import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../profile/providers/current_profile_provider.dart';
import '../providers/settings_provider.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _isSigningOut = false;

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final profile = ref.watch(currentProfileProvider).valueOrNull;
    final authUser = ref.read(authControllerProvider).currentUser;
    final fullName = profile?.fullName?.trim();
    final email = (profile?.email ?? authUser?.email ?? '').trim();
    final displayName = fullName != null && fullName.isNotEmpty
        ? fullName
        : email.isNotEmpty
        ? email.split('@').first
        : 'Account';

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: settings.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => _LoadError(
          onRetry: () => ref.read(settingsProvider.notifier).reloadFromRemote(),
        ),
        data: (preferences) => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const _SectionTitle('APPEARANCE'),
            const SizedBox(height: 10),
            Card(
              clipBehavior: Clip.antiAlias,
              child: SwitchListTile.adaptive(
                secondary: const Icon(Icons.dark_mode_outlined),
                title: const Text('Dark Mode'),
                subtitle: const Text('Use dark colors throughout the app'),
                value: preferences.darkMode,
                onChanged: (enabled) => _updatePreference(
                  () => ref
                      .read(settingsProvider.notifier)
                      .updateDarkMode(enabled),
                  'Dark Mode',
                ),
              ),
            ),
            const SizedBox(height: 24),
            const _SectionTitle('BOARD DISPLAY'),
            const SizedBox(height: 10),
            Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  SwitchListTile.adaptive(
                    secondary: const Icon(Icons.visibility_outlined),
                    title: const Text('View Mode'),
                    subtitle: const Text('Hide board editing controls'),
                    value: preferences.viewMode,
                    onChanged: (enabled) => _updatePreference(
                      () => ref
                          .read(settingsProvider.notifier)
                          .updateViewMode(enabled),
                      'View Mode',
                    ),
                  ),
                  const Divider(height: 1),
                  SwitchListTile.adaptive(
                    secondary: const Icon(Icons.width_wide_outlined),
                    title: const Text('Wide Song Columns'),
                    subtitle: const Text('Give lyrics more horizontal space'),
                    value: preferences.wideSongColumns,
                    onChanged: (enabled) => _updatePreference(
                      () => ref
                          .read(settingsProvider.notifier)
                          .updateWideSongColumns(enabled),
                      'Wide Song Columns',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const _SectionTitle('ACCOUNT'),
            const SizedBox(height: 10),
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  child: Text(displayName.characters.first.toUpperCase()),
                ),
                title: Text(
                  displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: email.isEmpty
                    ? null
                    : Text(email, maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _isSigningOut ? null : _signOut,
              icon: _isSigningOut
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.logout_rounded),
              label: Text(_isSigningOut ? 'Logging out...' : 'Log Out'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updatePreference(
    Future<void> Function() update,
    String settingName,
  ) async {
    try {
      await update();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save $settingName setting.')),
      );
    }
  }

  Future<void> _signOut() async {
    setState(() => _isSigningOut = true);
    try {
      await ref.read(authControllerProvider).signOut();
      if (mounted) context.go('/login');
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSigningOut = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not log out. Please try again.')),
      );
    }
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 1.1,
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.settings_outlined, size: 40),
            const SizedBox(height: 12),
            const Text('Could not load settings.'),
            const SizedBox(height: 12),
            FilledButton.tonal(
              onPressed: onRetry,
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
