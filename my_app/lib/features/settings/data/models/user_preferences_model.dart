import '../../domain/entities/user_preferences.dart';

/// Serializable storage shape for [UserPreferences].
///
/// Mirrors the remote `user_preferences` row columns so the same payload is
/// written to local storage and pushed to Supabase.
class UserPreferencesModel {
  const UserPreferencesModel({required this.lyricsFontScale});

  factory UserPreferencesModel.fromEntity(UserPreferences preferences) {
    return UserPreferencesModel(
      lyricsFontScale: preferences.lyricsFontScale,
    );
  }

  factory UserPreferencesModel.fromJson(Map<String, dynamic> json) {
    return UserPreferencesModel(
      lyricsFontScale:
          (json['lyrics_font_scale'] as num?)?.toDouble() ??
          UserPreferences.defaultLyricsFontScale,
    );
  }

  final double lyricsFontScale;

  UserPreferences toEntity() {
    return UserPreferences(lyricsFontScale: lyricsFontScale);
  }

  Map<String, dynamic> toJson() {
    return {'lyrics_font_scale': lyricsFontScale};
  }
}
