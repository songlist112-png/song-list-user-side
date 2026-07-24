import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

class AppChip extends StatelessWidget {
  final String label;
  final Color? backgroundColor;
  final Color? textColor;
  final double fontSize;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const AppChip({
    super.key,
    required this.label,
    this.backgroundColor,
    this.textColor,
    this.fontSize = 11,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.bgColumn,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: fontSize,
                color: textColor ?? AppColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (onDelete != null) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onDelete,
                behavior: HitTestBehavior.translucent,
                child: Icon(
                  Icons.close,
                  size: 12,
                  color: textColor ?? AppColors.textMuted,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
