import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:my_app/database/local/models/personal_song_edit.dart';
import 'package:my_app/database/local/models/sync_queue.dart';
import 'package:my_app/features/songs/data/isar_personal_song_edit_repository.dart';

void main() {
  late Directory directory;
  late Isar isar;
  var activeUser = 'user-one';
  var syncRequests = 0;

  setUpAll(_initializeIsarCore);
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('personal-edit-');
    isar = await Isar.open(
      [PersonalSongEditRecordSchema, SyncQueueSchema],
      directory: directory.path,
      name: 'personal_${DateTime.now().microsecondsSinceEpoch}',
    );
    activeUser = 'user-one';
    syncRequests = 0;
  });
  tearDown(() async {
    await isar.close(deleteFromDisk: true);
    await directory.delete(recursive: true);
  });

  test('saves locally and collapses repeated sync mutations', () async {
    final repository = IsarPersonalSongEditRepository(
      isar: isar,
      userId: () => activeUser,
      onSyncNeeded: () => syncRequests++,
    );

    await repository.save(songId: 'admin-song', lyrics: 'First');
    await repository.save(songId: 'admin-song', lyrics: 'Second\n[My note]');

    final edits = await isar.personalSongEditRecords.where().findAll();
    final queue = await isar.syncQueues.where().findAll();
    expect(edits, hasLength(1));
    expect(edits.single.lyrics, 'Second\n[My note]');
    expect(queue, hasLength(1));
    expect(jsonDecode(queue.single.payload!)['lyrics'], 'Second\n[My note]');
    expect(syncRequests, 2);
  });

  test('isolates local records by authenticated user', () async {
    final repository = IsarPersonalSongEditRepository(
      isar: isar,
      userId: () => activeUser,
    );
    await repository.save(songId: 'admin-song', lyrics: 'User one');
    activeUser = 'user-two';
    await repository.save(songId: 'admin-song', lyrics: 'User two');

    final edits = await isar.personalSongEditRecords.where().findAll();
    expect(edits, hasLength(2));
    expect(edits.map((edit) => edit.cacheKey), {
      'user-one:admin-song',
      'user-two:admin-song',
    });
  });

  test('reset persists tombstone for offline synchronization', () async {
    final repository = IsarPersonalSongEditRepository(
      isar: isar,
      userId: () => activeUser,
      onSyncNeeded: () => syncRequests++,
    );
    await repository.save(songId: 'admin-song', lyrics: 'Private');
    await repository.remove('admin-song');

    final edit = (await isar.personalSongEditRecords.where().findAll()).single;
    final queue = (await isar.syncQueues.where().findAll()).single;
    expect(edit.deleted, isTrue);
    expect(jsonDecode(queue.payload!)['deleted'], isTrue);
    expect(syncRequests, 2);
  });
}

Future<void> _initializeIsarCore() async {
  final packageConfig = File('.dart_tool/package_config.json');
  final config = jsonDecode(await packageConfig.readAsString());
  final packages = config['packages'] as List<dynamic>;
  final package = packages.cast<Map<String, dynamic>>().singleWhere(
    (item) => item['name'] == 'isar_community_flutter_libs',
  );
  final rootUri = package['rootUri'] as String;
  final packageRoot = packageConfig.uri.resolve(
    rootUri.endsWith('/') ? rootUri : '$rootUri/',
  );
  final libraryPath = switch (Abi.current()) {
    Abi.windowsX64 || Abi.windowsArm64 => 'windows/libisar.dll',
    Abi.linuxX64 => 'linux/libisar.so',
    Abi.macosX64 || Abi.macosArm64 => 'macos/libisar.dylib',
    final abi => throw UnsupportedError('Unsupported Isar test ABI: $abi'),
  };
  final library = File.fromUri(packageRoot.resolve(libraryPath));
  await Isar.initializeIsarCore(libraries: {Abi.current(): library.path});
}
