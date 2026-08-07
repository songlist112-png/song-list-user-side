class SupportMessage {
  const SupportMessage({
    required this.id,
    required this.ticketId,
    required this.body,
    required this.isFromSupport,
    required this.createdAt,
    required this.pendingSync,
    this.attachmentLocalPath,
    this.attachmentRemotePath,
    this.attachmentName,
    this.attachmentType,
    this.attachmentSize,
  });

  final String id;
  final String ticketId;
  final String body;
  final bool isFromSupport;
  final DateTime createdAt;
  final bool pendingSync;
  final String? attachmentLocalPath;
  final String? attachmentRemotePath;
  final String? attachmentName;
  final String? attachmentType;
  final int? attachmentSize;

  bool get hasAttachment =>
      attachmentLocalPath != null || attachmentRemotePath != null;
}

class SupportAttachmentDraft {
  const SupportAttachmentDraft({
    required this.path,
    required this.name,
    required this.mediaType,
    required this.size,
  });

  final String path;
  final String name;
  final String mediaType;
  final int size;
}
