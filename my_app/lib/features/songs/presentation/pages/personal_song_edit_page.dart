import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/models/song.dart';
import '../controllers/personal_lyrics_editing_controller.dart';

class PersonalSongEditPage extends StatefulWidget {
  const PersonalSongEditPage({
    super.key,
    required this.song,
    required this.onSave,
    this.onReset,
  });

  final Song song;
  final Future<void> Function(String lyrics) onSave;
  final Future<void> Function()? onReset;

  @override
  State<PersonalSongEditPage> createState() => _PersonalSongEditPageState();
}

class _PersonalSongEditPageState extends State<PersonalSongEditPage> {
  late final PersonalLyricsEditingController _lyricsController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _lyricsController = PersonalLyricsEditingController(
      originalLyrics: widget.song.lyrics ?? '',
      text: widget.song.displayedLyrics,
    );
  }

  @override
  void dispose() {
    _lyricsController.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() operation) async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await operation();
      if (mounted) Navigator.pop(context);
    } on Exception catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save personal version: $error')),
      );
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCard,
      appBar: AppBar(
        title: const Text('Personal lyrics & notes'),
        leading: IconButton(
          tooltip: 'Close',
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
        ),
        actions: [
          if (widget.onReset != null)
            IconButton(
              tooltip: 'Restore admin lyrics',
              onPressed: _saving ? null : () => _run(widget.onReset!),
              icon: const Icon(Icons.restore),
            ),
          TextButton(
            onPressed: _saving
                ? null
                : () => _run(() => widget.onSave(_lyricsController.text)),
            child: const Text('Save'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            widget.song.title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(
            'Song details stay managed by admin. Only your private lyrics and notes change.',
            style: const TextStyle(color: AppColors.textMuted),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _lyricsController,
            autofocus: true,
            minLines: 14,
            maxLines: null,
            maxLength: 100000,
            style: const TextStyle(color: Colors.black),
            decoration: InputDecoration(
              labelText: 'Your lyrics & notes',
              helperText: 'Add notes directly between lyric lines.',
              alignLabelWithHint: true,
              filled: true,
              fillColor: AppColors.personalEdit.withValues(alpha: 0.06),
              border: const OutlineInputBorder(),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(
                  color: AppColors.personalEdit,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
