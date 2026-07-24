import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/models/label.dart';
import '../../../../shared/models/song.dart';
import '../../../../shared/models/song_column.dart';
import 'song_card_widget.dart';

class SongColumnWidget extends StatefulWidget {
  final SongColumn column;
  final bool showArtist;
  final bool showBpm;
  final bool isViewMode;
  final VoidCallback? onAddSong;
  final VoidCallback? onMenuTap;
  final Function(Song)? onSongTap;
  final Function(String)? onRenameColumn;
  final Function(int, int)? onReorderSongs;
  final List<Label> availableLabels;

  const SongColumnWidget({
    super.key,
    required this.column,
    this.showArtist = true,
    this.showBpm = false,
    this.isViewMode = false,
    this.onAddSong,
    this.onMenuTap,
    this.onSongTap,
    this.onRenameColumn,
    this.onReorderSongs,
    this.availableLabels = const [],
  });

  @override
  State<SongColumnWidget> createState() => _SongColumnWidgetState();
}

class _SongColumnWidgetState extends State<SongColumnWidget> {
  final Set<String> _expandedSongIds = {};

  void _toggleSongExpansion(String songId) {
    setState(() {
      if (_expandedSongIds.contains(songId)) {
        _expandedSongIds.remove(songId);
      } else {
        _expandedSongIds.add(songId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Use almost full screen width with small padding (16px on each side)
    final columnWidth = screenWidth - 32;

    return Container(
      width: columnWidth,
      decoration: BoxDecoration(
        color: AppColors.bgColumn,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.column.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                ),
                if (!widget.isViewMode)
                  SizedBox(
                    width: 28,
                    height: 28,
                    child: IconButton(
                      onPressed: widget.onMenuTap,
                      icon: const Icon(Icons.more_vert, size: 18),
                      padding: EdgeInsets.zero,
                      color: AppColors.textMuted,
                    ),
                  ),
              ],
            ),
          ),

          // Song cards
          if (widget.column.songs.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: widget.onReorderSongs == null
                  ? Column(
                      children: widget.column.songs.map((song) {
                        final isExpanded = _expandedSongIds.contains(song.id);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: SongCardWidget(
                            song: song,
                            showArtist: widget.showArtist,
                            showBpm: widget.showBpm,
                            isExpanded: isExpanded,
                            availableLabels: widget.availableLabels,
                            onTap: widget.isViewMode
                                ? () => _toggleSongExpansion(song.id)
                                : () => widget.onSongTap?.call(song),
                          ),
                        );
                      }).toList(),
                    )
                  : ReorderableListView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      buildDefaultDragHandles: false, // Disable default handles to customize drag behavior
                      onReorder: (oldIndex, newIndex) {
                        if (widget.onReorderSongs != null) {
                          widget.onReorderSongs!(oldIndex, newIndex);
                        }
                      },
                      children: widget.column.songs.asMap().entries.map((entry) {
                        final index = entry.key;
                        final song = entry.value;
                        final isExpanded = _expandedSongIds.contains(song.id);
                        return ReorderableDelayedDragStartListener(
                          key: ValueKey(song.id),
                          index: index,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: SongCardWidget(
                              song: song,
                              showArtist: widget.showArtist,
                              showBpm: widget.showBpm,
                              isExpanded: isExpanded,
                              isReorderable: true,
                              availableLabels: widget.availableLabels,
                              onTap: widget.isViewMode
                                  ? () => _toggleSongExpansion(song.id)
                                  : () => widget.onSongTap?.call(song),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
            ),

          // Add song button
          if (!widget.isViewMode)
            InkWell(
              onTap: widget.onAddSong,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Row(
                  children: const [
                    Icon(Icons.add, size: 18, color: AppColors.textMuted),
                    SizedBox(width: 6),
                    Text(
                      'Add song',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
