import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/models/label.dart';
import '../../../../shared/models/song.dart';
import '../../../../shared/models/song_attachment.dart';
import '../../../../shared/utils/media_type.dart';

class AddEditSongPage extends StatefulWidget {
  final Song? existingSong;
  final List<String> availableArtists;
  final List<Label> availableLabels;
  final Future<void> Function(Song) onSave;
  final Future<void> Function()? onDelete;
  final Future<Uint8List> Function(SongAttachment)? onDownloadAttachment;

  const AddEditSongPage({
    super.key,
    this.existingSong,
    required this.availableArtists,
    this.availableLabels = const [],
    required this.onSave,
    this.onDelete,
    this.onDownloadAttachment,
  });

  @override
  State<AddEditSongPage> createState() => _AddEditSongPageState();
}

class _AddEditSongPageState extends State<AddEditSongPage> {
  late final TextEditingController _titleController;
  late final TextEditingController _tempoController;
  late final TextEditingController _lyricsController;
  String? _selectedArtist;
  String? _selectedKey;
  String _selectedKeyType = 'Major';
  List<SongAttachment> _attachments = [];
  List<String> _selectedLabelIds = [];
  static const List<String> _keys = [
    '(none)',
    "C",
    "C♯",
    "D",
    "Db",
    "D#",
    "E♭",
    "E",
    "F",
    "F♯",
    "G",
    "Gb",
    "G#",
    "A♭",
    "A",
    "A#",
    "B♭",
    "B",
  ];
  static const List<String> _keyTypes = ["Major", "Minor", "Freygish"];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.existingSong?.title ?? '',
    );
    _tempoController = TextEditingController(
      text: widget.existingSong?.tempo?.toString() ?? '',
    );
    _lyricsController = TextEditingController(
      text: widget.existingSong?.lyrics ?? '',
    );
    _selectedArtist = widget.existingSong?.artistName;
    _selectedKey = widget.existingSong?.key;
    _selectedKeyType = widget.existingSong?.keyType ?? 'Major';
    _attachments = List<SongAttachment>.from(
      widget.existingSong?.attachments ?? const [],
    );
    _selectedLabelIds = List<String>.from(widget.existingSong?.labels ?? []);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _tempoController.dispose();
    _lyricsController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_titleController.text.trim().isEmpty || _isSaving) return;

    final song = Song(
      id:
          widget.existingSong?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      createdBy: widget.existingSong?.createdBy,
      creatorType: widget.existingSong?.creatorType ?? SongCreatorType.user,
      canEdit: widget.existingSong?.canEdit ?? true,
      title: _titleController.text.trim(),
      artistName: _selectedArtist,
      tempo: int.tryParse(_tempoController.text),
      key: _selectedKey == '(none)' ? null : _selectedKey,
      keyType: _selectedKeyType,
      lyrics: _lyricsController.text.isNotEmpty ? _lyricsController.text : null,
      attachments: _attachments,
      labels: _selectedLabelIds,
    );
    setState(() => _isSaving = true);
    try {
      await widget.onSave(song);
      if (mounted) Navigator.of(context).pop();
    } on Exception catch (error) {
      if (mounted) _showError(error);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _handleDelete() async {
    if (widget.onDelete == null || _isSaving) return;
    setState(() => _isSaving = true);
    try {
      await widget.onDelete!();
      if (mounted) Navigator.of(context).pop();
    } on Exception catch (error) {
      if (mounted) _showError(error);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showError(Object error) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Could not save song: $error')));
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingSong != null;

    return Scaffold(
      backgroundColor: AppColors.bgCard,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.text,
        elevation: 0,
        title: Text(
          isEditing ? 'Edit Song' : 'New Song',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.text, size: 24),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (widget.onDelete != null)
            IconButton(
              onPressed: _isSaving ? null : _handleDelete,
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              tooltip: 'Delete song',
            ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton(
              onPressed: _isSaving ? null : _handleSave,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: const Text(
                'Save',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accent,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Basic Information Section
            _buildSection(
              title: 'BASIC INFORMATION',
              children: [
                // Title
                _buildTextField(
                  label: 'Title',
                  controller: _titleController,
                  hintText: 'Enter song title',
                  isRequired: true,
                ),
                const SizedBox(height: 16),

                // Artist
                _buildFieldLabel('Artist'),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.bgCard,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.border.withValues(alpha: 0.5),
                          ),
                        ),
                        child: DropdownButtonFormField<String>(
                          initialValue: _selectedArtist,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            border: InputBorder.none,
                            hintText: 'Select artist',
                          ),
                          dropdownColor: AppColors.bgCard,
                          items: widget.availableArtists.map((a) {
                            return DropdownMenuItem(
                              value: a,
                              child: Text(
                                a,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: AppColors.text,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() => _selectedArtist = val);
                          },
                        ),
                      ),
                    ),
                    // const SizedBox(width: 10),
                    // Container(
                    //   height: 48,
                    //   width: 48,
                    //   decoration: BoxDecoration(
                    //     color: AppColors.accent.withValues(alpha: 0.1),
                    //     borderRadius: BorderRadius.circular(12),
                    //     border: Border.all(
                    //       color: AppColors.accent.withValues(alpha: 0.3),
                    //     ),
                    //   ),
                    //   child: IconButton(
                    //     onPressed: _showAddArtistDialog,
                    //     icon: const Icon(
                    //       Icons.add,
                    //       size: 20,
                    //       color: AppColors.accent,
                    //     ),
                    //     tooltip: 'Add new artist',
                    //   ),
                    // ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Musical Details Section
            _buildSection(
              title: 'MUSICAL DETAILS',
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        label: 'Tempo (BPM)',
                        controller: _tempoController,
                        hintText: '120',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Key
                _buildFieldLabel('Key'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.bgCard,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.border.withValues(alpha: 0.5),
                          ),
                        ),
                        child: DropdownButtonFormField<String>(
                          initialValue: _selectedKey ?? '(none)',
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            border: InputBorder.none,
                          ),
                          dropdownColor: AppColors.bgCard,
                          items: _keys.map((k) {
                            return DropdownMenuItem(
                              value: k,
                              child: Text(
                                k,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: AppColors.text,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() => _selectedKey = val);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 3,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.bgCard,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.border.withValues(alpha: 0.5),
                          ),
                        ),
                        child: DropdownButtonFormField<String>(
                          initialValue: _selectedKeyType,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            border: InputBorder.none,
                          ),
                          dropdownColor: AppColors.bgCard,
                          items: _keyTypes.map((t) {
                            return DropdownMenuItem(
                              value: t,
                              child: Text(
                                t,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: AppColors.text,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() => _selectedKeyType = val ?? 'Major');
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Labels Section
            _buildSection(
              title: 'LABELS',
              children: [
                if (widget.availableLabels.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.bgColumn.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.border.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: const [
                        Icon(
                          Icons.info_outline,
                          size: 18,
                          color: AppColors.textMuted,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'No labels available. Add labels in the menu.',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: widget.availableLabels.map((label) {
                      final isSelected = _selectedLabelIds.contains(label.id);
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _selectedLabelIds.remove(label.id);
                              } else {
                                _selectedLabelIds.add(label.id);
                              }
                            });
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? label.color.withValues(alpha: 0.15)
                                  : AppColors.bgCard,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? label.color
                                    : AppColors.border.withValues(alpha: 0.5),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isSelected)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: Icon(
                                      Icons.check_circle,
                                      size: 16,
                                      color: label.color,
                                    ),
                                  )
                                else
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: Container(
                                      width: 14,
                                      height: 14,
                                      decoration: BoxDecoration(
                                        color: label.color,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                Text(
                                  label.name,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isSelected
                                        ? AppColors.text
                                        : AppColors.textMuted,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),

            const SizedBox(height: 24),

            // Lyrics Section
            _buildSection(
              title: 'LYRICS / NOTES',
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.border.withValues(alpha: 0.5),
                    ),
                  ),
                  child: TextField(
                    controller: _lyricsController,
                    maxLines: 6,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.text,
                      height: 1.5,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Enter lyrics or notes...',
                      hintStyle: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 15,
                      ),
                      contentPadding: EdgeInsets.all(16),
                      border: InputBorder.none,
                      alignLabelWithHint: true,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Attachments Section
            _buildSection(
              title: 'ATTACHMENTS',
              children: [
                InkWell(
                  onTap: _pickFile,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.accent.withValues(alpha: 0.3),
                        width: 1.5,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.add_circle_outline,
                          size: 20,
                          color: AppColors.accent,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Add attachment',
                          style: TextStyle(
                            fontSize: 15,
                            color: AppColors.accent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Display attached files
                if (_attachments.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  ..._attachments.asMap().entries.map((entry) {
                    final index = entry.key;
                    final attachment = entry.value;
                    final fileName = attachment.name;
                    final extension = fileName.toLowerCase().split('.').last;

                    // Determine icon and color based on file type
                    IconData fileIcon;
                    Color fileColor;

                    if (extension == 'pdf') {
                      fileIcon = Icons.picture_as_pdf;
                      fileColor = Colors.red;
                    } else if (['jpg', 'jpeg', 'png'].contains(extension)) {
                      fileIcon = Icons.image;
                      fileColor = Colors.blue;
                    } else if (['doc', 'docx'].contains(extension)) {
                      fileIcon = Icons.description;
                      fileColor = Colors.indigo;
                    } else if (extension == 'txt') {
                      fileIcon = Icons.text_snippet;
                      fileColor = Colors.grey;
                    } else {
                      fileIcon = Icons.insert_drive_file;
                      fileColor = AppColors.accent;
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.bgCard,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.border.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: fileColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(fileIcon, size: 20, color: fileColor),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                fileName,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.text,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // Download button for all files when editing
                            if (isEditing) ...[
                              IconButton(
                                icon: const Icon(
                                  Icons.download,
                                  size: 20,
                                  color: AppColors.accent,
                                ),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 36,
                                  minHeight: 36,
                                ),
                                tooltip: 'Download file',
                                onPressed:
                                    attachment.storagePath == null ||
                                        widget.onDownloadAttachment == null
                                    ? null
                                    : () => _downloadAttachment(attachment),
                              ),
                              const SizedBox(width: 4),
                            ],
                            IconButton(
                              icon: const Icon(
                                Icons.close,
                                size: 20,
                                color: AppColors.textMuted,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 36,
                                minHeight: 36,
                              ),
                              tooltip: 'Remove',
                              onPressed: () => _removeAttachment(index),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
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
        ...children,
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(label, isRequired: isRequired),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(fontSize: 15, color: AppColors.text),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 15,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFieldLabel(String text, {bool isRequired = false}) {
    return Row(
      children: [
        Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
        if (isRequired)
          const Text(
            ' *',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.red,
            ),
          ),
      ],
    );
  }

  // void _showAddArtistDialog() {
  //   final controller = TextEditingController();
  //   showDialog(
  //     context: context,
  //     builder: (ctx) => AlertDialog(
  //       title: const Text('Add Artist'),
  //       content: TextField(
  //         controller: controller,
  //         autofocus: true,
  //         decoration: const InputDecoration(hintText: 'Artist name'),
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(ctx),
  //           child: const Text('Cancel'),
  //         ),
  //         ElevatedButton(
  //           onPressed: () {
  //             final name = controller.text.trim();
  //             if (name.isNotEmpty) {
  //               setState(() {
  //                 _selectedArtist = name;
  //               });
  //             }
  //             Navigator.pop(ctx);
  //           },
  //           child: const Text('Add'),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'jpg', 'jpeg', 'png'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = result.files.single;
        setState(() {
          _attachments.add(
            SongAttachment(
              name: file.name,
              localPath: file.path,
              fileType: normalizeMediaType(
                file.extension ?? '',
                fileName: file.name,
              ),
              fileSize: file.size,
            ),
          );
        });
      }
    } catch (e) {
      // Handle error
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking file: $e')));
      }
    }
  }

  void _removeAttachment(int index) {
    setState(() {
      _attachments.removeAt(index);
    });
  }

  Future<void> _downloadAttachment(SongAttachment attachment) async {
    try {
      final bytes = await widget.onDownloadAttachment!(attachment);
      final directory = await getApplicationDocumentsDirectory();
      final safeName = attachment.name.replaceAll(
        RegExp(r'[^a-zA-Z0-9._-]'),
        '_',
      );
      final file = File('${directory.path}/$safeName');
      await file.writeAsBytes(bytes, flush: true);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saved ${attachment.name} to ${file.path}')),
      );
    } on Exception catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not download attachment: $error')),
      );
    }
  }
}

bool _isSaving = false;
