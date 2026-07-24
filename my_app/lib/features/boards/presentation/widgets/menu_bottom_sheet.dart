import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/models/artist.dart';
import '../../../../shared/models/label.dart';

class MenuBottomSheet extends StatefulWidget {
  final bool showArtist;
  final bool showBpm;
  final bool darkMode;
  final List<Artist> artists;
  final List<Label> labels;
  final ValueChanged<bool> onShowArtistChanged;
  final ValueChanged<bool> onShowBpmChanged;
  final ValueChanged<bool> onDarkModeChanged;
  final ValueChanged<String> onAddArtist;
  final ValueChanged<String> onRemoveArtist;
  final ValueChanged<String> onUpdateArtist;
  final ValueChanged<String> onAddLabel;
  final ValueChanged<String> onRemoveLabel;
  final VoidCallback? onExport;
  final VoidCallback? onImport;

  const MenuBottomSheet({
    super.key,
    required this.showArtist,
    required this.showBpm,
    required this.darkMode,
    required this.artists,
    required this.labels,
    required this.onShowArtistChanged,
    required this.onShowBpmChanged,
    required this.onDarkModeChanged,
    required this.onAddArtist,
    required this.onRemoveArtist,
    required this.onUpdateArtist,
    required this.onAddLabel,
    required this.onRemoveLabel,
    this.onExport,
    this.onImport,
  });

  @override
  State<MenuBottomSheet> createState() => _MenuBottomSheetState();
}

class _MenuBottomSheetState extends State<MenuBottomSheet> {
  late bool _showArtist;
  late bool _showBpm;
  late bool _darkMode;

  @override
  void initState() {
    super.initState();
    _showArtist = widget.showArtist;
    _showBpm = widget.showBpm;
    _darkMode = widget.darkMode;
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom + 20;

    return Scaffold(
      backgroundColor: AppColors.bgCard,
      body: SafeArea(
        // ADD THIS SafeArea WIDGET
        child: Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 8,
            bottom: bottomPadding,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const SizedBox(height: 12),
                const Center(
                  child: Text(
                    'Board Settings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Export / Import Section
                _buildSection(
                  title: 'DATA MANAGEMENT',
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          icon: Icons.upload_outlined,
                          label: 'Export',
                          onPressed: widget.onExport,
                          isPrimary: true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildActionButton(
                          icon: Icons.download_outlined,
                          label: 'Import',
                          onPressed: widget.onImport,
                          isPrimary: false,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Display Settings
                _buildSection(
                  title: 'DISPLAY SETTINGS',
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.border.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildSwitchTile(
                          icon: Icons.person_outline,
                          title: 'Show Artist',
                          subtitle: 'Display artist names on song cards',
                          value: _showArtist,
                          onChanged: (val) {
                            setState(() => _showArtist = val);
                            widget.onShowArtistChanged(val);
                          },
                        ),
                        _buildDivider(),
                        _buildSwitchTile(
                          icon: Icons.speed,
                          title: 'Show BPM',
                          subtitle: 'Display tempo on song cards',
                          value: _showBpm,
                          onChanged: (val) {
                            setState(() => _showBpm = val);
                            widget.onShowBpmChanged(val);
                          },
                        ),
                        _buildDivider(),
                        _buildSwitchTile(
                          icon: Icons.dark_mode_outlined,
                          title: 'Dark Mode',
                          subtitle: 'Use dark theme colors',
                          value: _darkMode,
                          onChanged: (val) {
                            setState(() => _darkMode = val);
                            widget.onDarkModeChanged(val);
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Artists Section
                _buildSection(
                  title: 'ARTISTS (${widget.artists.length})',
                  child: Column(
                    children: [
                      if (widget.artists.isEmpty)
                        _buildEmptyState(
                          icon: Icons.person_outline,
                          message: 'No artists added yet',
                        )
                      else
                        ...widget.artists.map(
                          (artist) => _buildListItem(
                            title: artist.name,
                            icon: Icons.person,
                            onDelete: () => widget.onRemoveArtist(artist.id),
                          ),
                        ),
                      const SizedBox(height: 8),
                      _buildAddButton(
                        label: 'Add Artist',
                        icon: Icons.person_add_outlined,
                        onPressed: () => widget.onAddArtist(''),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Labels Section
                _buildSection(
                  title: 'LABELS (${widget.labels.length})',
                  child: Column(
                    children: [
                      if (widget.labels.isEmpty)
                        _buildEmptyState(
                          icon: Icons.label_outline,
                          message: 'No labels added yet',
                        )
                      else
                        ...widget.labels.map(
                          (label) => _buildLabelItem(
                            label: label,
                            onDelete: () => widget.onRemoveLabel(label.id),
                          ),
                        ),
                      const SizedBox(height: 8),
                      _buildAddButton(
                        label: 'Add Label',
                        icon: Icons.add_circle_outline,
                        onPressed: () => widget.onAddLabel(''),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textMuted,
              letterSpacing: 0.5,
            ),
          ),
        ),
        child,
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    required bool isPrimary,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.accent : AppColors.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isPrimary
                ? AppColors.accent
                : AppColors.border.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isPrimary ? Colors.white : AppColors.text,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isPrimary ? Colors.white : AppColors.text,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: AppColors.accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.accent.withValues(alpha: 0.5),
            thumbColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppColors.accent;
              }
              return null;
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(height: 1, color: AppColors.border.withValues(alpha: 0.3)),
    );
  }

  Widget _buildListItem({
    required String title,
    required IconData icon,
    required VoidCallback onDelete,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 18, color: AppColors.accent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.text,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            IconButton(
              onPressed: onDelete,
              icon: const Icon(
                Icons.delete_outline,
                size: 20,
                color: Colors.red,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              tooltip: 'Remove',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabelItem({
    required Label label,
    required VoidCallback onDelete,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: label.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: label.color,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label.name,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.text,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            IconButton(
              onPressed: onDelete,
              icon: const Icon(
                Icons.delete_outline,
                size: 20,
                color: Colors.red,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              tooltip: 'Remove',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.accent.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.accent.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: AppColors.accent),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.accent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({required IconData icon, required String message}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 24,
            color: AppColors.textMuted.withValues(alpha: 0.5),
          ),
          const SizedBox(width: 12),
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textMuted.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
