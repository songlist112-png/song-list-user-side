import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/models/song_list.dart';

class BoardSelectorDialog extends StatelessWidget {
  final List<SongList> songLists;
  final String? activeId;
  final ValueChanged<SongList> onSelect;
  final VoidCallback onCreateNew;
  final Function(SongList)? onMenuTap;

  const BoardSelectorDialog({
    super.key,
    required this.songLists,
    this.activeId,
    required this.onSelect,
    required this.onCreateNew,
    this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 80),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Close button
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: const Icon(Icons.close, color: AppColors.textMuted),
              ),
            ),
            const SizedBox(height: 8),

            // Song list items
            ...songLists.map((list) {
              final isActive = list.id == activeId;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                          onSelect(list);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppColors.accent
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                            border: isActive
                                ? null
                                : Border.all(color: AppColors.border),
                          ),
                          child: Text(
                            list.name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color:
                                  isActive ? Colors.white : AppColors.text,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    SizedBox(
                      width: 32,
                      height: 32,
                      child: IconButton(
                        onPressed: () => onMenuTap?.call(list),
                        icon: const Icon(Icons.more_vert, size: 18),
                        padding: EdgeInsets.zero,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 8),

            // Create new button
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                onCreateNew();
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppColors.border,
                    style: BorderStyle.solid,
                  ),
                ),
                child: const Center(
                  child: Text(
                    '+ Create New Song List',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
