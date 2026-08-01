import 'dart:math' as math;

import 'package:flutter/material.dart';

class AppSnackbar {
  AppSnackbar._();

  static const _maximumWidth = 420.0;

  static void showSuccess(BuildContext context, String message) {
    final messenger = ScaffoldMessenger.of(context);
    final availableWidth = MediaQuery.sizeOf(context).width - 32;

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: _SnackbarContent(message: message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          elevation: 0,
          padding: EdgeInsets.zero,
          width: math.min(_maximumWidth, availableWidth),
          duration: const Duration(seconds: 3),
        ),
      );
  }
}

class _SnackbarContent extends StatelessWidget {
  const _SnackbarContent({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFBFA),
        border: Border.all(color: const Color(0xFFEAEAEA)),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFEDF3EC),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.check_rounded,
              size: 18,
              color: Color(0xFF346538),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFF2F3437),
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () =>
                ScaffoldMessenger.of(context).hideCurrentSnackBar(),
            icon: const Icon(Icons.close_rounded, size: 18),
            color: const Color(0xFF787774),
            tooltip: 'Dismiss notification',
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}
