import 'support_message.dart';
import 'support_ticket.dart';

abstract interface class SupportRepository {
  Stream<List<SupportTicket>> watchTickets();
  Stream<SupportTicket?> watchTicket(String ticketId);
  Stream<List<SupportMessage>> watchMessages(String ticketId);

  Future<String> createTicket({
    required String subject,
    required String message,
    SupportAttachmentDraft? attachment,
  });

  Future<void> sendMessage({
    required String ticketId,
    required String message,
    SupportAttachmentDraft? attachment,
  });

  Future<void> closeTicket(String ticketId);
  Future<void> refresh();
}
