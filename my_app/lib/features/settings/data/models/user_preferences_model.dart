import '../../domain/entities/user_preferences.dart';

/// Serializable storage shape for [UserPreferences].
///
/// Mirrors the remote `user_preferences` row columns so the same payload is
/// written to local storage and pushed to Supabase.
class UserPreferencesModel {
  const UserPreferencesModel({
    required this.lyricsFontScale,
    required this.darkMode,
    this.viewMode = false,
    this.wideSongColumns = false,
  });

  factory UserPreferencesModel.fromEntity(UserPreferences preferences) {
    return UserPreferencesModel(
      lyricsFontScale: preferences.lyricsFontScale,
      darkMode: preferences.darkMode,
      viewMode: preferences.viewMode,
      wideSongColumns: preferences.wideSongColumns,
    );
  }

  factory UserPreferencesModel.fromJson(Map<String, dynamic> json) {
    return UserPreferencesModel(
      lyricsFontScale:
          (json['lyrics_font_scale'] as num?)?.toDouble() ??
          UserPreferences.defaultLyricsFontScale,
      darkMode: json['dark_mode'] as bool? ?? false,
      viewMode: json['view_mode'] as bool? ?? false,
      wideSongColumns: json['wide_song_columns'] as bool? ?? false,
    );
  }

  final double lyricsFontScale;
  final bool darkMode;
  final bool viewMode;
  final bool wideSongColumns;

  UserPreferences toEntity() {
    return UserPreferences(
      lyricsFontScale: lyricsFontScale,
      darkMode: darkMode,
      viewMode: viewMode,
      wideSongColumns: wideSongColumns,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lyrics_font_scale': lyricsFontScale,
      'dark_mode': darkMode,
      'view_mode': viewMode,
      'wide_song_columns': wideSongColumns,
    };
  }
}
