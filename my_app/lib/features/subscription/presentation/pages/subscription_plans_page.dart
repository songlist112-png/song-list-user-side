import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/env.dart';
import '../../domain/subscription_entitlement.dart';
import '../providers/subscription_provider.dart';

typedef SubscriptionPortalLauncher = Future<bool> Function(Uri uri);

class SubscriptionPlansPage extends ConsumerStatefulWidget {
  const SubscriptionPlansPage({super.key, this.launchPortal});

  final SubscriptionPortalLauncher? launchPortal;

  @override
  ConsumerState<SubscriptionPlansPage> createState() =>
      _SubscriptionPlansPageState();
}

class _SubscriptionPlansPageState extends ConsumerState<SubscriptionPlansPage>
    with WidgetsBindingObserver {
  static final _portalUri = Uri.parse(Env.subscriptionPortalUrl);

  bool _isOpeningPortal = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(ref.read(subscriptionGateProvider.notifier).validate());
    }
  }

  Future<void> _openPortal() async {
    if (_isOpeningPortal) return;
    if (_portalUri.scheme != 'https' || !_portalUri.hasAuthority) {
      _showLaunchError();
      return;
    }
    setState(() => _isOpeningPortal = true);
    try {
      final opened = await (widget.launchPortal ?? _launchPortal)(_portalUri);
      if (!opened && mounted) _showLaunchError();
    } on Exception {
      if (mounted) _showLaunchError();
    } finally {
      if (mounted) setState(() => _isOpeningPortal = false);
    }
  }

  Future<bool> _launchPortal(Uri uri) =>
      launchUrl(uri, mode: LaunchMode.externalApplication);

  void _showLaunchError() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not open subscription page')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final gateState = ref.watch(subscriptionGateProvider);
    final membership = _MembershipView.from(gateState);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Plans & Billing'),
        actions: [
          IconButton(
            tooltip: 'Refresh subscription status',
            onPressed: gateState.status == SubscriptionGateStatus.loading
                ? null
                : () => unawaited(
                    ref.read(subscriptionGateProvider.notifier).validate(),
                  ),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Your membership',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'See your current access and manage your Song List plan.',
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _MembershipStatusCard(membership: membership),
                  const SizedBox(height: 18),
                  _PremiumPlanCard(
                    isCurrentPlan: membership.isSubscribed,
                    isOpeningPortal: _isOpeningPortal,
                    onOpenPortal: _openPortal,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MembershipStatusCard extends StatelessWidget {
  const _MembershipStatusCard({required this.membership});

  final _MembershipView membership;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      container: true,
      label: 'Subscription status: ${membership.statusLabel}',
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: colors.outline),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: membership.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(membership.icon, color: membership.color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    membership.statusLabel,
                    style: TextStyle(
                      color: membership.color,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    membership.planLabel,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (membership.detail case final detail?) ...[
                    const SizedBox(height: 4),
                    Text(
                      detail,
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PremiumPlanCard extends StatelessWidget {
  const _PremiumPlanCard({
    required this.isCurrentPlan,
    required this.isOpeningPortal,
    required this.onOpenPortal,
  });

  final bool isCurrentPlan;
  final bool isOpeningPortal;
  final VoidCallback onOpenPortal;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.bgDark,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.6)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Song List Premium',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
              ),
              if (isCurrentPlan)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Current plan',
                    style: TextStyle(
                      color: AppColors.bgDark,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Keep your complete music library available wherever you prepare.',
            style: TextStyle(color: Colors.white70, height: 1.45),
          ),
          const SizedBox(height: 20),
          const _Benefit(text: 'Access every board, song, and set list'),
          const _Benefit(text: 'Work offline after secure validation'),
          const _Benefit(text: 'Manage artists, labels, and personal edits'),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: isOpeningPortal ? null : onOpenPortal,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.bgDark,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: isOpeningPortal
                  ? SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colors.primary,
                      ),
                    )
                  : const Icon(Icons.open_in_new_rounded),
              label: Text(
                isCurrentPlan ? 'Manage subscription' : 'View premium plans',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Center(
            child: Text(
              'Pricing and payment are handled securely in the billing portal.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white60, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}

class _Benefit extends StatelessWidget {
  const _Benefit({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white, height: 1.35),
          ),
        ),
      ],
    ),
  );
}

class _MembershipView {
  const _MembershipView({
    required this.statusLabel,
    required this.planLabel,
    required this.icon,
    required this.color,
    required this.isSubscribed,
    this.detail,
  });

  final String statusLabel;
  final String planLabel;
  final String? detail;
  final IconData icon;
  final Color color;
  final bool isSubscribed;

  factory _MembershipView.from(SubscriptionGateState state) {
    final entitlement = state.entitlement;
    if (state.status == SubscriptionGateStatus.loading) {
      return const _MembershipView(
        statusLabel: 'Checking status',
        planLabel: 'Subscription verification in progress',
        icon: Icons.hourglass_top_rounded,
        color: AppColors.accent,
        isSubscribed: false,
      );
    }

    if (state.status == SubscriptionGateStatus.entitled &&
        entitlement?.status == SubscriptionStatus.active) {
      return _MembershipView(
        statusLabel: 'Subscribed',
        planLabel: 'Song List Premium',
        detail: _activePlanDetail(entitlement!),
        icon: Icons.verified_rounded,
        color: const Color(0xFF16803A),
        isSubscribed: true,
      );
    }

    if (state.status == SubscriptionGateStatus.entitled &&
        entitlement?.status == SubscriptionStatus.trial) {
      return _MembershipView(
        statusLabel: 'Free trial',
        planLabel: 'Song List Trial',
        detail: _accessDetail(entitlement!),
        icon: Icons.schedule_rounded,
        color: AppColors.accent,
        isSubscribed: false,
      );
    }

    if (state.status == SubscriptionGateStatus.expired) {
      return const _MembershipView(
        statusLabel: 'Not subscribed',
        planLabel: 'No active plan',
        icon: Icons.money_off_csred_rounded,
        color: Color(0xFFC62828),
        isSubscribed: false,
      );
    }

    return const _MembershipView(
      statusLabel: 'Could not verify',
      planLabel: 'Connect and refresh your status',
      icon: Icons.cloud_off_rounded,
      color: Color(0xFFB26A00),
      isSubscribed: false,
    );
  }

  static String? _accessDetail(SubscriptionEntitlement entitlement) {
    final expiration = entitlement.expiresAt;
    if (expiration == null) return null;
    final local = expiration.toLocal();
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final prefix = entitlement.status == SubscriptionStatus.trial
        ? 'Trial ends'
        : 'Access through';
    return '$prefix ${months[local.month - 1]} ${local.day}, ${local.year}';
  }

  static String? _activePlanDetail(SubscriptionEntitlement entitlement) {
    final cadence = switch (entitlement.plan.trim().toLowerCase()) {
      'monthly' => 'Monthly plan',
      'annual' || 'yearly' => 'Annual plan',
      _ => null,
    };
    final access = _accessDetail(entitlement);
    if (cadence == null) return access;
    if (access == null) return cadence;
    return '$cadence · $access';
  }
}
