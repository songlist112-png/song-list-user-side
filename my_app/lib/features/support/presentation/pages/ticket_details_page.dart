import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../domain/support_limits.dart';
import '../../domain/support_message.dart';
import '../../domain/support_ticket.dart';
import '../providers/support_providers.dart';
import '../support_attachment_picker.dart';
import '../support_error_text.dart';
import '../widgets/pending_sync_badge.dart';
import '../widgets/support_attachment_preview.dart';
import '../widgets/support_page_surface.dart';
import 'my_tickets_page.dart';

class TicketDetailsPage extends ConsumerStatefulWidget {
  const TicketDetailsPage({required this.ticketId, super.key});

  final String ticketId;

  @override
  ConsumerState<TicketDetailsPage> createState() => _TicketDetailsPageState();
}

class _TicketDetailsPageState extends ConsumerState<TicketDetailsPage> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  SupportAttachmentDraft? _attachment;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final attachment = await SupportAttachmentPicker.pickImage();
      if (mounted && attachment != null) {
        setState(() => _attachment = attachment);
      }
    } on Exception catch (error) {
      if (mounted) _showError(error);
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) {
      _showError(ArgumentError('Message is required'));
      return;
    }
    try {
      await ref
          .read(supportMutationControllerProvider.notifier)
          .sendMessage(
            ticketId: widget.ticketId,
            message: _messageController.text,
            attachment: _attachment,
          );
      if (!mounted) return;
      _messageController.clear();
      setState(() => _attachment = null);
      _scrollToEnd();
    } on Exception catch (error) {
      if (mounted) _showError(error);
    }
  }

  // Future<void> _confirmClose() async {
  //   final confirmed = await showDialog<bool>(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('Close this ticket?'),
  //       content: const Text(
  //         'Close the ticket only if your issue is resolved. You will not be '
  //         'able to send more messages.',
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context, false),
  //           child: const Text('Cancel'),
  //         ),
  //         FilledButton(
  //           onPressed: () => Navigator.pop(context, true),
  //           child: const Text('Close Ticket'),
  //         ),
  //       ],
  //     ),
  //   );
  //   if (confirmed != true || !mounted) return;
  //   try {
  //     await ref
  //         .read(supportMutationControllerProvider.notifier)
  //         .closeTicket(widget.ticketId);
  //     if (mounted) AppSnackbar.showSuccess(context, 'Ticket closed locally');
  //   } on Exception catch (error) {
  //     if (mounted) _showError(error);
  //   }
  // }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  void _showError(Object error) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(supportErrorText(error))));
  }

  @override
  Widget build(BuildContext context) {
    final ticketState = ref.watch(supportTicketProvider(widget.ticketId));
    final messagesState = ref.watch(supportMessagesProvider(widget.ticketId));
    final isSubmitting = ref.watch(
      supportMutationControllerProvider.select((state) => state.isLoading),
    );
    // final ticket = ticketState.asData?.value;
    ref.listen(supportMessagesProvider(widget.ticketId), (_, next) {
      if (next.hasValue) _scrollToEnd();
    });

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: const Text('Ticket Details'),
        // actions: [
        //   if (ticket?.canClose == true)
        //     IconButton(
        //       onPressed: isSubmitting ? null : _confirmClose,
        //       tooltip: 'Close ticket',
        //       icon: const Icon(Icons.check_circle_outline_rounded),
        //     ),
        // ],
      ),
      body: SupportPageSurface(
        child: ticketState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => const Center(child: Text('Could not load ticket')),
          data: (value) {
            if (value == null) {
              return const Center(child: Text('Ticket not found'));
            }
            return Column(
              children: [
                _TicketSummary(ticket: value),
                Expanded(
                  child: messagesState.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (_, _) => const Center(
                      child: Text('Could not load conversation'),
                    ),
                    data: (messages) => RefreshIndicator(
                      onRefresh: () =>
                          ref.read(supportRepositoryProvider).refresh(),
                      child: _ConversationList(
                        controller: _scrollController,
                        messages: messages,
                      ),
                    ),
                  ),
                ),
                _MessageComposer(
                  controller: _messageController,
                  attachment: _attachment,
                  enabled: value.status != SupportTicketStatus.closed,
                  isSubmitting: isSubmitting,
                  onPickImage: _pickImage,
                  onRemoveImage: () => setState(() => _attachment = null),
                  onSend: _sendMessage,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _TicketSummary extends StatelessWidget {
  const _TicketSummary({required this.ticket});

  final SupportTicket ticket;

  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.bgDark,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ticket.subject,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Updated ${formatSupportDate(ticket.updatedAt)}',
                  style: const TextStyle(color: Color(0xFFD8E8F5)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (ticket.pendingSync)
            const PendingSyncBadge()
          else
            Chip(
              label: Text(
                ticket.status.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              backgroundColor: switch (ticket.status) {
                SupportTicketStatus.open => Colors.blue,
                SupportTicketStatus.waitingForReply => Colors.orange,
                SupportTicketStatus.resolved => Colors.green,
                SupportTicketStatus.closed => Colors.grey,
              },
              side: BorderSide.none,
              visualDensity: VisualDensity.compact,
            ),
        ],
      ),
    ),
  );
}

class _ConversationList extends StatelessWidget {
  const _ConversationList({required this.controller, required this.messages});

  final ScrollController controller;
  final List<SupportMessage> messages;

  @override
  Widget build(BuildContext context) => ListView.builder(
    controller: controller,
    physics: const AlwaysScrollableScrollPhysics(),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
    itemCount: messages.length,
    itemBuilder: (context, index) => _MessageBubble(message: messages[index]),
  );
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final SupportMessage message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final localPath = message.attachmentLocalPath;
    return Align(
      alignment: message.isFromSupport
          ? Alignment.centerLeft
          : Alignment.centerRight,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 440),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: message.isFromSupport
              ? colors.surfaceContainerHighest
              : colors.primaryContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.isFromSupport ? 'Support' : 'You',
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(message.body),
            if (localPath != null) ...[
              const SizedBox(height: 10),
              SupportAttachmentPreview(
                path: localPath,
                name: message.attachmentName ?? 'Attachment',
              ),
            ] else if (message.attachmentRemotePath != null) ...[
              const SizedBox(height: 10),
              const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cloud_download_outlined, size: 18),
                  SizedBox(width: 6),
                  Flexible(child: Text('Image will download during sync')),
                ],
              ),
            ],
            const SizedBox(height: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  formatSupportDate(message.createdAt),
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                if (message.pendingSync) ...[
                  const SizedBox(width: 8),
                  const PendingSyncBadge(),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageComposer extends StatelessWidget {
  const _MessageComposer({
    required this.controller,
    required this.attachment,
    required this.enabled,
    required this.isSubmitting,
    required this.onPickImage,
    required this.onRemoveImage,
    required this.onSend,
  });

  final TextEditingController controller;
  final SupportAttachmentDraft? attachment;
  final bool enabled;
  final bool isSubmitting;
  final VoidCallback onPickImage;
  final VoidCallback onRemoveImage;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Material(
      elevation: 8,
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (attachment != null) ...[
              SupportAttachmentPreview(
                path: attachment!.path,
                name: attachment!.name,
                height: 80,
                onRemove: isSubmitting ? null : onRemoveImage,
              ),
              const SizedBox(height: 8),
            ],
            if (!enabled)
              const Padding(
                padding: EdgeInsets.all(8),
                child: Text('This ticket is closed.'),
              )
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: isSubmitting ? null : onPickImage,
                    tooltip: 'Attach image',
                    icon: const Icon(Icons.add_photo_alternate_outlined),
                  ),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      enabled: !isSubmitting,
                      minLines: 1,
                      maxLines: 4,
                      maxLength: SupportLimits.maximumMessageLength,
                      decoration: const InputDecoration(
                        hintText: 'Write a message',
                        counterText: '',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: isSubmitting ? null : onSend,
                    tooltip: 'Send message',
                    icon: isSubmitting
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send_rounded),
                  ),
                ],
              ),
          ],
        ),
      ),
    ),
  );
}
