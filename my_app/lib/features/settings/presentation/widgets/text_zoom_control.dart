import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

/// Compact A-/A+ control for adjusting text size.
///
/// Presentational: the parent owns the scale and the min/max bounds.
class TextZoomControl extends StatelessWidget {
  const TextZoomControl({
    super.key,
    required this.scale,
    required this.minScale,
    required this.maxScale,
    required this.onZoomIn,
    required this.onZoomOut,
  });

  final double scale;
  final double minScale;
  final double maxScale;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final canZoomOut = scale > minScale;
    final canZoomIn = scale < maxScale;
    return Semantics(
      label: 'Adjust lyrics text size',
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _zoomButton(
              Icons.text_decrease,
              canZoomOut,
              onZoomOut,
              colors.outline,
            ),
            Container(
              width: 1,
              height: 14,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              color: colors.outline,
            ),
            _zoomButton(
              Icons.text_increase,
              canZoomIn,
              onZoomIn,
              colors.outline,
            ),
          ],
        ),
      ),
    );
  }

  Widget _zoomButton(
    IconData icon,
    bool enabled,
    VoidCallback onTap,
    Color disabledColor,
  ) {
    return InkWell(
      onTap: enabled ? onTap : null,
      customBorder: const CircleBorder(),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Icon(
          icon,
          size: 16,
          color: enabled ? AppColors.accent : disabledColor,
        ),
      ),
    );
  }
}
