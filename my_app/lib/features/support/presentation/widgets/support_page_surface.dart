import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

class SupportPageSurface extends StatelessWidget {
  const SupportPageSurface({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: AppColors.bgDark,
    child: Padding(
      padding: const EdgeInsets.only(top: 10),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: Color(0xFFF3F7FC),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: child,
        ),
      ),
    ),
  );
}
