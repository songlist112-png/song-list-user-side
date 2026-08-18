import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../database/isar_database.dart';
import '../../../core/services/sync_service.dart';
import 'offline_board_repository.dart';

import '../../../shared/models/artist.dart';
import '../../../shared/models/label.dart';
import '../../../shared/models/song.dart';
import '../../../shared/models/song_attachment.dart';
import '../../../shared/models/song_column.dart';
import '../../../shared/models/song_list.dart';
import '../../../shared/utils/media_type.dart';

final boardRepositoryProvider = Provider<BoardRepository>(
  (ref) => OfflineBoardRepository(
    isar: IsarDatabase.instance,
    userId: () => Supabase.instance.client.auth.currentUser?.id,
    downloadRemoteAttachment: ref.read(syncServiceProvider).downloadAttachment,
    onSyncNeeded: () => unawaited(ref.read(syncServiceProvider).synchronize()),
  ),
);

abstract interface class BoardRepository {
  Stream<void> watchChanges();
  Future<List<SongList>> fetchBoards();
  Future<SongList> fetchBoard(String id);
  Future<SongList> createBoard(String name);
  Future<void> updateBoard(SongList board);
  Future<void> deleteBoard(String id);
  Future<SongColumn> createColumn(String boardId, String title, int position);
  Future<void> updateColumn(SongColumn column);
  Future<void> deleteColumn(String id);
  Future<Song> createSong(String columnId, Song song, int position);
  Future<Song> updateSong(Song song);
  Future<void> deleteSong(String id);
  Future<Uint8List> downloadAttachment(SongAttachment attachment);
  Future<void> reorderSongs(List<Song> songs);
  Future<void> moveSong(String songId, String destinationColumnId);
  Future<Artist> createArtist(String name);
  Future<Artist> updateArtist(Artist artist);
  Future<void> deleteArtist(String id);
  Future<Label> createLabel(String boardId, String name, Color color);
  Future<Label> updateLabel(String boardId, Label label);
  Future<void> deleteLabel(String id);
}

class SupabaseBoardRepository implements BoardRepository {
  SupabaseBoardRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;
  bool? _currentUserIsAdmin;

  @override
  Stream<void> watchChanges() => const Stream<void>.empty();

  @override
  Future<List<SongList>> fetchBoards() => _fetchBoardGraph();

  @override
  Future<SongList> fetchBoard(String id) async {
    final boards = await _fetchBoardGraph();
    return boards.firstWhere((board) => board.id == id);
  }

  @override
  Future<SongList> createBoard(String name) async {
    final userId = _requireUserId();
    final currentUserIsAdmin = await _isCurrentUserAdmin();
    final row = await _client
        .from('boards')
        .insert({'created_by': userId, 'name': name.trim()})
        .select()
        .single();
    return _boardFromJson(
      row,
      const [],
      const [],
      currentUserIsAdmin: currentUserIsAdmin,
    );
  }

  @override
  Future<void> updateBoard(SongList board) async {
    await _client
        .from('boards')
        .update({
          'name': board.name.trim(),
          'show_artist': board.showArtist,
          'show_bpm': board.showBpm,
          'dark_mode': board.darkMode,
        })
        .eq('id', board.id);
  }

  @override
  Future<void> deleteBoard(String id) =>
      _client.from('boards').delete().eq('id', id);

  @override
  Future<SongColumn> createColumn(
    String boardId,
    String title,
    int position,
  ) async {
    final row = await _client
        .from('columns')
        .insert({
          'board_id': boardId,
          'created_by': _requireUserId(),
          'title': title.trim(),
          'position': position,
        })
        .select()
        .single();
    return _columnFromJson(row, const []);
  }

  @override
  Future<void> updateColumn(SongColumn column) => _client
      .from('columns')
      .update({'title': column.title.trim(), 'position': column.order})
      .eq('id', column.id);

  @override
  Future<void> deleteColumn(String id) =>
      _client.from('columns').delete().eq('id', id);

  @override
  Future<Song> createSong(String columnId, Song song, int position) async {
    final userId = _requireUserId();
    final row = await _client
        .from('songs')
        .insert({
          ..._songPayload(song),
          'column_id': columnId,
          'created_by': userId,
          'position': position,
        })
        .select('id')
        .single();
    var saved = song.copyWith(
      id: row['id'] as String,
      createdBy: userId,
      creatorType: await _creatorTypeForCurrentUser(),
      canEdit: true,
    );
    try {
      await _syncSongRelations(saved);
      saved = saved.copyWith(
        attachments: await _syncAttachments(saved.id, saved.attachments),
      );
    } on Exception {
      await _client.from('songs').delete().eq('id', saved.id);
      rethrow;
    }
    return saved;
  }

  @override
  Future<Song> updateSong(Song song) async {
    await _client.from('songs').update(_songPayload(song)).eq('id', song.id);
    await _syncSongRelations(song);
    return song.copyWith(
      attachments: await _syncAttachments(song.id, song.attachments),
    );
  }

  @override
  Future<void> deleteSong(String id) async {
    final rows = _maps(
      await _client.from('attachments').select('file_url').eq('song_id', id),
    );
    await _client.from('songs').delete().eq('id', id);
    final paths = rows
        .map((row) => row['file_url'] as String?)
        .whereType<String>()
        .toList();
    if (paths.isNotEmpty) {
      await _client.storage.from('attachments').remove(paths);
    }
  }

  @override
  Future<Uint8List> downloadAttachment(SongAttachment attachment) {
    final path = attachment.storagePath;
    if (path == null) {
      throw const FileSystemException('Attachment has not been uploaded');
    }
    return _client.storage.from('attachments').download(path);
  }

  @override
  Future<void> reorderSongs(List<Song> songs) async {
    await Future.wait(
      songs.indexed.map(
        (entry) => _client
            .from('songs')
            .update({'position': entry.$1})
            .eq('id', entry.$2.id),
      ),
    );
  }

  @override
  Future<void> moveSong(String songId, String destinationColumnId) async {
    final rows = _maps(
      await _client
          .from('songs')
          .select('position')
          .eq('column_id', destinationColumnId)
          .eq('deleted', false)
          .order('position', ascending: false)
          .limit(1),
    );
    final position = rows.isEmpty ? 0 : (rows.single['position'] as int) + 1;
    await _client
        .from('songs')
        .update({'column_id': destinationColumnId, 'position': position})
        .eq('id', songId);
  }

  @override
  Future<Artist> createArtist(String name) async {
    final userId = _requireUserId();
    final row = await _client
        .from('artists')
        .insert({
          'created_by': userId,
          'name': name.trim(),
          'slug': '${_slugify(name)}-${DateTime.now().microsecondsSinceEpoch}',
        })
        .select()
        .single();
    return _artistFromJson(row);
  }

  @override
  Future<Artist> updateArtist(Artist artist) async {
    final row = await _client
        .from('artists')
        .update({'name': artist.name.trim()})
        .eq('id', artist.id)
        .select()
        .single();
    return _artistFromJson(row);
  }

  @override
  Future<void> deleteArtist(String id) =>
      _client.from('artists').delete().eq('id', id);

  @override
  Future<Label> createLabel(String boardId, String name, Color color) async {
    final row = await _client
        .from('labels')
        .insert({
          'created_by': _requireUserId(),
          'name': name.trim(),
          'color': _colorToHex(color),
        })
        .select()
        .single();
    return _labelFromJson(row);
  }

  @override
  Future<Label> updateLabel(String boardId, Label label) async {
    final row = await _client
        .from('labels')
        .update({'name': label.name.trim(), 'color': _colorToHex(label.color)})
        .eq('id', label.id)
        .select()
        .single();
    return _labelFromJson(row);
  }

  @override
  Future<void> deleteLabel(String id) =>
      _client.from('labels').delete().eq('id', id);

  Future<void> _syncSongRelations(Song song) async {
    await Future.wait([
      _syncSongArtist(song),
      _syncSongLabels(song.id, song.labels),
    ]);
  }

  Future<void> _syncSongArtist(Song song) async {
    await _client.from('song_artists').delete().eq('song_id', song.id);
    final artistName = song.artistName?.trim();
    if (artistName == null || artistName.isEmpty) return;

    final userId = _requireUserId();
    final matches = _maps(
      await _client
          .from('artists')
          .select('id, created_by')
          .ilike('name', artistName)
          .limit(20),
    );
    final existing =
        matches.where((row) => row['created_by'] == userId).firstOrNull ??
        matches.firstOrNull;
    final artistId =
        existing?['id'] as String? ?? (await createArtist(artistName)).id;
    await _client.from('song_artists').upsert({
      'song_id': song.id,
      'artist_id': artistId,
      'role': 'primary',
    }, onConflict: 'song_id,artist_id');
  }

  Future<void> _syncSongLabels(String songId, List<String> labelIds) async {
    await _client.from('song_labels').delete().eq('song_id', songId);
    if (labelIds.isEmpty) return;
    await _client
        .from('song_labels')
        .insert(
          labelIds
              .map((labelId) => {'song_id': songId, 'label_id': labelId})
              .toList(),
        );
  }

  Future<List<SongAttachment>> _syncAttachments(
    String songId,
    List<SongAttachment> requested,
  ) async {
    final rows = _maps(
      await _client
          .from('attachments')
          .select('id, file_url, file_type, file_size')
          .eq('song_id', songId)
          .eq('deleted', false),
    );
    final existing = {for (final row in rows) row['file_url'] as String: row};
    final keptPaths = requested
        .map((item) => item.storagePath)
        .whereType<String>()
        .where(existing.containsKey)
        .toSet();
    final created = <SongAttachment>[];
    final createdPaths = <String>[];

    try {
      for (final attachment in requested.where((item) => item.needsUpload)) {
        final uploaded = await _uploadAttachment(songId, attachment);
        created.add(uploaded);
        createdPaths.add(uploaded.storagePath!);
      }
    } on Exception {
      if (createdPaths.isNotEmpty) {
        await _client
            .from('attachments')
            .delete()
            .inFilter('file_url', createdPaths);
        await _client.storage.from('attachments').remove(createdPaths);
      }
      rethrow;
    }

    final removed = existing.entries
        .where((entry) => !keptPaths.contains(entry.key))
        .toList();
    if (removed.isNotEmpty) {
      await _client
          .from('attachments')
          .delete()
          .inFilter(
            'id',
            removed.map((entry) => entry.value['id'] as String).toList(),
          );
      await _client.storage
          .from('attachments')
          .remove(removed.map((entry) => entry.key).toList());
    }

    return [
      ...keptPaths.map((path) => _attachmentFromJson(existing[path]!)),
      ...created,
    ];
  }

  Future<SongAttachment> _uploadAttachment(
    String songId,
    SongAttachment attachment,
  ) async {
    final file = File(attachment.localPath!);
    if (!await file.exists()) {
      throw FileSystemException('Attachment file not found', file.path);
    }

    final userId = _requireUserId();
    final safeName = attachment.name.replaceAll(
      RegExp(r'[^a-zA-Z0-9._-]'),
      '_',
    );
    final uniqueName =
        '${DateTime.now().microsecondsSinceEpoch}-${file.path.hashCode.abs()}'
        '__$safeName';
    final storagePath = '$userId/$songId/$uniqueName';
    final fileType = _mimeType(attachment.name);

    await _client.storage
        .from('attachments')
        .upload(
          storagePath,
          file,
          fileOptions: FileOptions(contentType: fileType),
        );

    try {
      final row = await _client
          .from('attachments')
          .insert({
            'song_id': songId,
            'file_url': storagePath,
            'file_type': fileType,
            'file_size': await file.length(),
          })
          .select('id, file_url, file_type, file_size')
          .single();
      return _attachmentFromJson(row);
    } on Exception {
      await _client.storage.from('attachments').remove([storagePath]);
      rethrow;
    }
  }

  String _requireUserId() {
    final id = _client.auth.currentUser?.id;
    if (id == null) throw const AuthException('Authentication required');
    return id;
  }

  Future<List<SongList>> _fetchBoardGraph() async {
    final currentUserId = _requireUserId();
    final currentUserIsAdmin = await _isCurrentUserAdmin();
    final data = await Future.wait([
      _client.from('boards').select().eq('deleted', false).order('created_at'),
      _client.from('columns').select().eq('deleted', false).order('position'),
      _client
          .from('songs')
          .select()
          .eq('deleted', false)
          .order('position')
          .order('id'),
      _client.from('labels').select().eq('deleted', false),
      _client.from('artists').select().eq('deleted', false),
      _client.from('song_labels').select('song_id, label_id'),
      _client.from('song_artists').select('song_id, artist_id, role'),
      _client
          .from('attachments')
          .select('id, song_id, file_url, file_type, file_size')
          .eq('deleted', false),
    ]);

    final boardRows = _maps(data[0]);
    final columnRows = _maps(data[1]);
    final songRows = _maps(data[2]);
    final labelRows = _maps(data[3]);
    final artistRows = _maps(data[4]);
    final songLabelRows = _maps(data[5]);
    final songArtistRows = _maps(data[6]);
    final attachmentRows = _maps(data[7]);

    final labels = labelRows.map(_labelFromJson).toList(growable: false);
    final artists = artistRows.map(_artistFromJson).toList(growable: false);
    final artistNames = {
      for (final row in artistRows) row['id'] as String: row['name'] as String,
    };
    final labelIdsBySong = <String, List<String>>{};
    for (final row in songLabelRows) {
      labelIdsBySong
          .putIfAbsent(row['song_id'] as String, () => [])
          .add(row['label_id'] as String);
    }
    final artistNameBySong = <String, String>{};
    for (final row in songArtistRows) {
      final name = artistNames[row['artist_id']];
      if (name != null) {
        artistNameBySong.putIfAbsent(row['song_id'], () => name);
      }
    }
    final attachmentsBySong = <String, List<SongAttachment>>{};
    for (final row in attachmentRows) {
      attachmentsBySong
          .putIfAbsent(row['song_id'] as String, () => [])
          .add(_attachmentFromJson(row));
    }

    final songsByColumn = <String, List<Song>>{};
    for (final row in songRows) {
      final columnId = row['column_id'] as String?;
      if (columnId == null) continue;
      songsByColumn
          .putIfAbsent(columnId, () => [])
          .add(
            _songFromJson(
              row,
              currentUserId: currentUserId,
              currentUserIsAdmin: currentUserIsAdmin,
              artistName: artistNameBySong[row['id']],
              labelIds: labelIdsBySong[row['id']] ?? const [],
              attachments: attachmentsBySong[row['id']] ?? const [],
            ),
          );
    }

    final columnsByBoard = <String, List<SongColumn>>{};
    for (final row in columnRows) {
      final boardId = row['board_id'] as String;
      columnsByBoard
          .putIfAbsent(boardId, () => [])
          .add(_columnFromJson(row, songsByColumn[row['id']] ?? const []));
    }

    return boardRows
        .map(
          (row) => _boardFromJson(
            row,
            columnsByBoard[row['id']] ?? const [],
            labels,
            currentUserIsAdmin: currentUserIsAdmin,
            artists: artists,
          ),
        )
        .toList(growable: false);
  }

  SongList _boardFromJson(
    Map<String, dynamic> json,
    List<SongColumn> columns,
    List<Label> labels, {
    required bool currentUserIsAdmin,
    List<Artist> artists = const [],
  }) {
    final ownerId = json['created_by'] as String? ?? '';
    final canEdit = ownerId == _client.auth.currentUser?.id;

    return SongList(
      id: json['id'] as String,
      ownerId: ownerId,
      name: json['name'] as String,
      columns: columns,
      artists: artists,
      labels: labels,
      showArtist: json['show_artist'] as bool? ?? true,
      showBpm: json['show_bpm'] as bool? ?? false,
      darkMode: json['dark_mode'] as bool? ?? false,
      isPublished: !canEdit,
      canEdit: canEdit,
      creatorType: canEdit && !currentUserIsAdmin
          ? BoardCreatorType.user
          : BoardCreatorType.admin,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  static SongColumn _columnFromJson(
    Map<String, dynamic> json,
    List<Song> songs,
  ) => SongColumn(
    id: json['id'] as String,
    title: json['title'] as String,
    songs: songs,
    order: json['position'] as int? ?? 0,
  );

  static Song _songFromJson(
    Map<String, dynamic> json, {
    required String currentUserId,
    required bool currentUserIsAdmin,
    required String? artistName,
    required List<String> labelIds,
    required List<SongAttachment> attachments,
  }) {
    final createdBy = json['created_by'] as String?;
    final isOwner = createdBy == currentUserId;
    return Song(
      id: json['id'] as String,
      createdBy: createdBy,
      creatorType: isOwner && !currentUserIsAdmin
          ? SongCreatorType.user
          : SongCreatorType.admin,
      canEdit: isOwner,
      title: json['title'] as String,
      artistName: artistName,
      tempo: json['tempo'] as int?,
      key: json['key_root'] as String?,
      keyType: json['key_type'] as String?,
      labels: labelIds,
      lyrics: _optionalText(json['lyrics']),
      attachments: attachments,
    );
  }

  Label _labelFromJson(Map<String, dynamic> json) => Label(
    id: json['id'] as String,
    createdBy: json['created_by'] as String?,
    name: json['name'] as String,
    color: _colorFromHex(json['color'] as String),
    canEdit: json['created_by'] == _client.auth.currentUser?.id,
  );

  Artist _artistFromJson(Map<String, dynamic> json) => Artist(
    id: json['id'] as String,
    createdBy: json['created_by'] as String?,
    name: json['name'] as String,
    canEdit: json['created_by'] == _client.auth.currentUser?.id,
  );

  static SongAttachment _attachmentFromJson(Map<String, dynamic> json) {
    final storagePath = json['file_url'] as String;
    final storedName = storagePath.split('/').last;
    return SongAttachment(
      id: json['id'] as String,
      name: storedName.contains('__')
          ? storedName.substring(storedName.indexOf('__') + 2)
          : storedName,
      storagePath: storagePath,
      fileType: normalizeMediaType(
        json['file_type'] as String,
        fileName: storedName,
      ),
      fileSize: (json['file_size'] as num).toInt(),
    );
  }

  static Map<String, dynamic> _songPayload(Song song) => {
    'title': song.title.trim(),
    'tempo': song.tempo,
    'key_root': song.key,
    'key_type': song.keyType,
    'lyrics': song.lyrics?.trim() ?? '',
    'is_published': false,
    'deleted': false,
  };

  Future<SongCreatorType> _creatorTypeForCurrentUser() async =>
      await _isCurrentUserAdmin()
      ? SongCreatorType.admin
      : SongCreatorType.user;

  Future<bool> _isCurrentUserAdmin() async {
    final cached = _currentUserIsAdmin;
    if (cached != null) return cached;
    final row = await _client
        .from('profiles')
        .select('role')
        .eq('id', _requireUserId())
        .single();
    return _currentUserIsAdmin = row['role'] == 'admin';
  }

  static Color _colorFromHex(String value) {
    final hex = value.replaceFirst('#', '');
    final argb = switch (hex.length) {
      3 => 'FF${hex.split('').map((char) => '$char$char').join()}',
      6 => 'FF$hex',
      8 => hex,
      _ => '',
    };
    return Color(int.tryParse(argb, radix: 16) ?? Colors.blue.toARGB32());
  }

  static String _colorToHex(Color color) {
    final argb = color.toARGB32().toRadixString(16).padLeft(8, '0');
    return '#${argb.substring(2).toUpperCase()}';
  }

  static String _slugify(String value) => value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');

  static String _mimeType(String fileName) =>
      normalizeMediaType('', fileName: fileName);

  static String? _optionalText(Object? value) {
    final text = (value as String?)?.trim();
    return text == null || text.isEmpty ? null : text;
  }

  static List<Map<String, dynamic>> _maps(Object? value) =>
      (value as List? ?? const []).cast<Map<String, dynamic>>();
}
