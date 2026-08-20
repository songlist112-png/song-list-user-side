import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:my_app/database/local/models/sync_queue.dart';
import 'package:my_app/features/support/data/isar_support_repository.dart';
import 'package:my_app/features/support/data/models/support_records.dart';
import 'package:my_app/features/support/domain/support_message.dart';

void main() {
  late Directory root;
  late Directory attachmentDirectory;
  late Isar isar;
  var syncRequests = 0;

  setUpAll(_initializeIsarCore);
  setUp(() async {
    root = await Directory.systemTemp.createTemp('support-repository-');
    final databaseDirectory = Directory('${root.path}/database');
    attachmentDirectory = Directory('${root.path}/attachments');
    await databaseDirectory.create();
    isar = await Isar.open(
      [SupportTicketRecordSchema, SupportMessageRecordSchema, SyncQueueSchema],
      directory: databaseDirectory.path,
      name: 'support_${DateTime.now().microsecondsSinceEpoch}',
    );
    syncRequests = 0;
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
    if (await root.exists()) await root.delete(recursive: true);
  });

  IsarSupportRepository repository() => IsarSupportRepository(
    isar: isar,
    userId: () => 'user-one',
    onSyncNeeded: () async => syncRequests++,
    attachmentDirectory: () async => attachmentDirectory,
  );

  test(
    'creates ticket and first message locally before requesting sync',
    () async {
      final ticketId = await repository().createTicket(
        subject: '  Playback issue  ',
        message: '  Songs stop early  ',
      );

      final tickets = await isar.supportTicketRecords.where().findAll();
      final messages = await isar.supportMessageRecords.where().findAll();
      final queue = await isar.syncQueues.where().findAll();
      expect(tickets.single.uuid, ticketId);
      expect(tickets.single.subject, 'Playback issue');
      expect(tickets.single.pendingSync, isTrue);
      expect(messages.single.body, 'Songs stop early');
      expect(queue.map((item) => item.entityType), {
        'support_tickets',
        'support_messages',
      });
      expect(syncRequests, 1);
    },
  );

  test('adds optimistic reply and queues stable message payload', () async {
    final supportRepository = repository();
    final ticketId = await supportRepository.createTicket(
      subject: 'Question',
      message: 'Initial message',
    );

    await supportRepository.sendMessage(
      ticketId: ticketId,
      message: 'Additional details',
    );

    final messages = await isar.supportMessageRecords.where().findAll();
    final queue = await isar.syncQueues
        .filter()
        .entityTypeEqualTo('support_messages')
        .findAll();
    expect(messages, hasLength(2));
    expect(messages.last.body, 'Additional details');
    expect(jsonDecode(queue.last.payload!)['ticket_id'], ticketId);
    expect(syncRequests, 2);
  });

  test('closes locally and queues only allowed status transition', () async {
    final supportRepository = repository();
    final ticketId = await supportRepository.createTicket(
      subject: 'Resolved issue',
      message: 'Everything works now',
    );

    await supportRepository.closeTicket(ticketId);

    final ticket = (await isar.supportTicketRecords.where().findAll()).single;
    final closeItem =
        (await isar.syncQueues.filter().operationEqualTo('close').findAll())
            .single;
    expect(ticket.status, 'closed');
    expect(ticket.pendingSync, isTrue);
    expect(closeItem.entityId, ticketId);
  });

  test('copies selected image into durable app-owned storage', () async {
    final source = File('${root.path}/picked.png');
    await source.writeAsBytes([137, 80, 78, 71]);

    await repository().createTicket(
      subject: 'Screenshot',
      message: 'See attached image',
      attachment: SupportAttachmentDraft(
        path: source.path,
        name: 'screen.png',
        mediaType: 'image/png',
        size: await source.length(),
      ),
    );

    final message = (await isar.supportMessageRecords.where().findAll()).single;
    expect(message.attachmentLocalPath, isNot(source.path));
    expect(await File(message.attachmentLocalPath!).exists(), isTrue);
  });

  test('rejects empty fields and unsupported attachment types', () async {
    expect(
      () => repository().createTicket(subject: ' ', message: 'Message'),
      throwsArgumentError,
    );
    expect(
      () => repository().createTicket(
        subject: 'Subject',
        message: 'Message',
        attachment: const SupportAttachmentDraft(
          path: 'document.pdf',
          name: 'document.pdf',
          mediaType: 'application/pdf',
          size: 100,
        ),
      ),
      throwsArgumentError,
    );
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
