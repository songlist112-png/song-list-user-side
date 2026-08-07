import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../domain/lyric_line_origin.dart';

class PersonalLyricsEditingController extends TextEditingController {
  PersonalLyricsEditingController({
    required this.originalLyrics,
    required super.text,
  });

  final String originalLyrics;

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final composingRange = value.composing;
    if (withComposing &&
        composingRange.isValid &&
        !composingRange.isCollapsed) {
      return super.buildTextSpan(
        context: context,
        style: style,
        withComposing: withComposing,
      );
    }
    final lines = classifyLyricLines(
      originalLyrics: originalLyrics,
      displayedLyrics: text,
    );
    return TextSpan(
      style: style,
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
    );
  }
}
