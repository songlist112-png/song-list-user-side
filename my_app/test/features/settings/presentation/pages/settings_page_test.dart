import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_app/database/local/models/profile.dart';
import 'package:my_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:my_app/features/profile/providers/current_profile_provider.dart';
import 'package:my_app/features/settings/domain/entities/user_preferences.dart';
import 'package:my_app/features/settings/domain/repositories/settings_repository.dart';
import 'package:my_app/features/settings/presentation/pages/settings_page.dart';
import 'package:my_app/features/settings/presentation/providers/settings_provider.dart';

class _SettingsRepository implements SettingsRepository {
  UserPreferences preferences = const UserPreferences();

  @override
  Future<UserPreferences> load({bool preferRemote = false}) async =>
      preferences;

  @override
  Future<void> save(UserPreferences preferences) async {
    this.preferences = preferences;
  }
}

class _MockAuthController extends Mock implements AuthController {}

void main() {
  testWidgets('shows account and persists all display toggles', (tester) async {
    final repository = _SettingsRepository();
    final auth = _MockAuthController();
    when(() => auth.currentUser).thenReturn(null);

    await _pumpSettings(tester, repository: repository, auth: auth);

    expect(find.text('Taylor Singer'), findsOneWidget);
    expect(find.text('taylor@example.com'), findsOneWidget);
    expect(find.text('Dark Mode'), findsOneWidget);
    expect(find.text('View Mode'), findsOneWidget);
    expect(find.text('Wide Song Columns'), findsOneWidget);

    await tester.tap(find.text('View Mode'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Wide Song Columns'));
    await tester.pumpAndSettle();

    expect(repository.preferences.viewMode, isTrue);
    expect(repository.preferences.wideSongColumns, isTrue);
  });

  testWidgets('Log Out signs out and opens login', (tester) async {
    final repository = _SettingsRepository();
    final auth = _MockAuthController();
    when(() => auth.currentUser).thenReturn(null);
    when(auth.signOut).thenAnswer((_) async {});

    await _pumpSettings(tester, repository: repository, auth: auth);
    await tester.scrollUntilVisible(
      find.text('Log Out'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Log Out'));
    await tester.pumpAndSettle();

    verify(auth.signOut).called(1);
    expect(find.text('Login page'), findsOneWidget);
  });
}

Future<void> _pumpSettings(
  WidgetTester tester, {
  required _SettingsRepository repository,
  required AuthController auth,
}) async {
  final profile = Profile()
    ..userId = 'user'
    ..fullName = 'Taylor Singer'
    ..email = 'taylor@example.com'
    ..role = 'user'
    ..createdAt = DateTime.utc(2026)
    ..updatedAt = DateTime.utc(2026);
  final router = GoRouter(
    initialLocation: '/settings',
    routes: [
      GoRoute(path: '/settings', builder: (_, _) => const SettingsPage()),
      GoRoute(
        path: '/login',
        builder: (_, _) => const Scaffold(body: Text('Login page')),
      ),
    ],
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(repository),
        authControllerProvider.overrideWithValue(auth),
        currentProfileProvider.overrideWith((_) => Stream.value(profile)),
      ],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
}
