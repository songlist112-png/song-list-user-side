import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../app/theme/app_colors.dart';
import '../../domain/support_limits.dart';
import '../../domain/support_message.dart';
import '../providers/support_providers.dart';
import '../support_attachment_picker.dart';
import '../support_error_text.dart';
import '../widgets/support_attachment_preview.dart';
import '../widgets/support_page_surface.dart';

class CreateTicketPage extends ConsumerStatefulWidget {
  const CreateTicketPage({super.key});

  @override
  ConsumerState<CreateTicketPage> createState() => _CreateTicketPageState();
}

class _CreateTicketPageState extends ConsumerState<CreateTicketPage> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  SupportAttachmentDraft? _attachment;

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      await ref
          .read(supportMutationControllerProvider.notifier)
          .createTicket(
            subject: _subjectController.text,
            message: _messageController.text,
            attachment: _attachment,
          );
      if (!mounted) return;
      AppSnackbar.showSuccess(
        context,
        'Ticket saved. We will get back to you.',
      );
      context.go('/support/tickets');
    } on Exception catch (error) {
      if (mounted) _showError(error);
    }
  }

  void _showError(Object error) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(supportErrorText(error))));
  }

  @override
  Widget build(BuildContext context) {
    final isSubmitting = ref.watch(
      supportMutationControllerProvider.select((state) => state.isLoading),
    );
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(title: const Text('Create Ticket')),
      body: SupportPageSurface(
        child: SafeArea(
          top: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                  children: [
                    TextFormField(
                      controller: _subjectController,
                      enabled: !isSubmitting,
                      maxLength: SupportLimits.maximumSubjectLength,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Subject',
                        hintText: 'What do you need help with?',
                      ),
                      validator: _requiredValidator,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _messageController,
                      enabled: !isSubmitting,
                      minLines: 6,
                      maxLines: 10,
                      maxLength: SupportLimits.maximumMessageLength,
                      decoration: const InputDecoration(
                        labelText: 'Message',
                        hintText: 'Describe your question or feedback',
                        alignLabelWithHint: true,
                      ),
                      validator: _requiredValidator,
                    ),
                    const SizedBox(height: 12),
                    if (_attachment != null) ...[
                      SupportAttachmentPreview(
                        path: _attachment!.path,
                        name: _attachment!.name,
                        onRemove: isSubmitting
                            ? null
                            : () => setState(() => _attachment = null),
                      ),
                      const SizedBox(height: 12),
                    ],
                    OutlinedButton.icon(
                      onPressed: isSubmitting ? null : _pickImage,
                      icon: const Icon(Icons.add_photo_alternate_outlined),
                      label: Text(
                        _attachment == null
                            ? 'Attach Screenshot'
                            : 'Change Image',
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: isSubmitting ? null : _submit,
                      child: isSubmitting
                          ? const SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Submit'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static String? _requiredValidator(String? value) =>
      value == null || value.trim().isEmpty ? 'This field is required' : null;
}
