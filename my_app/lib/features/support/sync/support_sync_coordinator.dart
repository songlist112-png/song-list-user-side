import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../../../database/local/models/sync_queue.dart';
import '../data/models/support_records.dart';
import 'support_remote_data_source.dart';

class SupportSyncCoordinator {
  SupportSyncCoordinator({required Isar isar, SupportRemoteDataSource? remote})
    : // Public constructor keeps conventional `isar` name.
      // ignore: prefer_initializing_formals
      _isar = isar,
      _remote = remote ?? SupportRemoteDataSource();

  final Isar _isar;
  final SupportRemoteDataSource _remote;

  bool handles(SyncQueue item) =>
      item.entityType == 'support_tickets' ||
      item.entityType == 'support_messages';

  Future<void> apply(SyncQueue item) => _remote.apply(item);

  Future<void> pull(String userId) async {
    final pending = await _pendingSupportItems(userId);
    final pendingMessageIds = pending
        .where((item) => item.entityType == 'support_messages')
        .map((item) => item.entityId)
        .toSet();
    final dirtyTicketIds = pending
        .map(_ticketIdFromQueue)
        .whereType<String>()
        .toSet();
    final results = await Future.wait([
      _remote.fetchTickets(),
      _remote.fetchMessages(),
    ]);

    await _mergeTickets(userId, results[0], dirtyTicketIds);
    await _mergeMessages(userId, results[1], pendingMessageIds);
    await reconcilePending(userId);
  }

  Future<void> reconcilePending(String userId) async {
    final pending = await _pendingSupportItems(userId);
    final pendingMessageIds = pending
        .where((item) => item.entityType == 'support_messages')
        .map((item) => item.entityId)
        .toSet();
    final dirtyTicketIds = pending
        .map(_ticketIdFromQueue)
        .whereType<String>()
        .toSet();
    final tickets = await _isar.supportTicketRecords
        .filter()
        .userIdEqualTo(userId)
        .findAll();
    final messages = await _isar.supportMessageRecords
        .filter()
        .userIdEqualTo(userId)
        .findAll();
    await _isar.writeTxn(() async {
      for (final ticket in tickets) {
        ticket.pendingSync = dirtyTicketIds.contains(ticket.uuid);
      }
      for (final message in messages) {
        message.pendingSync = pendingMessageIds.contains(message.uuid);
      }
      await _isar.supportTicketRecords.putAll(tickets);
      await _isar.supportMessageRecords.putAll(messages);
    });
  }

  Future<void> _mergeTickets(
    String userId,
    List<Map<String, dynamic>> rows,
    Set<String> dirtyTicketIds,
  ) async {
    final records = <SupportTicketRecord>[];
    for (final row in rows.where((row) => row['user_id'] == userId)) {
      final uuid = row['id'] as String;
      if (dirtyTicketIds.contains(uuid)) continue;
      final existing = await _isar.supportTicketRecords
          .filter()
          .uuidEqualTo(uuid)
          .findFirst();
      records.add(
        (existing ?? SupportTicketRecord())
          ..uuid = uuid
          ..userId = userId
          ..subject = row['subject'] as String
          ..status = row['status'] as String
          ..createdAt = DateTime.parse(row['created_at'] as String).toUtc()
          ..updatedAt = DateTime.parse(row['updated_at'] as String).toUtc()
          ..pendingSync = false,
      );
    }
    if (records.isNotEmpty) {
      await _isar.writeTxn(() => _isar.supportTicketRecords.putAll(records));
    }
  }

  Future<void> _mergeMessages(
    String userId,
    List<Map<String, dynamic>> rows,
    Set<String> pendingMessageIds,
  ) async {
    final records = <SupportMessageRecord>[];
    for (final row in rows) {
      final uuid = row['id'] as String;
      if (pendingMessageIds.contains(uuid)) continue;
      final existing = await _isar.supportMessageRecords
          .filter()
          .uuidEqualTo(uuid)
          .findFirst();
      final remotePath = row['attachment_path'] as String?;
      final localPath = await _cacheAttachment(
        uuid: uuid,
        remotePath: remotePath,
        existingPath: existing?.attachmentLocalPath,
        attachmentName: row['attachment_name'] as String?,
      );
      records.add(
        (existing ?? SupportMessageRecord())
          ..uuid = uuid
          ..ticketId = row['ticket_id'] as String
          ..userId = userId
          ..body = row['body'] as String
          ..isFromSupport = row['sender_role'] == 'support'
          ..createdAt = DateTime.parse(row['created_at'] as String).toUtc()
          ..pendingSync = false
          ..attachmentLocalPath = localPath
          ..attachmentRemotePath = remotePath
          ..attachmentName = row['attachment_name'] as String?
          ..attachmentType = row['attachment_type'] as String?
          ..attachmentSize = (row['attachment_size'] as num?)?.toInt(),
      );
    }
    if (records.isNotEmpty) {
      await _isar.writeTxn(() => _isar.supportMessageRecords.putAll(records));
    }
  }

  Future<String?> _cacheAttachment({
    required String uuid,
    required String? remotePath,
    required String? existingPath,
    required String? attachmentName,
  }) async {
    if (existingPath != null && await File(existingPath).exists()) {
      return existingPath;
    }
    if (remotePath == null) return null;
    try {
      final bytes = await _remote.downloadAttachment(remotePath);
      final root = await getApplicationSupportDirectory();
      final directory = Directory(
        '${root.path}${Platform.pathSeparator}support_attachments',
      );
      await directory.create(recursive: true);
      final extension = _safeExtension(attachmentName);
      final file = File(
        '${directory.path}${Platform.pathSeparator}$uuid$extension',
      );
      final temporary = File('${file.path}.part');
      await temporary.writeAsBytes(bytes, flush: true);
      if (await file.exists()) await file.delete();
      await temporary.rename(file.path);
      return file.path;
    } on Exception catch (error) {
      debugPrint('Support attachment cache failed: $error');
      return null;
    }
  }

  Future<List<SyncQueue>> _pendingSupportItems(String userId) => _isar
      .syncQueues
      .filter()
      .userIdEqualTo(userId)
      .and()
      .statusEqualTo('pending')
      .findAll()
      .then((items) => items.where(handles).toList(growable: false));

  static String? _ticketIdFromQueue(SyncQueue item) {
    if (item.entityType == 'support_tickets') return item.entityId;
    if (item.entityType != 'support_messages' || item.payload == null) {
      return null;
    }
    final payload = jsonDecode(item.payload!) as Map<String, dynamic>;
    return payload['ticket_id'] as String?;
  }

  static String _safeExtension(String? name) {
    if (name == null || !name.contains('.')) return '.img';
    final extension = '.${name.split('.').last.toLowerCase()}';
    return const {'.jpg', '.jpeg', '.png', '.webp'}.contains(extension)
        ? extension
        : '.img';
  }
}
