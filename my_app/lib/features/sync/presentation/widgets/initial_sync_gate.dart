import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/sync_service.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../pages/initial_sync_page.dart';

class InitialSyncGate extends ConsumerStatefulWidget {
  const InitialSyncGate({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<InitialSyncGate> createState() => _InitialSyncGateState();
}

class _InitialSyncGateState extends ConsumerState<InitialSyncGate> {
  Future<void> _retry() => ref.read(syncServiceProvider).synchronize();

  Future<void> _signOut() async {
    await ref.read(authControllerProvider).signOut();
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final status =
        ref.watch(syncStatusProvider).valueOrNull ??
        const SyncStatus.checking();
    final isResolvingAccount =
        status.phase == SyncPhase.idle || status.phase == SyncPhase.checking;
    final requiresInitialSync =
        status.isInitialSync && status.phase != SyncPhase.completed;

    if (!isResolvingAccount && !requiresInitialSync) return widget.child;

    return InitialSyncPage(
      status: isResolvingAccount ? const SyncStatus.checking() : status,
      onRetry: _retry,
      onSignOut: _signOut,
    );
  }
}
