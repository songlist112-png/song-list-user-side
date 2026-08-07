import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../database/local/models/sync_queue.dart';

class SupportRemoteDataSource {
  SupportRemoteDataSource({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  static const bucketName = 'support-attachments';

  final SupabaseClient _client;

  Future<List<Map<String, dynamic>>> fetchTickets() async =>
      _rows(await _client.from('support_tickets').select().order('updated_at'));

  Future<List<Map<String, dynamic>>> fetchMessages() async => _rows(
    await _client.from('support_messages').select().order('created_at'),
  );

  Future<Uint8List> downloadAttachment(String storagePath) =>
      _client.storage.from(bucketName).download(storagePath);

  Future<void> apply(SyncQueue item) async {
    final payload = item.payload == null
        ? <String, dynamic>{}
        : (jsonDecode(item.payload!) as Map).cast<String, dynamic>();
    if (item.entityType == 'support_tickets') {
      await _applyTicket(item, payload);
      return;
    }
    if (item.entityType == 'support_messages') {
      await _applyMessage(item, payload);
      return;
    }
    throw ArgumentError.value(item.entityType, 'entityType');
  }

  Future<void> _applyTicket(
    SyncQueue item,
    Map<String, dynamic> payload,
  ) async {
    if (item.operation == 'close') {
      await _client.rpc<void>(
        'support_close_ticket',
        params: {'p_ticket_id': item.entityId},
      );
      return;
    }
    await _client
        .from('support_tickets')
        .upsert(
          {
            'id': payload['id'],
            'subject': payload['subject'],
            'created_at': payload['created_at'],
          },
          onConflict: 'id',
          ignoreDuplicates: true,
        );
  }

  Future<void> _applyMessage(
    SyncQueue item,
    Map<String, dynamic> payload,
  ) async {
    final attachmentPath = await _uploadAttachment(item, payload);
    await _client
        .from('support_messages')
        .upsert(
          {
            'id': payload['id'],
            'ticket_id': payload['ticket_id'],
            'body': payload['body'],
            'created_at': payload['created_at'],
            'attachment_path': attachmentPath,
            'attachment_name': payload['attachment_name'],
            'attachment_type': payload['attachment_type'],
            'attachment_size': payload['attachment_size'],
          },
          onConflict: 'id',
          ignoreDuplicates: true,
        );
  }

  Future<String?> _uploadAttachment(
    SyncQueue item,
    Map<String, dynamic> payload,
  ) async {
    final localPath = payload['attachment_local_path'] as String?;
    if (localPath == null) return null;
    final file = File(localPath);
    if (!await file.exists()) {
      throw FileSystemException('Support attachment not found', localPath);
    }
    final safeName = (payload['attachment_name'] as String? ?? 'image')
        .replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    final storagePath = '${item.userId}/${item.entityId}__$safeName';
    await _client.storage
        .from(bucketName)
        .upload(
          storagePath,
          file,
          fileOptions: FileOptions(
            contentType: payload['attachment_type'] as String?,
            upsert: true,
          ),
        );
    return storagePath;
  }

  static List<Map<String, dynamic>> _rows(Object? value) =>
      (value as List? ?? const [])
          .map((row) => (row as Map).cast<String, dynamic>())
          .toList(growable: false);
}
