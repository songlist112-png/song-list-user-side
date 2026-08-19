import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:my_app/core/services/board_sync_cache.dart';
import 'package:my_app/database/local/models/cached_board.dart';
import 'package:my_app/database/local/models/sync_metadata.dart';
import 'package:my_app/database/local/models/sync_queue.dart';
import 'package:my_app/database/remote/models/sync_pull_models.dart';
import 'package:my_app/features/boards/data/board_codec.dart';
import 'package:my_app/shared/models/song_attachment.dart';
import 'package:my_app/shared/models/song_list.dart';

void main() {
  late Directory directory;
  late Isar isar;

  setUpAll(_initializeIsarCore);

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('board-sync-cache-');
    isar = await Isar.open(
      [CachedBoardSchema, SyncQueueSchema, SyncMetadataSchema],
      directory: directory.path,
      name: 'sync_${DateTime.now().microsecondsSinceEpoch}',
    );
  });

  tearDown(() async {
    if (isar.isOpen) await isar.close(deleteFromDisk: true);
    if (await directory.exists()) await directory.delete(recursive: true);
  });

  test('publishes structure before bulk song pages complete', () async {
    final cache = BoardSyncCache(isar: isar, userId: 'user');

    await cache.applyStructure(_structure(), isInitial: true);

    var board = _cachedBoard(isar);
    expect(board.name, 'My board');
    expect(board.columns.map((column) => column.id), ['column']);
    expect(board.columns.single.songs, isEmpty);

    await cache.applySongPage([
      _songRow('song-2', position: 1, title: 'Second'),
      _songRow(
        'song-1',
        position: 0,
        title: 'First',
        attachments: [
          {
            'id': 'attachment-1',
            'file_url': 'user/song-1/attachment-1__chart.pdf',
            'file_type': 'application/pdf',
            'file_size': 123,
          },
        ],
      ),
    ]);

    board = _cachedBoard(isar);
    expect(board.columns.single.songs.map((song) => song.id), [
      'song-1',
      'song-2',
    ]);
    final attachment = board.columns.single.songs.first.attachments.single;
    expect(attachment.storagePath, contains('chart.pdf'));
    expect(attachment.localPath, isNull);
  });

  test('incremental page updates and deletes only changed songs', () async {
    final cache = BoardSyncCache(isar: isar, userId: 'user');
    await cache.applyStructure(_structure(), isInitial: true);
    await cache.applySongPage([
      _songRow('song-1', position: 0, title: 'Old title'),
      _songRow('song-2', position: 1, title: 'Keep me'),
    ]);

    await cache.applySongPage([
      _songRow('song-1', position: 0, title: 'Updated title'),
      _songRow('song-2', position: 1, title: 'Keep me', deleted: true),
    ]);

    final songs = _cachedBoard(isar).columns.single.songs;
    expect(songs, hasLength(1));
    expect(songs.single.id, 'song-1');
    expect(songs.single.title, 'Updated title');
  });

  test(
    'hard tombstone removes a song without full cache replacement',
    () async {
      final cache = BoardSyncCache(isar: isar, userId: 'user');
      await cache.applyStructure(_structure(), isInitial: true);
      await cache.applySongPage([
        _songRow('song-1', position: 0, title: 'Remove me'),
        _songRow('song-2', position: 1, title: 'Keep me'),
      ]);

      await cache.applyStructure(
        SyncStructureDelta(
          currentUserIsAdmin: false,
          boards: const [],
          columns: const [],
          labels: const [],
          artists: const [],
          tombstones: const [
            {'entity_type': 'songs', 'entity_id': 'song-1'},
          ],
        ),
        isInitial: false,
      );

      expect(_cachedBoard(isar).columns.single.songs.map((song) => song.id), [
        'song-2',
      ]);
    },
  );

  test('attachment refresh preserves a downloaded local path', () async {
    final cache = BoardSyncCache(isar: isar, userId: 'user');
    final attachmentRow = {
      'id': 'attachment-1',
      'file_url': 'user/song-1/attachment-1__chart.pdf',
      'file_type': 'application/pdf',
      'file_size': 123,
    };
    await cache.applyStructure(_structure(), isInitial: true);
    await cache.applySongPage([
      _songRow(
        'song-1',
        position: 0,
        title: 'Song',
        attachments: [attachmentRow],
      ),
    ]);
    final row = isar.cachedBoards.where().findAllSync().single;
    final board = BoardCodec.decode(row.document);
    final column = board.columns.single;
    final song = column.songs.single;
    final attachment = song.attachments.single;
    final downloaded = SongAttachment(
      id: attachment.id,
      name: attachment.name,
      storagePath: attachment.storagePath,
      localPath: 'C:/offline/chart.pdf',
      fileType: attachment.fileType,
      fileSize: attachment.fileSize,
    );
    row.document = BoardCodec.encode(
      board.copyWith(
        columns: [
          column.copyWith(
            songs: [
              song.copyWith(attachments: [downloaded]),
            ],
          ),
        ],
      ),
    );
    await isar.writeTxn(() => isar.cachedBoards.put(row));

    await cache.applySongPage([
      _songRow(
        'song-1',
        position: 0,
        title: 'Song updated',
        attachments: [attachmentRow],
      ),
    ]);

    final refreshed = _cachedBoard(
      isar,
    ).columns.single.songs.single.attachments.single;
    expect(refreshed.localPath, 'C:/offline/chart.pdf');
  });

  test('pending local mutation protects its board from remote pages', () async {
    final cache = BoardSyncCache(isar: isar, userId: 'user');
    await cache.applyStructure(_structure(), isInitial: true);
    await cache.applySongPage([
      _songRow('song-1', position: 0, title: 'Local title'),
    ]);
    final queue = SyncQueue()
      ..entityType = 'songs'
      ..entityId = 'song-1'
      ..operation = 'upsert'
      ..payload = '{}'
      ..status = 'pending'
      ..createdAt = DateTime.utc(2026)
      ..userId = 'user';
    await isar.writeTxn(() => isar.syncQueues.put(queue));

    await cache.applySongPage([
      _songRow('song-1', position: 0, title: 'Remote title'),
    ]);

    expect(_cachedBoard(isar).columns.single.songs.single.title, 'Local title');
  });

  test('song page exposes a stable updated-at and id cursor', () {
    final rows = [
      _songRow('song-1', position: 0, title: 'One'),
      _songRow('song-2', position: 1, title: 'Two'),
    ];
    final page = SyncSongPage.fromJson(rows, pageSize: 2);

    expect(page.hasMore, isTrue);
    expect(page.nextId, 'song-2');
    expect(page.nextUpdatedAt, DateTime.utc(2026, 8, 19));
  });

  test('sync version and resumable page cursor persist in Isar', () async {
    final metadata = SyncMetadata()
      ..userId = 'user'
      ..syncVersion = 1
      ..initialSyncComplete = false
      ..initialSyncUpperBound = DateTime.utc(2026, 8, 19, 1)
      ..songCursorUpdatedAt = DateTime.utc(2026, 8, 19)
      ..songCursorId = 'song-500';
    await isar.writeTxn(() => isar.syncMetadatas.put(metadata));

    final restored = await isar.syncMetadatas.getByUserId('user');
    expect(restored?.syncVersion, 1);
    expect(restored?.initialSyncComplete, isFalse);
    expect(
      restored?.initialSyncUpperBound?.toUtc(),
      DateTime.utc(2026, 8, 19, 1),
    );
    expect(restored?.songCursorId, 'song-500');
  });
}

SyncStructureDelta _structure() => SyncStructureDelta(
  currentUserIsAdmin: false,
  boards: [
    {
      'id': 'board',
      'created_by': 'user',
      'name': 'My board',
      'show_artist': true,
      'show_bpm': false,
      'dark_mode': false,
      'created_at': DateTime.utc(2026).toIso8601String(),
      'deleted': false,
    },
  ],
  columns: [
    {
      'id': 'column',
      'board_id': 'board',
      'created_by': 'user',
      'title': 'Songs',
      'position': 0,
      'deleted': false,
    },
  ],
  labels: const [],
  artists: const [],
  tombstones: const [],
);

Map<String, dynamic> _songRow(
  String id, {
  required int position,
  required String title,
  bool deleted = false,
  List<Map<String, dynamic>> attachments = const [],
}) => {
  'id': id,
  'column_id': 'column',
  'created_by': 'user',
  'title': title,
  'tempo': null,
  'key_root': null,
  'key_type': null,
  'lyrics': '',
  'position': position,
  'deleted': deleted,
  'updated_at': DateTime.utc(2026, 8, 19).toIso8601String(),
  'artist_name': null,
  'label_ids': <String>[],
  'attachments': attachments,
};

SongList _cachedBoard(Isar isar) {
  final rows = isar.cachedBoards.where().findAllSync();
  expect(rows, hasLength(1));
  return BoardCodec.decode(rows.single.document);
}

Future<void> _initializeIsarCore() async {
  final packageConfig = File('.dart_tool/package_config.json');
  final config = jsonDecode(await packageConfig.readAsString());
  final packages = config['packages'] as List<dynamic>;
  final isarFlutterLibs = packages.cast<Map<String, dynamic>>().singleWhere(
    (package) => package['name'] == 'isar_community_flutter_libs',
  );
  final rootUri = isarFlutterLibs['rootUri'] as String;
  final packageRoot = packageConfig.uri.resolve(
    rootUri.endsWith('/') ? rootUri : '$rootUri/',
  );
  final relativeLibraryPath = switch (Abi.current()) {
    Abi.windowsX64 || Abi.windowsArm64 => 'windows/libisar.dll',
    Abi.linuxX64 => 'linux/libisar.so',
    Abi.macosX64 || Abi.macosArm64 => 'macos/libisar.dylib',
    final abi => throw UnsupportedError('Unsupported Isar test ABI: $abi'),
  };
  final library = File.fromUri(packageRoot.resolve(relativeLibraryPath));
  await Isar.initializeIsarCore(libraries: {Abi.current(): library.path});
}
