import 'package:flutter/material.dart';

/// Prevents native selection and clipboard actions in read-only lyrics views.
class ProtectedLyricsText extends StatelessWidget {
  const ProtectedLyricsText({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SelectionContainer.disabled(child: child);
  }
}
