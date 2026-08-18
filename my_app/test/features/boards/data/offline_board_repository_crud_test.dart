import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:my_app/database/local/models/cached_board.dart';
import 'package:my_app/database/local/models/personal_song_edit.dart';
import 'package:my_app/database/local/models/sync_queue.dart';
import 'package:my_app/features/boards/data/offline_board_repository.dart';
import 'package:my_app/shared/models/song_attachment.dart';

void main() {
  late Directory directory;
  late Isar isar;

  setUpAll(_initializeIsarCore);

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('board-crud-');
    isar = await Isar.open(
      [CachedBoardSchema, SyncQueueSchema, PersonalSongEditRecordSchema],
      directory: directory.path,
      name: 'crud_${DateTime.now().microsecondsSinceEpoch}',
    );
  });

  tearDown(() async {
    if (isar.isOpen) await isar.close(deleteFromDisk: true);
    if (await directory.exists()) await directory.delete(recursive: true);
  });

  test('create, update, and delete persist locally and request sync', () async {
    var syncRequests = 0;
    final repository = OfflineBoardRepository(
      isar: isar,
      userId: () => 'user',
      downloadRemoteAttachment: _unusedDownload,
      onSyncNeeded: () => syncRequests++,
    );

    final created = await repository.createBoard('  First Board  ');
    expect(created.name, 'First Board');
    expect((await repository.fetchBoards()).single.name, 'First Board');

    await repository.updateBoard(created.copyWith(name: 'Updated Board'));
    expect((await repository.fetchBoard(created.id)).name, 'Updated Board');

    await repository.deleteBoard(created.id);
    expect(await repository.fetchBoards(), isEmpty);

    final queue = await isar.syncQueues.where().findAll();
    expect(queue.map((item) => item.operation), ['upsert', 'upsert', 'delete']);
    expect(queue.every((item) => item.entityType == 'boards'), isTrue);
    expect(queue.every((item) => item.entityId == created.id), isTrue);
    expect(syncRequests, 3);
  });
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

Future<Uint8List> _unusedDownload(SongAttachment _) =>
    throw UnsupportedError('Not used by board CRUD test');
