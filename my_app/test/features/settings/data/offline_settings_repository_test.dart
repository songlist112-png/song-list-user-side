import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_app/database/local/models/sync_queue.dart';
import 'package:my_app/features/settings/data/datasources/local_settings_datasource.dart';
import 'package:my_app/features/settings/data/datasources/remote_settings_datasource.dart';
import 'package:my_app/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:my_app/features/settings/domain/entities/user_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockRemoteSettingsDataSource extends Mock
    implements RemoteSettingsDataSource {}

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
  [SyncQueueSchema],
  directory: directory,
  name: name,
);

SettingsRepositoryImpl _repository(
  Isar isar, {
  required LocalSettingsDataSource local,
  required RemoteSettingsDataSource remote,
  void Function()? onSyncNeeded,
}) => SettingsRepositoryImpl(
  isar: isar,
  userId: () => 'user',
  local: local,
  remote: remote,
  onSyncNeeded: onSyncNeeded,
);

void main() {
  late Directory directory;
  late Isar isar;
  late String databaseName;
  var isarOpened = false;

  setUpAll(_initializeIsarCore);

  setUp(() async {
    isarOpened = false;
    SharedPreferences.setMockInitialValues({});
    directory = await Directory.systemTemp.createTemp('settings-');
    databaseName = 'settings_${DateTime.now().microsecondsSinceEpoch}';
    isar = await _openIsar(directory.path, databaseName);
    isarOpened = true;
  });

  tearDown(() async {
    if (isarOpened && isar.isOpen) {
      await isar.close(deleteFromDisk: true);
    }
    if (await directory.exists()) await directory.delete(recursive: true);
  });

  test('save persists locally, enqueues one upsert, and skips the remote',
      () async {
    final preferences = await SharedPreferences.getInstance();
    final local = LocalSettingsDataSource(preferences: preferences);
    final remote = MockRemoteSettingsDataSource();
    var syncRequests = 0;
    final repository = _repository(
      isar,
      local: local,
      remote: remote,
      onSyncNeeded: () => syncRequests++,
    );

    await repository.save(const UserPreferences(lyricsFontScale: 1.25));

    final loaded = await repository.load();
    expect(loaded, const UserPreferences(lyricsFontScale: 1.25));
    verifyNever(() => remote.fetch(userId: any(named: 'userId')));

    final queue = await isar.syncQueues.where().findAll();
    expect(queue, hasLength(1));
    final item = queue.single;
    expect(item.entityType, 'user_preferences');
    expect(item.operation, 'upsert');
    expect(item.status, 'pending');
    expect(item.userId, 'user');
    expect(jsonDecode(item.payload!)['lyrics_font_scale'], 1.25);
    expect(syncRequests, 1);
  });

  test('rapid saves coalesce into a single queue item', () async {
    final preferences = await SharedPreferences.getInstance();
    final local = LocalSettingsDataSource(preferences: preferences);
    final remote = MockRemoteSettingsDataSource();
    final repository = _repository(isar, local: local, remote: remote);

    await repository.save(const UserPreferences(lyricsFontScale: 1.1));
    await repository.save(const UserPreferences(lyricsFontScale: 1.3));

    final queue = await isar.syncQueues.where().findAll();
    expect(queue, hasLength(1));
    expect(jsonDecode(queue.single.payload!)['lyrics_font_scale'], 1.3);
  });

  test('load falls back to defaults when offline and nothing is cached',
      () async {
    final preferences = await SharedPreferences.getInstance();
    final local = LocalSettingsDataSource(preferences: preferences);
    final remote = MockRemoteSettingsDataSource();
    when(() => remote.fetch(userId: any(named: 'userId'))).thenThrow(
      Exception('offline'),
    );
    final repository = _repository(isar, local: local, remote: remote);

    final loaded = await repository.load();

    expect(loaded, const UserPreferences());
    final cached = await local.read();
    expect(cached, isNotNull);
    expect(cached!.lyricsFontScale, UserPreferences.defaultLyricsFontScale);
  });
}
