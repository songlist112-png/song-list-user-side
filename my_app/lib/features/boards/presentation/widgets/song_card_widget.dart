import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_chip.dart';
import '../../../../shared/models/label.dart';
import '../../../../shared/models/song.dart';

class SongCardWidget extends StatelessWidget {
  final Song song;
  final bool showArtist;
  final bool showBpm;
  final bool isExpanded;
  final bool isReorderable;
  final int? reorderIndex;
  final VoidCallback? onTap;
  final VoidCallback? onMove;
  final List<Label> availableLabels;

  const SongCardWidget({
    super.key,
    required this.song,
    this.showArtist = true,
    this.showBpm = false,
    this.isExpanded = false,
    this.isReorderable = false,
    this.reorderIndex,
    this.onTap,
    this.onMove,
    this.availableLabels = const [],
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(8),
          boxShadow: AppColors.shadowCard,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Song title
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    song.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.text,
                    ),
                  ),
                ),
                if (onMove != null)
                  IconButton(
                    tooltip: 'Move song',
                    onPressed: onMove,
                    icon: const Icon(
                      Icons.drive_file_move_outlined,
                      size: 20,
                      color: AppColors.textMuted,
                    ),
                  ),
                if (isReorderable) _DragHandle(reorderIndex: reorderIndex),
              ],
            ),

            // Badges row (key, artist)
            if (_hasBadges) ...[
              const SizedBox(height: 6),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: [
                  AppChip(
                    label: song.creatorType == SongCreatorType.admin
                        ? 'Admin-created'
                        : 'User-created',
                    backgroundColor: song.creatorType == SongCreatorType.admin
                        ? AppColors.accent
                        : Colors.green.shade600,
                    textColor: Colors.white,
                  ),
                  if (song.key != null && song.key!.isNotEmpty)
                    AppChip(label: song.keyDisplay),
                  if (showArtist &&
                      song.artistName != null &&
                      song.artistName!.isNotEmpty)
                    AppChip(label: song.artistName!),
                  if (showBpm && song.tempo != null)
                    AppChip(label: '${song.tempo} BPM'),
                  // Label badges with their names and colors
                  ..._getLabels().map(
                    (label) => AppChip(
                      label: label.name,
                      backgroundColor: label.color,
                      textColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 6),
            // Attachment icon
            if (song.attachments.isNotEmpty) ...[
              const SizedBox(height: 6),
              const Icon(
                Icons.attach_file,
                size: 14,
                color: AppColors.textMuted,
              ),
            ],

            // Lyrics section (expanded)
            if (isExpanded && song.lyrics != null) ...[
              const SizedBox(height: 12),
              const Divider(color: AppColors.border, height: 1),
              const SizedBox(height: 12),
              Row(
                children: const [
                  Icon(Icons.lyrics, size: 14, color: AppColors.textMuted),
                  SizedBox(width: 6),
                  Text(
                    'Lyrics',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                song.lyrics!,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.text,
                  height: 1.5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  bool get _hasBadges {
    if (song.creatorType == SongCreatorType.admin ||
        song.creatorType == SongCreatorType.user) {
      return true;
    }
    if (song.key != null && song.key!.isNotEmpty) return true;
    if (showArtist && song.artistName != null && song.artistName!.isNotEmpty) {
      return true;
    }
    if (showBpm && song.tempo != null) return true;
    if (song.labels.isNotEmpty) return true;
    return false;
  }

  List<Label> _getLabels() {
    // Look up full Label objects from availableLabels by matching IDs
    return song.labels
        .map((labelId) {
          try {
            return availableLabels.firstWhere((label) => label.id == labelId);
          } catch (e) {
            return null;
          }
        })
        .whereType<Label>()
        .toList();
  }
}

class _DragHandle extends StatelessWidget {
  const _DragHandle({required this.reorderIndex});

  final int? reorderIndex;

  @override
  Widget build(BuildContext context) {
    const icon = Icon(
      Icons.drag_indicator,
      size: 20,
      color: AppColors.textMuted,
    );
    final index = reorderIndex;
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: index == null
          ? icon
          : ReorderableDragStartListener(
              index: index,
              child: const SizedBox(
                width: 40,
                height: 40,
                child: Center(child: icon),
              ),
            ),
    );
  }
}
