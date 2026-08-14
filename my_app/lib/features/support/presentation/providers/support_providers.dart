import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/services/sync_service.dart';
import '../../../../database/isar_database.dart';
import '../../data/isar_support_repository.dart';
import '../../domain/support_message.dart';
import '../../domain/support_repository.dart';
import '../../domain/support_ticket.dart';

final supportRepositoryProvider = Provider<SupportRepository>((ref) {
  final syncService = ref.read(syncServiceProvider);
  return IsarSupportRepository(
    isar: IsarDatabase.instance,
    userId: () => Supabase.instance.client.auth.currentUser?.id,
    onSyncNeeded: syncService.synchronize,
  );
});

final supportTicketsProvider = StreamProvider.autoDispose<List<SupportTicket>>(
  (ref) => ref.watch(supportRepositoryProvider).watchTickets(),
);

final supportTicketProvider = StreamProvider.autoDispose
    .family<SupportTicket?, String>(
      (ref, ticketId) =>
          ref.watch(supportRepositoryProvider).watchTicket(ticketId),
    );

final supportMessagesProvider = StreamProvider.autoDispose
    .family<List<SupportMessage>, String>(
      (ref, ticketId) =>
          ref.watch(supportRepositoryProvider).watchMessages(ticketId),
    );

final supportMutationControllerProvider =
    StateNotifierProvider.autoDispose<
      SupportMutationController,
      AsyncValue<void>
    >((ref) => SupportMutationController(ref.watch(supportRepositoryProvider)));

class SupportMutationController extends StateNotifier<AsyncValue<void>> {
  SupportMutationController(this._repository)
    : super(const AsyncValue.data(null));

  final SupportRepository _repository;

  Future<String> createTicket({
    required String subject,
    required String message,
    SupportAttachmentDraft? attachment,
  }) => _run(
    () => _repository.createTicket(
      subject: subject,
      message: message,
      attachment: attachment,
    ),
  );

  Future<void> sendMessage({
    required String ticketId,
    required String message,
    SupportAttachmentDraft? attachment,
  }) => _run(
    () => _repository.sendMessage(
      ticketId: ticketId,
      message: message,
      attachment: attachment,
    ),
  );

  Future<void> closeTicket(String ticketId) =>
      _run(() => _repository.closeTicket(ticketId));

  Future<T> _run<T>(Future<T> Function() operation) async {
    if (state.isLoading) throw StateError('Operation already in progress');
    state = const AsyncValue.loading();
    try {
      final result = await operation();
      state = const AsyncValue.data(null);
      return result;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }
}
