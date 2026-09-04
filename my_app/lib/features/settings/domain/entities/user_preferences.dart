/// User-controlled application preferences.
class UserPreferences {
  const UserPreferences({
    this.lyricsFontScale = defaultLyricsFontScale,
    this.darkMode = false,
  });

  static const double defaultLyricsFontScale = 1.0;

  /// Smallest multiplier applied to the base lyrics font size.
  static const double minLyricsFontScale = 1.0;

  /// Largest multiplier applied to the base lyrics font size.
  static const double maxLyricsFontScale = 1.8;

  /// Multiplier applied to the base lyrics font size (1.0 = default).
  final double lyricsFontScale;
  final bool darkMode;

  UserPreferences copyWith({double? lyricsFontScale, bool? darkMode}) {
    return UserPreferences(
      lyricsFontScale: lyricsFontScale ?? this.lyricsFontScale,
      darkMode: darkMode ?? this.darkMode,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is UserPreferences &&
        other.lyricsFontScale == lyricsFontScale &&
        other.darkMode == darkMode;
  }

  @override
  int get hashCode => Object.hash(lyricsFontScale, darkMode);
}
