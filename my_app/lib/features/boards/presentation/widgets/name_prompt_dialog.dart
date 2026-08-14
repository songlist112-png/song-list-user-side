import 'package:flutter/material.dart';

Future<String?> showNamePrompt(
  BuildContext context, {
  required String title,
  String initialValue = '',
  String label = 'Name',
  String actionLabel = 'Save',
}) {
  return showDialog<String>(
    context: context,
    builder: (_) => _NamePromptDialog(
      title: title,
      initialValue: initialValue,
      label: label,
      actionLabel: actionLabel,
    ),
  );
}

class _NamePromptDialog extends StatefulWidget {
  const _NamePromptDialog({
    required this.title,
    required this.initialValue,
    required this.label,
    required this.actionLabel,
  });

  final String title;
  final String initialValue;
  final String label;
  final String actionLabel;

  @override
  State<_NamePromptDialog> createState() => _NamePromptDialogState();
}

class _NamePromptDialogState extends State<_NamePromptDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _controller.text.trim();
    if (name.isNotEmpty) Navigator.pop(context, name);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: 120,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(labelText: widget.label),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: Text(widget.actionLabel)),
      ],
    );
  }
}
