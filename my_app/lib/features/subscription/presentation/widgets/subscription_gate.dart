import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/controllers/auth_controller.dart';
import '../providers/subscription_provider.dart';
import 'subscription_modal.dart';

class SubscriptionGate extends ConsumerStatefulWidget {
  const SubscriptionGate({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<SubscriptionGate> createState() => _SubscriptionGateState();
}

class _SubscriptionGateState extends ConsumerState<SubscriptionGate>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    scheduleMicrotask(
      () => ref.read(subscriptionGateProvider.notifier).validate(),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        ref.read(subscriptionGateProvider).status !=
            SubscriptionGateStatus.entitled) {
      unawaited(ref.read(subscriptionGateProvider.notifier).validate());
    }
  }

  Future<void> _signOut() async {
    await ref.read(authControllerProvider).signOut();
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(subscriptionGateProvider);
    if (state.status == SubscriptionGateStatus.entitled) return widget.child;

    return ColoredBox(
      color: const Color(0xFF06152F),
      child: SafeArea(
        child: Center(
          child: state.status == SubscriptionGateStatus.loading
              ? const _ValidationProgress()
              : SubscriptionModal(
                  problem: switch (state.status) {
                    SubscriptionGateStatus.expired =>
                      SubscriptionProblem.expired,
                    SubscriptionGateStatus.serviceUnavailable =>
                      SubscriptionProblem.serviceUnavailable,
                    _ => SubscriptionProblem.internetRequired,
                  },
                  onRetry: () =>
                      ref.read(subscriptionGateProvider.notifier).validate(),
                  onSignOut: _signOut,
                ),
        ),
      ),
    );
  }
}

class _ValidationProgress extends StatelessWidget {
  const _ValidationProgress();

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Validating subscription',
    liveRegion: true,
    child: const CircularProgressIndicator(color: Colors.white),
  );
}
