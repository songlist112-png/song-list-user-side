class LyricLineOrigin {
  const LyricLineOrigin({required this.text, required this.isPersonal});

  final String text;
  final bool isPersonal;
}

List<LyricLineOrigin> classifyLyricLines({
  required String originalLyrics,
  required String displayedLyrics,
}) {
  final remainingOriginalLines = <String, int>{};
  for (final line in originalLyrics.split('\n')) {
    final key = _comparisonKey(line);
    remainingOriginalLines[key] = (remainingOriginalLines[key] ?? 0) + 1;
  }

  return displayedLyrics
      .split('\n')
      .map((line) {
        final key = _comparisonKey(line);
        final remaining = remainingOriginalLines[key] ?? 0;
        if (remaining > 0) {
          remainingOriginalLines[key] = remaining - 1;
          return LyricLineOrigin(text: line, isPersonal: false);
        }
        return LyricLineOrigin(text: line, isPersonal: true);
      })
      .toList(growable: false);
}

String _comparisonKey(String line) =>
    line.endsWith('\r') ? line.substring(0, line.length - 1) : line;
