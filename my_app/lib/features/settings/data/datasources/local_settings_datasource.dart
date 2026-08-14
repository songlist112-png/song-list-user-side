import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_preferences_model.dart';

/// Persists user preferences on-device using [SharedPreferences].
class LocalSettingsDataSource {
  LocalSettingsDataSource({SharedPreferences? preferences})
    : // Optional injection keeps the instance testable while staying conventional.
      // ignore: prefer_initializing_formals
      _preferences = preferences;

  static const _key = 'user_preferences';

  final SharedPreferences? _preferences;

  Future<SharedPreferences> _getPreferences() async {
    return _preferences ?? await SharedPreferences.getInstance();
  }

  Future<UserPreferencesModel?> read() async {
    final raw = (await _getPreferences()).getString(_key);
    if (raw == null) return null;
    return UserPreferencesModel.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
  }

  Future<void> write(UserPreferencesModel model) async {
    await (await _getPreferences()).setString(_key, jsonEncode(model.toJson()));
  }
}
