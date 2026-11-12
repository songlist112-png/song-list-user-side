/// User-controlled application preferences.
class UserPreferences {
  const UserPreferences({
    this.lyricsFontScale = defaultLyricsFontScale,
    this.darkMode = false,
    this.viewMode = false,
    this.wideSongColumns = false,
  });

  static const double defaultLyricsFontScale = 1.0;

  /// Smallest multiplier applied to the base lyrics font size.
  static const double minLyricsFontScale = 1.0;

  /// Largest multiplier applied to the base lyrics font size.
  static const double maxLyricsFontScale = 1.8;

  /// Multiplier applied to the base lyrics font size (1.0 = default).
  final double lyricsFontScale;
  final bool darkMode;
  final bool viewMode;
  final bool wideSongColumns;

  UserPreferences copyWith({
    double? lyricsFontScale,
    bool? darkMode,
    bool? viewMode,
    bool? wideSongColumns,
  }) {
    return UserPreferences(
      lyricsFontScale: lyricsFontScale ?? this.lyricsFontScale,
      darkMode: darkMode ?? this.darkMode,
      viewMode: viewMode ?? this.viewMode,
      wideSongColumns: wideSongColumns ?? this.wideSongColumns,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is UserPreferences &&
        other.lyricsFontScale == lyricsFontScale &&
        other.darkMode == darkMode &&
        other.viewMode == viewMode &&
        other.wideSongColumns == wideSongColumns;
  }

  @override
  int get hashCode =>
      Object.hash(lyricsFontScale, darkMode, viewMode, wideSongColumns);
}
