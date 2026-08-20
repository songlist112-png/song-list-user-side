import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../../database/local/models/sync_queue.dart';
import '../domain/support_limits.dart';
import '../domain/support_message.dart';
import '../domain/support_repository.dart';
import '../domain/support_ticket.dart';
import 'models/support_records.dart';

class IsarSupportRepository implements SupportRepository {
  IsarSupportRepository({
    required Isar isar,
    required this.userId,
    required this.onSyncNeeded,
    Future<Directory> Function()? attachmentDirectory,
  }) : // Public constructor keeps conventional `isar` name.
       // ignore: prefer_initializing_formals
       _isar = isar,
       _attachmentDirectory = attachmentDirectory ?? _defaultDirectory;

  final Isar _isar;
  final String? Function() userId;
  final Future<void> Function() onSyncNeeded;
  final Future<Directory> Function() _attachmentDirectory;
  final Uuid _uuid = const Uuid();

  String get _requiredUserId =>
      userId() ?? (throw StateError('Authentication required'));

  @override
  Stream<List<SupportTicket>> watchTickets() => _isar.supportTicketRecords
      .filter()
      .userIdEqualTo(_requiredUserId)
      .watch(fireImmediately: true)
      .map((records) {
        final tickets = records.map(_ticketFromRecord).toList();
        tickets.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        return tickets;
      });

  @override
  Stream<SupportTicket?> watchTicket(String ticketId) => _isar
      .supportTicketRecords
      .filter()
      .uuidEqualTo(ticketId)
      .and()
      .userIdEqualTo(_requiredUserId)
      .watch(fireImmediately: true)
      .map(
        (records) => records.isEmpty ? null : _ticketFromRecord(records.first),
      );

  @override
  Stream<List<SupportMessage>> watchMessages(String ticketId) => _isar
      .supportMessageRecords
      .filter()
      .ticketIdEqualTo(ticketId)
      .and()
      .userIdEqualTo(_requiredUserId)
      .watch(fireImmediately: true)
      .map((records) {
        final messages = records.map(_messageFromRecord).toList();
        messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        return messages;
      });

  @override
  Future<String> createTicket({
    required String subject,
    required String message,
    SupportAttachmentDraft? attachment,
  }) async {
    final normalizedSubject = _requiredText(
      subject,
      field: 'Subject',
      maximumLength: SupportLimits.maximumSubjectLength,
    );
    final normalizedMessage = _requiredText(
      message,
      field: 'Message',
      maximumLength: SupportLimits.maximumMessageLength,
    );
    final ownerId = _requiredUserId;
    final ticketId = _uuid.v4();
    final messageId = _uuid.v4();
    final now = DateTime.now().toUtc();
    final storedAttachment = await _storeAttachment(attachment, messageId);
    final ticket = SupportTicketRecord()
      ..uuid = ticketId
      ..userId = ownerId
      ..subject = normalizedSubject
      ..status = SupportTicketStatus.open.storageValue
      ..createdAt = now
      ..updatedAt = now;
    final firstMessage = _newMessageRecord(
      id: messageId,
      ticketId: ticketId,
      userId: ownerId,
      message: normalizedMessage,
      createdAt: now,
      attachment: storedAttachment,
    );

    await _isar.writeTxn(() async {
      await _isar.supportTicketRecords.put(ticket);
      await _isar.supportMessageRecords.put(firstMessage);
      await _isar.syncQueues.putAll([
        _queueTicket(ticket),
        _queueMessage(firstMessage),
      ]);
    });
    unawaited(onSyncNeeded());
    return ticketId;
  }

  @override
  Future<void> sendMessage({
    required String ticketId,
    required String message,
    SupportAttachmentDraft? attachment,
  }) async {
    final normalizedMessage = _requiredText(
      message,
      field: 'Message',
      maximumLength: SupportLimits.maximumMessageLength,
    );
    final ownerId = _requiredUserId;
    final ticket = await _ownedTicket(ticketId, ownerId);
    if (ticket.status == SupportTicketStatus.closed.storageValue) {
      throw StateError('Closed tickets cannot receive new messages');
    }
    final messageId = _uuid.v4();
    final now = DateTime.now().toUtc();
    final storedAttachment = await _storeAttachment(attachment, messageId);
    final record = _newMessageRecord(
      id: messageId,
      ticketId: ticketId,
      userId: ownerId,
      message: normalizedMessage,
      createdAt: now,
      attachment: storedAttachment,
    );
    ticket
      ..updatedAt = now
      ..pendingSync = true;
    await _isar.writeTxn(() async {
      await _isar.supportMessageRecords.put(record);
      await _isar.supportTicketRecords.put(ticket);
      await _isar.syncQueues.put(_queueMessage(record));
    });
    unawaited(onSyncNeeded());
  }

  @override
  Future<void> closeTicket(String ticketId) async {
    final ownerId = _requiredUserId;
    final ticket = await _ownedTicket(ticketId, ownerId);
    if (ticket.status == SupportTicketStatus.closed.storageValue) return;
    final now = DateTime.now().toUtc();
    ticket
      ..status = SupportTicketStatus.closed.storageValue
      ..updatedAt = now
      ..pendingSync = true;
    await _isar.writeTxn(() async {
      await _isar.supportTicketRecords.put(ticket);
      await _isar.syncQueues.put(
        SyncQueue()
          ..entityType = 'support_tickets'
          ..entityId = ticketId
          ..operation = 'close'
          ..payload = jsonEncode({'id': ticketId})
          ..status = 'pending'
          ..createdAt = now
          ..userId = ownerId,
      );
    });
    unawaited(onSyncNeeded());
  }

  @override
  Future<void> refresh() => onSyncNeeded();

  Future<SupportTicketRecord> _ownedTicket(
    String ticketId,
    String ownerId,
  ) async {
    final ticket = await _isar.supportTicketRecords
        .filter()
        .uuidEqualTo(ticketId)
        .and()
        .userIdEqualTo(ownerId)
        .findFirst();
    return ticket ?? (throw StateError('Ticket not found'));
  }

  SupportMessageRecord _newMessageRecord({
    required String id,
    required String ticketId,
    required String userId,
    required String message,
    required DateTime createdAt,
    required SupportAttachmentDraft? attachment,
  }) => SupportMessageRecord()
    ..uuid = id
    ..ticketId = ticketId
    ..userId = userId
    ..body = message
    ..createdAt = createdAt
    ..attachmentLocalPath = attachment?.path
    ..attachmentName = attachment?.name
    ..attachmentType = attachment?.mediaType
    ..attachmentSize = attachment?.size;

  SyncQueue _queueTicket(SupportTicketRecord ticket) => SyncQueue()
    ..entityType = 'support_tickets'
    ..entityId = ticket.uuid
    ..operation = 'insert'
    ..payload = jsonEncode({
      'id': ticket.uuid,
      'subject': ticket.subject,
      'created_at': ticket.createdAt.toIso8601String(),
    })
    ..status = 'pending'
    ..createdAt = ticket.createdAt
    ..userId = ticket.userId;

  SyncQueue _queueMessage(SupportMessageRecord message) => SyncQueue()
    ..entityType = 'support_messages'
    ..entityId = message.uuid
    ..operation = 'insert'
    ..payload = jsonEncode({
      'id': message.uuid,
      'ticket_id': message.ticketId,
      'body': message.body,
      'created_at': message.createdAt.toIso8601String(),
      'attachment_local_path': message.attachmentLocalPath,
      'attachment_name': message.attachmentName,
      'attachment_type': message.attachmentType,
      'attachment_size': message.attachmentSize,
    })
    ..status = 'pending'
    ..createdAt = message.createdAt
    ..userId = message.userId;

  Future<SupportAttachmentDraft?> _storeAttachment(
    SupportAttachmentDraft? attachment,
    String messageId,
  ) async {
    if (attachment == null) return null;
    _validateAttachment(attachment);
    final source = File(attachment.path);
    if (!await source.exists()) throw StateError('Attachment file not found');
    final directory = await _attachmentDirectory();
    await directory.create(recursive: true);
    final extension = attachment.name.contains('.')
        ? '.${attachment.name.split('.').last.toLowerCase()}'
        : '.img';
    final target = File(
      '${directory.path}${Platform.pathSeparator}$messageId$extension',
    );
    await source.copy(target.path);
    return SupportAttachmentDraft(
      path: target.path,
      name: attachment.name,
      mediaType: attachment.mediaType,
      size: attachment.size,
    );
  }

  static void _validateAttachment(SupportAttachmentDraft attachment) {
    if (!SupportLimits.allowedAttachmentTypes.contains(attachment.mediaType)) {
      throw ArgumentError('Only JPEG, PNG, and WebP images are supported');
    }
    if (attachment.size <= 0 ||
        attachment.size > SupportLimits.maximumAttachmentBytes) {
      throw ArgumentError('Image must be 10 MB or smaller');
    }
  }

  static String _requiredText(
    String value, {
    required String field,
    required int maximumLength,
  }) {
    final normalized = value.trim();
    if (normalized.isEmpty) throw ArgumentError('$field is required');
    if (normalized.length > maximumLength) {
      throw ArgumentError('$field exceeds $maximumLength characters');
    }
    return normalized;
  }

  static Future<Directory> _defaultDirectory() async {
    final root = await getApplicationSupportDirectory();
    return Directory(
      '${root.path}${Platform.pathSeparator}support_attachments',
    );
  }

  static SupportTicket _ticketFromRecord(SupportTicketRecord record) =>
      SupportTicket(
        id: record.uuid,
        subject: record.subject,
        status: SupportTicketStatus.fromStorage(record.status),
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        pendingSync: record.pendingSync,
      );

  static SupportMessage _messageFromRecord(SupportMessageRecord record) =>
      SupportMessage(
        id: record.uuid,
        ticketId: record.ticketId,
        body: record.body,
        isFromSupport: record.isFromSupport,
        createdAt: record.createdAt,
        pendingSync: record.pendingSync,
        attachmentLocalPath: record.attachmentLocalPath,
        attachmentRemotePath: record.attachmentRemotePath,
        attachmentName: record.attachmentName,
        attachmentType: record.attachmentType,
        attachmentSize: record.attachmentSize,
      );
}
