import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/env.dart';

enum SubscriptionProblem { expired, internetRequired, serviceUnavailable }

class SubscriptionModal extends StatefulWidget {
  const SubscriptionModal({
    required this.problem,
    required this.onRetry,
    required this.onSignOut,
    super.key,
  });

  final SubscriptionProblem problem;
  final Future<void> Function() onRetry;
  final Future<void> Function() onSignOut;

  @override
  State<SubscriptionModal> createState() => _SubscriptionModalState();
}

class _SubscriptionModalState extends State<SubscriptionModal> {
  bool _isOpening = false;

  Future<void> _subscribe() async {
    setState(() => _isOpening = true);
    try {
      final opened = await launchUrl(
        Uri.parse(Env.subscriptionPortalUrl),
        mode: LaunchMode.externalApplication,
      );
      if (!opened) throw const FormatException('Portal could not be opened');
    } on Exception {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open subscription page')),
        );
      }
    } finally {
      if (mounted) setState(() => _isOpening = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = _ModalContent.forProblem(widget.problem);

    return Material(
      color: Colors.transparent,
      child: Container(
        width: 420,
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [
            BoxShadow(
              color: Color(0x55000000),
              blurRadius: 40,
              offset: Offset(0, 18),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/app-logo.png',
              width: 50,
              height: 50,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 22),
            Text(
              content.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 26,
                height: 1.1,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.7,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              content.message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 15,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            if (widget.problem == SubscriptionProblem.expired)
              _SubscribeButton(isLoading: _isOpening, onPressed: _subscribe),
            if (widget.problem == SubscriptionProblem.expired)
              const SizedBox(height: 10),
            TextButton.icon(
              onPressed: () => unawaited(widget.onRetry()),
              icon: const Icon(Icons.refresh_rounded, size: 19),
              label: Text(
                widget.problem == SubscriptionProblem.expired
                    ? 'I already subscribed'
                    : 'Try again',
              ),
            ),
            const SizedBox(height: 4),
            TextButton.icon(
              onPressed: () => unawaited(widget.onSignOut()),
              icon: const Icon(Icons.logout_rounded, size: 19),
              label: const Text('Log out / Use another account'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModalContent {
  const _ModalContent(this.title, this.message);

  final String title;
  final String message;

  factory _ModalContent.forProblem(
    SubscriptionProblem problem,
  ) => switch (problem) {
    SubscriptionProblem.expired => const _ModalContent(
      'Keep the music going',
      'Your trial or subscription has ended. Subscribe to keep every board, song, and set list within reach.',
    ),
    SubscriptionProblem.internetRequired => const _ModalContent(
      'Connect to verify',
      'Internet is required to securely validate your subscription. Connect, then try again.',
    ),
    SubscriptionProblem.serviceUnavailable => const _ModalContent(
      'Verification unavailable',
      'The subscription service could not validate your account. Your internet may be working—please try again shortly.',
    ),
  };
}

class _SubscribeButton extends StatelessWidget {
  const _SubscribeButton({required this.isLoading, required this.onPressed});

  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: FilledButton.icon(
      onPressed: isLoading ? null : onPressed,
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      icon: isLoading
          ? const SizedBox.square(
              dimension: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.lock_open_rounded),
      label: const Text(
        'Subscribe now',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
  );
}
