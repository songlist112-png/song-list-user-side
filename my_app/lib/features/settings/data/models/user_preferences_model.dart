import '../../domain/entities/user_preferences.dart';

/// Serializable storage shape for [UserPreferences].
///
/// Mirrors the remote `user_preferences` row columns so the same payload is
/// written to local storage and pushed to Supabase.
class UserPreferencesModel {
  const UserPreferencesModel({
    required this.lyricsFontScale,
    required this.darkMode,
  });

  factory UserPreferencesModel.fromEntity(UserPreferences preferences) {
    return UserPreferencesModel(
      lyricsFontScale: preferences.lyricsFontScale,
      darkMode: preferences.darkMode,
    );
  }

  factory UserPreferencesModel.fromJson(Map<String, dynamic> json) {
    return UserPreferencesModel(
      lyricsFontScale:
          (json['lyrics_font_scale'] as num?)?.toDouble() ??
          UserPreferences.defaultLyricsFontScale,
      darkMode: json['dark_mode'] as bool? ?? false,
    );
  }

  final double lyricsFontScale;
  final bool darkMode;

  UserPreferences toEntity() {
    return UserPreferences(
      lyricsFontScale: lyricsFontScale,
      darkMode: darkMode,
    );
  }

  Map<String, dynamic> toJson() {
    return {'lyrics_font_scale': lyricsFontScale, 'dark_mode': darkMode};
  }
}
