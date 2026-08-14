import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../features/boards/data/board_repository.dart';
import '../../../shared/utils/media_type.dart';
import '../../local/models/sync_queue.dart';

/// Sole data-network boundary used by background synchronization.
class SyncRemoteDataSource {
  SyncRemoteDataSource({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client,
      _reader = SupabaseBoardRepository(client: client);

  final SupabaseClient _client;
  final SupabaseBoardRepository _reader;

  static const _serverTimeRetryDelays = <Duration>[
    Duration(milliseconds: 500),
    Duration(seconds: 1),
    Duration(seconds: 2),
  ];

  Future<DateTime> serverTime() async {
    for (var attempt = 0; ; attempt++) {
      try {
        final value = await _client.rpc<Object>('sync_server_time');
        return DateTime.parse(value as String).toUtc();
      } on PostgrestException catch (error) {
        final statusCode = int.tryParse(error.code ?? '');
        final retryable = statusCode != null && statusCode >= 500;
        if (!retryable || attempt == _serverTimeRetryDelays.length) rethrow;
        await Future<void>.delayed(_serverTimeRetryDelays[attempt]);
      }
    }
  }

  Future<bool> hasChangesSince(DateTime since) async {
    return await _client.rpc<bool>(
      'sync_has_changes',
      params: {'since_at': since.toUtc().toIso8601String()},
    );
  }

  Future<List<dynamic>> fetchBoardGraph() => _reader.fetchBoards();

  Future<List<Map<String, dynamic>>> fetchPersonalSongEdits({
    DateTime? since,
  }) async {
    final response = since == null
        ? await _client.from('user_song_edits').select().order('updated_at')
        : await _client
              .from('user_song_edits')
              .select()
              .gt('updated_at', since.toUtc().toIso8601String())
              .order('updated_at');
    return (response as List)
        .map((row) => (row as Map).cast<String, dynamic>())
        .toList(growable: false);
  }

  Future<Uint8List> downloadAttachment(String storagePath) =>
      _client.storage.from('attachments').download(storagePath);

  Future<void> apply(SyncQueue item) async {
    final payload = item.payload == null
        ? <String, dynamic>{}
        : (jsonDecode(item.payload!) as Map).cast<String, dynamic>();
    if (item.entityType == 'user_song_edits') {
      await _client.rpc<Object?>(
        'sync_upsert_user_song_edit',
        params: {
          'p_id': payload['id'],
          'p_song_id': payload['song_id'],
          'p_lyrics': payload['lyrics'],
          'p_client_updated_at': payload['client_updated_at'],
          'p_deleted': payload['deleted'],
        },
      );
      return;
    }
    if (item.operation == 'delete') {
      await _client
          .from(item.entityType)
          .update({'deleted': true})
          .eq('id', item.entityId);
      return;
    }
    if (item.operation == 'reorder') {
      final ids = (payload['ids'] as List).cast<String>();
      await _applyPersonalSongOrder(
        columnId: payload['column_id'] as String,
        ids: ids,
      );
      return;
    }
    if (item.operation == 'move') {
      await _client.rpc<void>(
        'sync_move_song',
        params: {
          'p_song_id': payload['song_id'] as String,
          'p_source_column_id': payload['source_column_id'] as String,
          'p_destination_column_id': payload['destination_column_id'] as String,
          'p_source_song_ids': (payload['source_song_ids'] as List)
              .cast<String>(),
          'p_destination_song_ids': (payload['destination_song_ids'] as List)
              .cast<String>(),
        },
      );
      return;
    }
    if (item.entityType == 'songs') {
      await _upsertSong(payload);
      return;
    }
    final row = Map<String, dynamic>.from(payload)
      ..removeWhere((_, value) => value == null);
    await _client.from(item.entityType).upsert(row, onConflict: 'id');
  }

  Future<void> _applyPersonalSongOrder({
    required String columnId,
    required List<String> ids,
  }) async {
    final response = await _client.rpc<List<dynamic>>(
      'sync_reorder_songs',
      params: {'p_column_id': columnId, 'p_song_ids': ids},
    );
    final confirmedIds = response.cast<String>();
    if (!_sameOrder(confirmedIds, ids)) {
      throw StateError('Server did not confirm song arrangement');
    }
  }

  static bool _sameOrder(List<String> first, List<String> second) {
    if (first.length != second.length) return false;
    for (var index = 0; index < first.length; index++) {
      if (first[index] != second[index]) return false;
    }
    return true;
  }

  Future<void> _upsertSong(Map<String, dynamic> payload) async {
    final artistName = payload.remove('artist_name') as String?;
    final labelIds = (payload.remove('label_ids') as List? ?? const [])
        .cast<String>();
    final attachments = (payload.remove('attachments') as List? ?? const [])
        .map((item) => (item as Map).cast<String, dynamic>())
        .toList();
    await _client.from('songs').upsert(payload, onConflict: 'id');
    final songId = payload['id'] as String;

    await _client.from('song_artists').delete().eq('song_id', songId);
    if (artistName != null && artistName.trim().isNotEmpty) {
      final matches =
          (await _client
                      .from('artists')
                      .select('id')
                      .ilike('name', artistName.trim())
                      .limit(1)
                  as List)
              .cast<Map<String, dynamic>>();
      String artistId;
      if (matches.isEmpty) {
        final created = await _client
            .from('artists')
            .insert({
              'created_by': payload['created_by'],
              'name': artistName.trim(),
              'slug':
                  '${_slug(artistName)}-${DateTime.now().microsecondsSinceEpoch}',
            })
            .select('id')
            .single();
        artistId = created['id'] as String;
      } else {
        artistId = matches.first['id'] as String;
      }
      await _client.from('song_artists').upsert({
        'song_id': songId,
        'artist_id': artistId,
        'role': 'primary',
      }, onConflict: 'song_id,artist_id');
    }

    await _client.from('song_labels').delete().eq('song_id', songId);
    if (labelIds.isNotEmpty) {
      await _client
          .from('song_labels')
          .insert(
            labelIds.map((id) => {'song_id': songId, 'label_id': id}).toList(),
          );
    }
    await _syncAttachments(
      songId,
      payload['created_by'] as String,
      attachments,
    );
  }

  Future<void> _syncAttachments(
    String songId,
    String userId,
    List<Map<String, dynamic>> requested,
  ) async {
    final existing =
        (await _client
                    .from('attachments')
                    .select('id, file_url')
                    .eq('song_id', songId)
                    .eq('deleted', false)
                as List)
            .cast<Map<String, dynamic>>();
    final keep = requested
        .map((item) => item['storage_path'])
        .whereType<String>()
        .toSet();
    for (final item in requested.where(
      (item) => item['storage_path'] == null,
    )) {
      final localPath = item['local_path'] as String?;
      if (localPath == null) continue;
      final file = File(localPath);
      if (!await file.exists()) {
        throw FileSystemException('Attachment file not found', localPath);
      }
      final name = (item['name'] as String).replaceAll(
        RegExp(r'[^a-zA-Z0-9._-]'),
        '_',
      );
      final attachmentId = item['id'] as String?;
      if (attachmentId == null) {
        throw StateError('Local attachment requires a stable UUID');
      }
      // Stable object path and row UUID make retries idempotent.
      final storagePath = '$userId/$songId/${attachmentId}__$name';
      final mediaType = normalizeMediaType(
        item['file_type'] as String? ?? '',
        fileName: item['name'] as String?,
      );
      await _client.storage
          .from('attachments')
          .upload(
            storagePath,
            file,
            fileOptions: FileOptions(contentType: mediaType, upsert: true),
          );
      await _client.from('attachments').upsert({
        'id': attachmentId,
        'song_id': songId,
        'file_url': storagePath,
        'file_name': item['name'],
        'file_type': mediaType,
        'file_size': item['file_size'],
        'created_by': userId,
        'deleted': false,
      }, onConflict: 'id');
      keep.add(storagePath);
    }
    final removed = existing
        .where((row) => !keep.contains(row['file_url']))
        .toList();
    for (final row in removed) {
      await _client
          .from('attachments')
          .update({'deleted': true})
          .eq('id', row['id']);
    }
  }

  static String _slug(String value) => value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');
}
