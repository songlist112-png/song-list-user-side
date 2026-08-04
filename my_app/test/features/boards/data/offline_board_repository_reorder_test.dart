import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:my_app/database/local/models/cached_board.dart';
import 'package:my_app/database/local/models/sync_queue.dart';
import 'package:my_app/features/boards/data/board_codec.dart';
import 'package:my_app/features/boards/data/offline_board_repository.dart';
import 'package:my_app/shared/models/song.dart';
import 'package:my_app/shared/models/song_attachment.dart';
import 'package:my_app/shared/models/song_column.dart';
import 'package:my_app/shared/models/song_list.dart';

void main() {
  late Directory directory;
  late Isar isar;
  late String databaseName;
  var isarOpened = false;

  setUpAll(_initializeIsarCore);

  setUp(() async {
    isarOpened = false;
    directory = await Directory.systemTemp.createTemp('song-reorder-');
    databaseName = 'reorder_${DateTime.now().microsecondsSinceEpoch}';
    isar = await _openIsar(directory.path, databaseName);
    isarOpened = true;
    await _seedBoard(isar);
  });

  tearDown(() async {
    if (isarOpened && isar.isOpen) {
      await isar.close(deleteFromDisk: true);
    }
    if (await directory.exists()) await directory.delete(recursive: true);
  });

  test(
    'latest rapid reorder survives Isar restart with one queue item',
    () async {
      var syncRequests = 0;
      final repository = _repository(isar, onSyncNeeded: () => syncRequests++);
      final songs = (await repository.fetchBoard('board')).columns.first.songs;

      final firstMove = repository.reorderSongs([songs[1], songs[2], songs[0]]);
      final finalMove = repository.reorderSongs([songs[2], songs[0], songs[1]]);
      await Future.wait([firstMove, finalMove]);

      await isar.close();
      isar = await _openIsar(directory.path, databaseName);

      final restored = await _repository(isar).fetchBoard('board');
      expect(restored.columns.first.songs.map((song) => song.id), [
        'three',
        'one',
        'two',
      ]);

      final queue = await isar.syncQueues.where().findAll();
      expect(queue, hasLength(1));
      final payload = jsonDecode(queue.single.payload!) as Map<String, dynamic>;
      expect(payload['column_id'], 'column');
      expect(payload['ids'], ['three', 'one', 'two']);
      expect(syncRequests, 2);
    },
  );

  test(
    'moves a personal song between columns and queues atomic move',
    () async {
      var syncRequests = 0;
      final repository = _repository(isar, onSyncNeeded: () => syncRequests++);

      await repository.moveSong('one', 'column-two');
      await isar.close();
      isar = await _openIsar(directory.path, databaseName);

      final restored = await _repository(isar).fetchBoard('board');
      expect(restored.columns[0].songs.map((song) => song.id), [
        'two',
        'three',
      ]);
      expect(restored.columns[1].songs.map((song) => song.id), ['one']);

      final queue = await isar.syncQueues.where().findAll();
      expect(queue, hasLength(1));
      expect(queue.single.operation, 'move');
      final payload = jsonDecode(queue.single.payload!) as Map<String, dynamic>;
      expect(payload['source_column_id'], 'column');
      expect(payload['destination_column_id'], 'column-two');
      expect(payload['source_song_ids'], ['two', 'three']);
      expect(payload['destination_song_ids'], ['one']);
      expect(syncRequests, 1);
    },
  );
}

Future<void> _initializeIsarCore() async {
  final packageConfig = File('.dart_tool/package_config.json');
  final config = jsonDecode(await packageConfig.readAsString());
  final packages = config['packages'] as List<dynamic>;
  final isarFlutterLibs = packages.cast<Map<String, dynamic>>().singleWhere(
    (package) => package['name'] == 'isar_flutter_libs',
  );
  final rootUri = isarFlutterLibs['rootUri'] as String;
  final packageRoot = packageConfig.uri.resolve(
    rootUri.endsWith('/') ? rootUri : '$rootUri/',
  );
  final relativeLibraryPath = switch (Abi.current()) {
    Abi.windowsX64 || Abi.windowsArm64 => 'windows/isar.dll',
    Abi.linuxX64 => 'linux/libisar.so',
    Abi.macosX64 || Abi.macosArm64 => 'macos/libisar.dylib',
    final abi => throw UnsupportedError('Unsupported Isar test ABI: $abi'),
  };
  final library = File.fromUri(packageRoot.resolve(relativeLibraryPath));

  await Isar.initializeIsarCore(libraries: {Abi.current(): library.path});
}

Future<Isar> _openIsar(String directory, String name) => Isar.open(
  [CachedBoardSchema, SyncQueueSchema],
  directory: directory,
  name: name,
);

Future<void> _seedBoard(Isar isar) async {
  final board = SongList(
    id: 'board',
    ownerId: 'user',
    name: 'My songs',
    canEdit: true,
    createdAt: DateTime.utc(2026),
    columns: const [
      SongColumn(
        id: 'column',
        title: 'Set list',
        songs: [
          Song(id: 'one', title: 'One'),
          Song(id: 'two', title: 'Two'),
          Song(id: 'three', title: 'Three'),
        ],
      ),
      SongColumn(id: 'column-two', title: 'Encore'),
    ],
  );
  final row = CachedBoard()
    ..uuid = board.id
    ..cacheKey = 'user:${board.id}'
    ..accountId = 'user'
    ..ownerId = 'user'
    ..document = BoardCodec.encode(board)
    ..updatedAt = DateTime.now().toUtc();
  await isar.writeTxn(() => isar.cachedBoards.put(row));
}

OfflineBoardRepository _repository(
  Isar isar, {
  void Function()? onSyncNeeded,
}) => OfflineBoardRepository(
  isar: isar,
  userId: () => 'user',
  downloadRemoteAttachment: _unusedDownload,
  onSyncNeeded: onSyncNeeded,
);

Future<Uint8List> _unusedDownload(SongAttachment _) =>
    throw UnsupportedError('Not used by reorder test');
