import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../domain/support_ticket.dart';
import '../providers/support_providers.dart';
import '../widgets/pending_sync_badge.dart';
import '../widgets/support_page_surface.dart';

class MyTicketsPage extends ConsumerWidget {
  const MyTicketsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tickets = ref.watch(supportTicketsProvider);
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(title: const Text('My Tickets')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/support/new'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Ticket'),
      ),
      body: SupportPageSurface(
        child: tickets.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => _TicketsError(
            onRetry: () => ref.invalidate(supportTicketsProvider),
          ),
          data: (items) => RefreshIndicator(
            onRefresh: () => ref.read(supportRepositoryProvider).refresh(),
            child: items.isEmpty
                ? const _EmptyTickets()
                : ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 96),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) => _TicketTile(
                      ticket: items[index],
                      onTap: () =>
                          context.push('/support/tickets/${items[index].id}'),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _TicketTile extends StatelessWidget {
  const _TicketTile({required this.ticket, required this.onTap});

  final SupportTicket ticket;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    child: ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      title: Text(
        ticket.subject,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Wrap(
          spacing: 10,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (ticket.pendingSync)
              const PendingSyncBadge()
            else
              Text(ticket.status.label),
            Text('Updated ${formatSupportDate(ticket.updatedAt)}'),
          ],
        ),
      ),
      trailing: const Icon(Icons.chevron_right_rounded),
    ),
  );
}

class _EmptyTickets extends StatelessWidget {
  const _EmptyTickets();

  @override
  Widget build(BuildContext context) => ListView(
    physics: const AlwaysScrollableScrollPhysics(),
    padding: const EdgeInsets.symmetric(horizontal: 32),
    children: [
      const SizedBox(height: 150),
      Icon(
        Icons.inbox_outlined,
        size: 64,
        color: Theme.of(context).colorScheme.outline,
      ),
      const SizedBox(height: 16),
      Text(
        'No support tickets yet',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      const SizedBox(height: 8),
      const Text(
        'Pull down to refresh or create a ticket when you need help.',
        textAlign: TextAlign.center,
      ),
    ],
  );
}

class _TicketsError extends StatelessWidget {
  const _TicketsError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Could not load tickets'),
        const SizedBox(height: 8),
        OutlinedButton(onPressed: onRetry, child: const Text('Try Again')),
      ],
    ),
  );
}

String formatSupportDate(DateTime value) {
  final local = value.toLocal();
  String two(int number) => number.toString().padLeft(2, '0');
  return '${local.year}-${two(local.month)}-${two(local.day)} '
      '${two(local.hour)}:${two(local.minute)}';
}
