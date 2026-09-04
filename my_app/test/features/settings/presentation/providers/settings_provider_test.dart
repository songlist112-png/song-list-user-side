import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/features/settings/domain/entities/user_preferences.dart';
import 'package:my_app/features/settings/domain/repositories/settings_repository.dart';
import 'package:my_app/features/settings/presentation/providers/settings_provider.dart';

class _SettingsRepository implements SettingsRepository {
  UserPreferences preferences = const UserPreferences();
  bool failSave = false;

  @override
  Future<UserPreferences> load({bool preferRemote = false}) async =>
      preferences;

  @override
  Future<void> save(UserPreferences preferences) async {
    if (failSave) throw StateError('save failed');
    this.preferences = preferences;
  }
}

void main() {
  test('dark mode updates global preferences', () async {
    final repository = _SettingsRepository();
    final controller = SettingsController(repository);
    await Future<void>.delayed(Duration.zero);

    await controller.updateDarkMode(true);

    expect(controller.state.asData?.value.darkMode, isTrue);
    expect(repository.preferences.darkMode, isTrue);
  });

  test('dark mode rolls back when persistence fails', () async {
    final repository = _SettingsRepository()..failSave = true;
    final controller = SettingsController(repository);
    await Future<void>.delayed(Duration.zero);

    await expectLater(controller.updateDarkMode(true), throwsStateError);

    expect(controller.state.asData?.value.darkMode, isFalse);
  });
}
