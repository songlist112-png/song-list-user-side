import '../entities/user_preferences.dart';

abstract interface class SettingsRepository {
  /// Loads the persisted preferences, defaulting when none are stored.
  Future<UserPreferences> load({bool preferRemote = false});

  /// Persists the given preferences locally and pushes them to the remote.
  Future<void> save(UserPreferences preferences);
}
