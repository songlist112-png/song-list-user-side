import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../domain/lyric_line_origin.dart';

class PersonalLyricsText extends StatelessWidget {
  const PersonalLyricsText({
    super.key,
    required this.originalLyrics,
    required this.personalLyrics,
  });

  final String originalLyrics;
  final String personalLyrics;

  @override
  Widget build(BuildContext context) {
    final lines = classifyLyricLines(
      originalLyrics: originalLyrics,
      displayedLyrics: personalLyrics,
    );
    return Text.rich(
      TextSpan(
        children: lines.indexed
            .map((entry) {
              final suffix = entry.$1 == lines.length - 1 ? '' : '\n';
              return TextSpan(
                text: '${entry.$2.text}$suffix',
                style: TextStyle(
                  color: entry.$2.isPersonal
                      ? AppColors.personalEdit
                      : Colors.black,
                ),
              );
            })
            .toList(growable: false),
      ),
      style: const TextStyle(fontSize: 13, height: 1.5),
    );
  }
}
