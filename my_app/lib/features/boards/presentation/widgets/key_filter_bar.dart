import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

class KeyFilterBar extends StatelessWidget {
  final String? activeKey;
  final String? activeAccidental; // 'flat', 'sharp', or null
  final ValueChanged<String?> onKeySelected;
  final ValueChanged<String?> onAccidentalSelected;
  final VoidCallback onClear;

  const KeyFilterBar({
    super.key,
    this.activeKey,
    this.activeAccidental,
    required this.onKeySelected,
    required this.onAccidentalSelected,
    required this.onClear,
  });

  static const List<String> keys = ['C', 'D', 'E', 'F', 'G', 'A', 'B'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Key buttons
                  ...keys.map(
                    (key) => _buildFilterChip(
                      label: key,
                      isActive: activeKey == key,
                      onTap: () {
                        if (activeKey == key) {
                          onKeySelected(null);
                        } else {
                          onKeySelected(key);
                        }
                      },
                    ),
                  ),

                  const SizedBox(width: 4),

                  // Flat button
                  _buildFilterChip(
                    label: '♭',
                    isActive: activeAccidental == 'flat',
                    onTap: () {
                      if (activeAccidental == 'flat') {
                        onAccidentalSelected(null);
                      } else {
                        onAccidentalSelected('flat');
                      }
                    },
                  ),

                  // Sharp button
                  _buildFilterChip(
                    label: '♯',
                    isActive: activeAccidental == 'sharp',
                    onTap: () {
                      if (activeAccidental == 'sharp') {
                        onAccidentalSelected(null);
                      } else {
                        onAccidentalSelected('sharp');
                      }
                    },
                  ),

                  // Clear button
                  _buildFilterChip(
                    label: '✕',
                    isActive: false,
                    onTap: onClear,
                    isCancel: true,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    bool isCancel = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isCancel
                ? Colors.red.shade400
                : isActive
                ? AppColors.filterBtnActive
                : AppColors.filterBtnBg,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isCancel
                  ? Colors.white
                  : isActive
                  ? AppColors.filterBtnActiveText
                  : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
