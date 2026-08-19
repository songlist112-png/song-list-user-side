import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../shared/utils/media_type.dart';
import '../../local/models/sync_queue.dart';
import '../models/sync_pull_models.dart';

typedef ReorderSongsRpc =
    Future<void> Function({
      required String columnId,
      required List<String> ids,
    });

/// Sole data-network boundary used by background synchronization.
class SyncRemoteDataSource {
  SyncRemoteDataSource({
    SupabaseClient? client,
    ReorderSongsRpc? reorderSongsRpc,
  }) : // Keep the injectable boundary private while retaining a clear API.
       // ignore: prefer_initializing_formals
       _reorderSongsRpc = reorderSongsRpc,
       _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;
  final ReorderSongsRpc? _reorderSongsRpc;

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

  Future<SyncStructureDelta> fetchStructureDelta({
    required DateTime until,
    DateTime? since,
  }) async {
    final response = await _client.rpc<Map<String, dynamic>>(
      'sync_pull_structure',
      params: {
        'p_since': since?.toUtc().toIso8601String(),
        'p_until': until.toUtc().toIso8601String(),
      },
    );
    return SyncStructureDelta.fromJson(response);
  }

  Future<SyncSongPage> fetchSongPage({
    required DateTime until,
    required int pageSize,
    DateTime? since,
    DateTime? cursorUpdatedAt,
    String? cursorId,
  }) async {
    final response = await _client.rpc<List<dynamic>>(
      'sync_pull_song_page',
      params: {
        'p_since': since?.toUtc().toIso8601String(),
        'p_until': until.toUtc().toIso8601String(),
        'p_cursor_updated_at': cursorUpdatedAt?.toUtc().toIso8601String(),
        'p_cursor_id': cursorId,
        'p_page_size': pageSize,
      },
    );
    return SyncSongPage.fromJson(response, pageSize: pageSize);
  }

  Future<Map<String, List<String>>> fetchOwnedSongOrders(
    Set<String> columnIds,
  ) async {
    if (columnIds.isEmpty) return const {};
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw const AuthException('Authentication required');
    final response = await _client
        .from('songs')
        .select('id, column_id')
        .eq('created_by', userId)
        .eq('deleted', false)
        .inFilter('column_id', columnIds.toList())
        .order('position')
        .order('id');
    final result = {for (final id in columnIds) id: <String>[]};
    for (final item in response as List) {
      final row = (item as Map).cast<String, dynamic>();
      result[row['column_id'] as String]?.add(row['id'] as String);
    }
    return result;
  }

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
    final injectedRpc = _reorderSongsRpc;
    if (injectedRpc != null) {
      await injectedRpc(columnId: columnId, ids: ids);
      return;
    }
    // The canonical board read performed by SyncService is the authoritative
    // confirmation. PostgREST response decoding can vary between deployed
    // function versions, so a successful transaction must not be rejected
    // only because its immediate response has a different runtime shape.
    await _client.rpc<Object?>(
      'sync_reorder_songs',
      params: {'p_column_id': columnId, 'p_song_ids': ids},
    );
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
