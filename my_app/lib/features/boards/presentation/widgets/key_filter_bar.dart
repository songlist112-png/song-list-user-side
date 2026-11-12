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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Row(
            children: [
              // Key buttons
              ...keys.map(
                (key) => Expanded(
                  child: _buildFilterChip(
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
              ),

              const SizedBox(width: 6),

              // Flat button
              Expanded(
                child: _buildFilterChip(
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
              ),

              // Sharp button
              Expanded(
                child: _buildFilterChip(
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
              ),

              const SizedBox(width: 6),

              // Clear button
              Expanded(
                child: _buildFilterChip(
                  label: '✕',
                  isActive: false,
                  onTap: onClear,
                  isCancel: true,
                ),
              ),
            ],
          ),
        ),
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
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isCancel
                ? AppColors.bgDark
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
