enum SupportTicketStatus {
  open('Open'),
  waitingForReply('Waiting for Reply'),
  resolved('Resolved'),
  closed('Closed');

  const SupportTicketStatus(this.label);

  final String label;

  static SupportTicketStatus fromStorage(String value) => switch (value) {
    'waiting_for_reply' => waitingForReply,
    'resolved' => resolved,
    'closed' => closed,
    _ => open,
  };

  String get storageValue => switch (this) {
    open => 'open',
    waitingForReply => 'waiting_for_reply',
    resolved => 'resolved',
    closed => 'closed',
  };
}

class SupportTicket {
  const SupportTicket({
    required this.id,
    required this.subject,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.pendingSync,
  });

  final String id;
  final String subject;
  final SupportTicketStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool pendingSync;

  bool get canClose => status != SupportTicketStatus.closed;

  String get displayStatus => pendingSync ? 'Pending Sync' : status.label;
}
