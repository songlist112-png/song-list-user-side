import 'package:isar_community/isar.dart';

part 'support_records.g.dart';

@collection
class SupportTicketRecord {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String uuid;

  @Index()
  late String userId;

  late String subject;
  late String status;
  late DateTime createdAt;
  late DateTime updatedAt;
  bool pendingSync = true;
}

@collection
class SupportMessageRecord {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String uuid;

  @Index()
  late String ticketId;

  @Index()
  late String userId;

  late String body;
  bool isFromSupport = false;
  late DateTime createdAt;
  bool pendingSync = true;
  String? attachmentLocalPath;
  String? attachmentRemotePath;
  String? attachmentName;
  String? attachmentType;
  int? attachmentSize;
}
