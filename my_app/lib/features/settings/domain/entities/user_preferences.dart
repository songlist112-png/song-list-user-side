/// User-controlled application preferences.
class UserPreferences {
  const UserPreferences({this.lyricsFontScale = defaultLyricsFontScale});

  static const double defaultLyricsFontScale = 1.0;

  /// Smallest multiplier applied to the base lyrics font size.
  static const double minLyricsFontScale = 1.0;

  /// Largest multiplier applied to the base lyrics font size.
  static const double maxLyricsFontScale = 1.8;

  /// Multiplier applied to the base lyrics font size (1.0 = default).
  final double lyricsFontScale;

  UserPreferences copyWith({double? lyricsFontScale}) {
    return UserPreferences(
      lyricsFontScale: lyricsFontScale ?? this.lyricsFontScale,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is UserPreferences &&
        other.lyricsFontScale == lyricsFontScale;
  }

  @override
  int get hashCode => lyricsFontScale.hashCode;
}
