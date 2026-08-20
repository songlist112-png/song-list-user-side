import 'package:flutter/material.dart';

import '../../../../core/services/sync_service.dart';

class InitialSyncPage extends StatelessWidget {
  const InitialSyncPage({
    required this.status,
    required this.onRetry,
    required this.onSignOut,
    super.key,
  });

  final SyncStatus status;
  final Future<void> Function() onRetry;
  final Future<void> Function() onSignOut;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF031A3D), Color(0xFF0758B8)],
          ),
        ),
        child: Stack(
          children: [
            const Positioned(
              top: -100,
              right: -90,
              child: _GlowOrb(size: 280, color: Color(0x3359C3FF)),
            ),
            const Positioned(
              bottom: -130,
              left: -100,
              child: _GlowOrb(size: 320, color: Color(0x2246F0B0)),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: _SetupCard(
                      status: status,
                      onRetry: onRetry,
                      onSignOut: onSignOut,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SetupCard extends StatelessWidget {
  const _SetupCard({
    required this.status,
    required this.onRetry,
    required this.onSignOut,
  });

  final SyncStatus status;
  final Future<void> Function() onRetry;
  final Future<void> Function() onSignOut;

  bool get _hasError =>
      status.phase == SyncPhase.failed || status.phase == SyncPhase.offline;

  @override
  Widget build(BuildContext context) {
    final progress = (status.progress ?? 0).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33001335),
            blurRadius: 40,
            offset: Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _BrandMark(),
          const SizedBox(height: 28),
          Text(
            _title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF0A1E3A),
              fontSize: 27,
              height: 1.15,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.7,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF607089),
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 30),
          _ProgressPanel(status: status, progress: progress),
          const SizedBox(height: 24),
          if (_hasError) ...[
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try again'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(54),
                  shape: const StadiumBorder(),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
          TextButton(
            onPressed: onSignOut,
            child: const Text('Use another account'),
          ),
        ],
      ),
    );
  }

  String get _title => switch (status.phase) {
    SyncPhase.offline => 'You’re offline',
    SyncPhase.failed => 'Setup needs another try',
    _ => 'Preparing your song library',
  };

  String get _description => switch (status.phase) {
    SyncPhase.offline => 'Reconnect to finish downloading your master songs.',
    SyncPhase.failed => 'Your progress is saved. Continue when you’re ready.',
    _ => 'We’re securely adding the master songs to this device.',
  };
}

class _ProgressPanel extends StatelessWidget {
  const _ProgressPanel({required this.status, required this.progress});

  final SyncStatus status;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Initial song synchronization',
      value: '${status.progressPercent} percent',
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F7FC),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFDDE8F6)),
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${status.progressPercent}',
                  style: const TextStyle(
                    color: Color(0xFF0758B8),
                    fontSize: 42,
                    height: 0.9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1.5,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 3, bottom: 2),
                  child: Text(
                    '%',
                    style: TextStyle(
                      color: Color(0xFF0758B8),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.cloud_download_outlined,
                  color: Color(0xFF0758B8),
                  size: 24,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _countLabel,
                style: const TextStyle(
                  color: Color(0xFF607089),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: TweenAnimationBuilder<double>(
                tween: Tween(end: progress),
                duration: const Duration(milliseconds: 450),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) => LinearProgressIndicator(
                  value: value,
                  minHeight: 10,
                  backgroundColor: const Color(0xFFD7E3F2),
                  color: const Color(0xFF0C66E4),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(
                  Icons.offline_bolt_rounded,
                  size: 18,
                  color: Color(0xFF04963A),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _statusLabel,
                    style: const TextStyle(
                      color: Color(0xFF33445D),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String get _countLabel {
    final total = status.totalSongs;
    if (total == null) {
      return status.syncedSongs == 0
          ? 'Checking library'
          : '${status.syncedSongs} songs ready';
    }
    final synced = status.syncedSongs.clamp(0, total);
    return '$synced of $total songs';
  }

  String get _statusLabel => switch (status.phase) {
    SyncPhase.offline => 'Waiting for an internet connection',
    SyncPhase.failed => 'Downloaded songs are safely saved',
    SyncPhase.checking => 'Connecting securely',
    _ => 'Making songs available offline',
  };
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFF0758B8),
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Icon(Icons.queue_music_rounded, color: Colors.white),
      ),
      const SizedBox(width: 12),
      const Flexible(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'Song List',
            maxLines: 1,
            style: TextStyle(
              color: Color(0xFF0A1E3A),
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
            ),
          ),
        ),
      ),
    ],
  );
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}
