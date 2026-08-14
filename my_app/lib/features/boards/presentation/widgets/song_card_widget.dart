import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_chip.dart';
import '../../../../shared/models/label.dart';
import '../../../../shared/models/song.dart';
import '../../../settings/domain/entities/user_preferences.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../../settings/presentation/widgets/text_zoom_control.dart';
import '../../../songs/presentation/widgets/personal_lyrics_text.dart';

class SongCardWidget extends StatelessWidget {
  final Song song;
  final bool showArtist;
  final bool showBpm;
  final bool isExpanded;
  final bool isReorderable;
  final bool isViewMode;
  final int? reorderIndex;
  final VoidCallback? onTap;
  final VoidCallback? onMove;
  final VoidCallback? onPersonalEdit;
  final List<Label> availableLabels;

  const SongCardWidget({
    super.key,
    required this.song,
    this.showArtist = true,
    this.showBpm = false,
    this.isExpanded = false,
    this.isReorderable = false,
    this.isViewMode = false,
    this.reorderIndex,
    this.onTap,
    this.onMove,
    this.onPersonalEdit,
    this.availableLabels = const [],
  });

  @override
  Widget build(BuildContext context) {
    final statusLabel = song.hasPersonalEdit
        ? 'Edited'
        : song.creatorType == SongCreatorType.admin
        ? 'Library'
        : null;
    final statusColor = song.hasPersonalEdit
        ? AppColors.personalEdit
        : AppColors.accent;

    final metaItems = <String>[
      if (song.key != null && song.key!.isNotEmpty) song.keyDisplay,
      if (showArtist && song.artistName != null && song.artistName!.isNotEmpty)
        song.artistName!,
      if (showBpm && song.tempo != null) '${song.tempo} BPM',
    ];

    final labelChips = _getLabels()
        .map(
          (label) => AppChip(
            label: label.name,
            backgroundColor: label.color,
            textColor: Colors.white,
          ),
        )
        .toList(growable: false);

    final hasInfo =
        statusLabel != null ||
        metaItems.isNotEmpty ||
        song.attachments.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(10),
          boxShadow: AppColors.shadowCard,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title + actions
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    song.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
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
                if (onPersonalEdit != null)
                  IconButton(
                    tooltip: song.hasPersonalEdit
                        ? 'Edit personal lyrics and notes'
                        : 'Create personal lyrics and notes',
                    onPressed: onPersonalEdit,
                    icon: Icon(
                      song.hasPersonalEdit
                          ? Icons.edit_note
                          : Icons.note_add_outlined,
                      size: 20,
                      color: song.hasPersonalEdit
                          ? AppColors.personalEdit
                          : AppColors.accent,
                    ),
                  ),
                if (isReorderable) _DragHandle(reorderIndex: reorderIndex),
              ],
            ),

            // Status badge + quiet metadata line
            if (hasInfo) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  if (statusLabel != null) ...[
                    _StatusPill(label: statusLabel, color: statusColor),
                    if (metaItems.isNotEmpty || song.attachments.isNotEmpty)
                      const SizedBox(width: 10),
                  ],
                  if (metaItems.isNotEmpty)
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                          children: _joinMeta(metaItems),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  if (song.attachments.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    _AttachmentCount(count: song.attachments.length),
                  ],
                ],
              ),
            ],

            // Colored label chips
            if (labelChips.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(spacing: 4, runSpacing: 4, children: labelChips),
            ],

            // Lyrics section (expanded)
            if (isExpanded && song.displayedLyrics != null) ...[
              _LyricsSection(song: song, isViewMode: isViewMode),
            ],
          ],
        ),
      ),
    );
  }

  List<InlineSpan> _joinMeta(List<String> items) {
    final spans = <InlineSpan>[];
    for (var i = 0; i < items.length; i++) {
      if (i > 0) {
        spans.add(
          const WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 6),
              child: _MetaDot(),
            ),
          ),
        );
      }
      spans.add(TextSpan(text: items[i]));
    }
    return spans;
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

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaDot extends StatelessWidget {
  const _MetaDot();

  @override
  Widget build(BuildContext context) => Container(
    width: 3,
    height: 3,
    decoration: const BoxDecoration(
      shape: BoxShape.circle,
      color: AppColors.border,
    ),
  );
}

class _AttachmentCount extends StatelessWidget {
  const _AttachmentCount({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.attach_file, size: 13, color: AppColors.textMuted),
        const SizedBox(width: 3),
        Text(
          '$count',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}

class _LyricsSection extends ConsumerStatefulWidget {
  const _LyricsSection({required this.song, required this.isViewMode});

  final Song song;
  final bool isViewMode;

  @override
  ConsumerState<_LyricsSection> createState() => _LyricsSectionState();
}

class _LyricsSectionState extends ConsumerState<_LyricsSection> {
  static const _baseSize = 13.0;
  static const _step = 0.2;

  double _currentScale() {
    final preferences = ref.read(settingsProvider).valueOrNull;
    return preferences?.lyricsFontScale ??
        UserPreferences.defaultLyricsFontScale;
  }

  Future<void> _zoomIn() => _setScale(_currentScale() + _step);

  Future<void> _zoomOut() => _setScale(_currentScale() - _step);

  Future<void> _setScale(double value) async {
    if (value == _currentScale()) return;
    try {
      await ref.read(settingsProvider.notifier).updateLyricsFontScale(value);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save text size: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final song = widget.song;
    final hasPersonalEdit = song.hasPersonalEdit;
    final preferences = ref.watch(settingsProvider).valueOrNull;
    final scale =
        preferences?.lyricsFontScale ??
        UserPreferences.defaultLyricsFontScale;
    final fontSize = _baseSize * scale;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        const Divider(color: AppColors.border, height: 1),
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(
              Icons.lyrics,
              size: 14,
              color: hasPersonalEdit
                  ? AppColors.personalEdit
                  : AppColors.textMuted,
            ),
            const SizedBox(width: 6),
            Text(
              hasPersonalEdit ? 'Personal lyrics & notes' : 'Lyrics',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: hasPersonalEdit
                    ? AppColors.personalEdit
                    : AppColors.textMuted,
              ),
            ),
            const Spacer(),
            if (widget.isViewMode)
              TextZoomControl(
                scale: scale,
                minScale: UserPreferences.minLyricsFontScale,
                maxScale: UserPreferences.maxLyricsFontScale,
                onZoomIn: _zoomIn,
                onZoomOut: _zoomOut,
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (hasPersonalEdit)
          PersonalLyricsText(
            originalLyrics: song.lyrics ?? '',
            personalLyrics: song.personalLyrics!,
            fontSize: fontSize,
          )
        else
          Text(song.lyrics!, style: TextStyle(fontSize: fontSize, height: 1.5)),
      ],
    );
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
