import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/services/screen_capture_protection.dart';
import '../../../../shared/models/artist.dart';
import '../../../../shared/models/label.dart';
import '../../../../shared/models/song.dart';
import '../../../../shared/models/song_column.dart';
import '../../../../shared/models/song_list.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../songs/data/isar_personal_song_edit_repository.dart';
import '../../../songs/presentation/pages/add_edit_song_page.dart';
import '../../../songs/presentation/pages/personal_song_edit_page.dart';
import '../../application/board_detail_controller.dart';
import '../../data/board_repository.dart';
import '../../domain/board_filter.dart';
import '../../domain/song_reorder.dart';
import '../providers/search_history_provider.dart';
import '../widgets/add_column_button.dart';
import '../widgets/key_filter_bar.dart';
import '../widgets/menu_bottom_sheet.dart';
import '../widgets/name_prompt_dialog.dart';
import '../widgets/song_column_widget.dart';

class BoardViewPage extends ConsumerStatefulWidget {
  final String boardId;

  const BoardViewPage({super.key, required this.boardId});

  @override
  ConsumerState<BoardViewPage> createState() => _BoardViewPageState();
}

class _BoardViewPageState extends ConsumerState<BoardViewPage> {
  late SongList _songList;
  bool _isLoading = true;
  Object? _loadError;

  // Key filter state
  String? _activeKey;
  String? _activeAccidental;

  // View mode state
  bool _isViewMode = false;
  bool _isEditMode = false;

  // Search state
  bool _isSearchMode = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';
  List<String> _searchSuggestions = [];
  Timer? _debounceTimer;
  Timer? _boardReloadDebounce;
  StreamSubscription<void>? _boardSubscription;
  int _pendingReorders = 0;
  int _localBoardRevision = 0;

  BoardRepository get _repository => ref.read(boardRepositoryProvider);

  @override
  void initState() {
    super.initState();
    // unawaited(ScreenCaptureProtection.acquire());
    _songList = SongList(
      id: widget.boardId,
      ownerId: '',
      name: '',
      canEdit: false,
      createdAt: DateTime.fromMillisecondsSinceEpoch(0),
    );
    _loadBoard();
    _boardSubscription = _repository.watchChanges().listen((_) {
      _boardReloadDebounce?.cancel();
      _boardReloadDebounce = Timer(const Duration(milliseconds: 120), () {
        if (mounted && _pendingReorders == 0) {
          unawaited(_loadBoard(showLoading: false));
        }
      });
    });
    _searchController.addListener(_onSearchChanged);
    _searchFocusNode.addListener(() {
      if (!_searchFocusNode.hasFocus) {
        _hideSuggestions();
      }
    });
  }

  @override
  void dispose() {
    unawaited(ScreenCaptureProtection.release());
    _debounceTimer?.cancel();
    _boardReloadDebounce?.cancel();
    _boardSubscription?.cancel();
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBoard({bool showLoading = true}) async {
    final revision = _localBoardRevision;
    if (showLoading) {
      setState(() {
        _isLoading = true;
        _loadError = null;
      });
    }
    try {
      final board = await _repository.fetchBoard(widget.boardId);
      if (mounted && _pendingReorders == 0 && revision == _localBoardRevision) {
        setState(() => _songList = board);
      }
    } on Exception catch (error) {
      if (showLoading) {
        if (mounted) setState(() => _loadError = error);
      } else {
        debugPrint('Silent board refresh failed: $error');
      }
    } finally {
      if (showLoading && mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(Object error) {
    debugPrint('Board operation failed: $error');
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Could not save change: $error')));
  }

  void _onSearchChanged() {
    final query = _searchController.text;
    if (!mounted) return;
    setState(() => _searchQuery = query);
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() => _searchSuggestions = _computeSuggestions(query));
    });
  }

  List<String> _computeSuggestions(String query) {
    final normalized = query.trim().toLowerCase();
    final history = ref.read(searchHistoryProvider);

    if (normalized.isEmpty) {
      return history.take(5).toList();
    }

    final suggestions = <String>[];

    for (final h in history) {
      if (h.toLowerCase().contains(normalized)) {
        suggestions.add(h);
      }
    }

    for (final column in _songList.columns) {
      if (column.title.toLowerCase().contains(normalized) &&
          !suggestions.contains(column.title)) {
        suggestions.add(column.title);
      }
    }

    for (final song in _songList.columns.expand((c) => c.songs)) {
      if (song.title.toLowerCase().contains(normalized) &&
          !suggestions.contains(song.title)) {
        suggestions.add(song.title);
      }
      if (song.artistName != null &&
          song.artistName!.toLowerCase().contains(normalized) &&
          !suggestions.contains(song.artistName!)) {
        suggestions.add(song.artistName!);
      }
    }

    return suggestions.take(8).toList();
  }

  void _onSuggestionSelected(String suggestion) {
    _searchController.text = suggestion;
    _hideSuggestions();
  }

  void _hideSuggestions() {
    _debounceTimer?.cancel();
    if (mounted) setState(() => _searchSuggestions = []);
  }

  Widget _buildSearchSuggestions() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        border: Border(
          bottom: BorderSide(color: AppColors.border.withValues(alpha: 0.3)),
        ),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _searchSuggestions.length,
        separatorBuilder: (_, _) => Divider(
          height: 1,
          color: AppColors.border.withValues(alpha: 0.3),
          indent: 16,
          endIndent: 16,
        ),
        itemBuilder: (context, index) {
          final suggestion = _searchSuggestions[index];
          return ListTile(
            leading: const Icon(
              Icons.search,
              size: 18,
              color: AppColors.textMuted,
            ),
            title: Text(
              suggestion,
              style: const TextStyle(fontSize: 15, color: AppColors.text),
            ),
            onTap: () => _onSuggestionSelected(suggestion),
          );
        },
      ),
    );
  }

  Future<void> _addColumn() async {
    final name = await showNamePrompt(
      context,
      title: 'Add List',
      initialValue: 'New List',
      label: 'List name',
      actionLabel: 'Add',
    );
    if (name == null) return;

    try {
      final column = await _repository.createColumn(
        _songList.id,
        name,
        _songList.columns.length,
      );
      if (mounted) {
        setState(() {
          _songList = _songList.copyWith(
            columns: [..._songList.columns, column],
          );
        });
        AppSnackbar.showSuccess(context, 'Column created');
      }
    } on Exception catch (error) {
      if (mounted) _showError(error);
    }
  }

  void _addSongToColumn(String columnId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: AppColors.bgCard,
      builder: (_) => AddEditSongPage(
        availableArtists: _songList.artists.map((a) => a.name).toList(),
        availableLabels: _songList.labels,
        onDownloadAttachment: _repository.downloadAttachment,
        onSave: (song) async {
          final column = _songList.columns.firstWhere(
            (item) => item.id == columnId,
          );
          final savedSong = await _repository.createSong(
            columnId,
            song,
            column.songs.length,
          );
          if (!mounted) return;
          setState(() {
            final columns = _songList.columns.map((col) {
              if (col.id == columnId) {
                return col.copyWith(songs: [...col.songs, savedSong]);
              }
              return col;
            }).toList();
            _songList = _songList.copyWith(columns: columns);
          });
          AppSnackbar.showSuccess(context, 'Song created');
        },
      ),
    );
  }

  void _editSong(Song song, String columnId) {
    // Collect all unique artist names from the song list
    final allArtistNames = <String>{
      ..._songList.artists.map((a) => a.name),
      // Also include artists from songs that might not be in the artists list
      ..._songList.columns
          .expand((c) => c.songs)
          .where((s) => s.artistName != null)
          .map((s) => s.artistName!),
    }.toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: AppColors.bgCard,
      builder: (_) => AddEditSongPage(
        existingSong: song,
        availableArtists: allArtistNames,
        availableLabels: _songList.labels,
        onDownloadAttachment: _repository.downloadAttachment,
        onSave: (updatedSong) async {
          final savedSong = await _repository.updateSong(updatedSong);
          if (!mounted) return;
          setState(() {
            final columns = _songList.columns.map((col) {
              if (col.id == columnId) {
                final updatedSongs = col.songs.map((s) {
                  return s.id == savedSong.id ? savedSong : s;
                }).toList();
                return col.copyWith(songs: updatedSongs);
              }
              return col;
            }).toList();
            _songList = _songList.copyWith(columns: columns);
          });
          AppSnackbar.showSuccess(context, 'Song updated');
        },
        onDelete: () async {
          await _repository.deleteSong(song.id);
          if (!mounted) return;
          setState(() {
            final columns = _songList.columns.map((column) {
              if (column.id != columnId) return column;
              return column.copyWith(
                songs: column.songs
                    .where((item) => item.id != song.id)
                    .toList(),
              );
            }).toList();
            _songList = _songList.copyWith(columns: columns);
          });
        },
      ),
    );
  }

  void _editPersonalSong(Song song) {
    final repository = ref.read(personalSongEditRepositoryProvider);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => PersonalSongEditPage(
        song: song,
        onSave: (lyrics) async {
          await repository.save(songId: song.id, lyrics: lyrics);
          if (mounted) {
            AppSnackbar.showSuccess(context, 'Personal version saved');
          }
        },
        onReset: !song.hasPersonalEdit
            ? null
            : () async {
                await repository.remove(song.id);
                if (mounted) {
                  AppSnackbar.showSuccess(context, 'Admin lyrics restored');
                }
              },
      ),
    );
  }

  Future<void> _reorderSongs(
    String columnId,
    int oldIndex,
    int newIndex,
  ) async {
    final column = _songList.columns.firstWhere((item) => item.id == columnId);
    final songs = reorderSongsByIndex(column.songs, oldIndex, newIndex);
    _pendingReorders++;
    _localBoardRevision++;
    setState(() {
      final columns = _songList.columns
          .map(
            (item) => item.id == columnId ? item.copyWith(songs: songs) : item,
          )
          .toList();
      _songList = _songList.copyWith(columns: columns);
    });
    try {
      await _repository.reorderSongs(songs);
    } catch (error) {
      if (mounted) _showError(error);
    } finally {
      _pendingReorders--;
      if (mounted && _pendingReorders == 0) {
        await _loadBoard(showLoading: false);
      }
    }
  }

  Future<void> _showMoveSongSheet(Song song, String sourceColumnId) async {
    final destinations = _songList.columns
        .where(
          (column) =>
              column.id != sourceColumnId &&
              column.songs.every((item) => item.canEdit),
        )
        .toList(growable: false);
    if (destinations.isEmpty) {
      _showError(StateError('Create another personal column before moving'));
      return;
    }

    final destinationColumnId = await showModalBottomSheet<String>(
      context: context,
      useSafeArea: true,
      backgroundColor: AppColors.bgCard,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(
              title: Text('Move song to'),
              subtitle: Text('Choose personal destination column'),
            ),
            ...destinations.map(
              (column) => ListTile(
                leading: const Icon(Icons.view_column_outlined),
                title: Text(column.title),
                subtitle: Text('${column.songs.length} songs'),
                onTap: () => Navigator.pop(context, column.id),
              ),
            ),
          ],
        ),
      ),
    );
    if (destinationColumnId == null || !mounted) return;
    await _moveSong(song.id, destinationColumnId);
  }

  Future<void> _moveSong(String songId, String destinationColumnId) async {
    final sourceColumn = _songList.columns.firstWhere(
      (column) => column.songs.any((song) => song.id == songId),
    );
    final destinationColumn = _songList.columns.firstWhere(
      (column) => column.id == destinationColumnId,
    );
    final song = sourceColumn.songs.firstWhere((item) => item.id == songId);
    if (!song.canEdit ||
        sourceColumn.songs.any((item) => !item.canEdit) ||
        destinationColumn.songs.any((item) => !item.canEdit)) {
      _showError(StateError('Only personal songs can be moved'));
      return;
    }

    _pendingReorders++;
    _localBoardRevision++;
    setState(() {
      _songList = _songList.copyWith(
        columns: _songList.columns
            .map(
              (column) => switch (column.id) {
                final id when id == sourceColumn.id => column.copyWith(
                  songs: column.songs
                      .where((item) => item.id != songId)
                      .toList(growable: false),
                ),
                final id when id == destinationColumn.id => column.copyWith(
                  songs: [...column.songs, song],
                ),
                _ => column,
              },
            )
            .toList(growable: false),
      );
    });
    try {
      await _repository.moveSong(songId, destinationColumnId);
    } catch (error) {
      if (mounted) _showError(error);
    } finally {
      _pendingReorders--;
      if (mounted && _pendingReorders == 0) {
        await _loadBoard(showLoading: false);
      }
    }
  }

  Future<bool> _saveBoard(SongList board) async {
    setState(() => _songList = board);
    ref.read(boardDetailIsMutatingProvider.notifier).state = true;
    try {
      await _repository.updateBoard(board);
      return true;
    } on Exception catch (error) {
      if (mounted) _showError(error);
      return false;
    } finally {
      ref.read(boardDetailIsMutatingProvider.notifier).state = false;
    }
  }

  Future<void> _removeLabel(String id) async {
    try {
      await _repository.deleteLabel(id);
      if (!mounted) return;
      final labels = _songList.labels.where((label) => label.id != id).toList();
      setState(() => _songList = _songList.copyWith(labels: labels));
      Navigator.pop(context);
      _showMenu();
    } on Exception catch (error) {
      if (mounted) _showError(error);
    }
  }

  void _showMenu() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true, // ADD THIS - keeps content away from status bar
      backgroundColor: AppColors.bgCard,
      builder: (_) => MenuBottomSheet(
        readOnly: !_songList.canEdit,
        showArtist: _songList.showArtist,
        showBpm: _songList.showBpm,
        darkMode: _songList.darkMode,
        artists: _songList.artists,
        labels: _songList.labels,
        onShowArtistChanged: (val) =>
            _saveBoard(_songList.copyWith(showArtist: val)),
        onShowBpmChanged: (val) => _saveBoard(_songList.copyWith(showBpm: val)),
        onDarkModeChanged: (val) =>
            _saveBoard(_songList.copyWith(darkMode: val)),
        onAddArtist: _showArtistDialog,
        onRemoveArtist: _removeArtist,
        onUpdateArtist: _showArtistDialog,
        onAddLabel: (name) {
          _showAddLabelDialog();
        },
        onUpdateLabel: (label) {
          _showAddLabelDialog(label);
        },
        onRemoveLabel: _removeLabel,
        onExport: () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Export feature coming soon')),
          );
        },
        onImport: () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Import feature coming soon')),
          );
        },
      ),
    );
  }

  Future<void> _showArtistDialog([Artist? existing]) async {
    Navigator.pop(context);
    final name = await showNamePrompt(
      context,
      title: existing == null ? 'Add Artist' : 'Rename Artist',
      initialValue: existing?.name ?? '',
      label: 'Artist name',
      actionLabel: existing == null ? 'Add' : 'Save',
    );
    if (name == null || name == existing?.name) return;

    try {
      final saved = existing == null
          ? await _repository.createArtist(name)
          : await _repository.updateArtist(existing.copyWith(name: name));
      if (!mounted) return;
      final artists = existing == null
          ? [..._songList.artists, saved]
          : _songList.artists
                .map((artist) => artist.id == saved.id ? saved : artist)
                .toList();
      setState(() => _songList = _songList.copyWith(artists: artists));
      if (existing == null) {
        AppSnackbar.showSuccess(context, 'Artist created');
      }
      _showMenu();
    } on Exception catch (error) {
      if (mounted) _showError(error);
    }
  }

  Future<void> _removeArtist(String id) async {
    try {
      await _repository.deleteArtist(id);
      final board = await _repository.fetchBoard(widget.boardId);
      if (!mounted) return;
      setState(() => _songList = board);
      Navigator.pop(context);
      _showMenu();
    } on Exception catch (error) {
      if (mounted) _showError(error);
    }
  }

  void _showAddLabelDialog([Label? existingLabel]) {
    Navigator.pop(context); // Close menu first

    final controller = TextEditingController(text: existingLabel?.name);
    Color selectedColor = existingLabel?.color ?? Colors.blue;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: selectedColor.withValues(alpha: .12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.label_rounded,
                        color: selectedColor,
                        size: 34,
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'Create Label',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Create a label to organize your songs.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 24),

                    TextField(
                      controller: controller,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Label name',
                        prefixIcon: const Icon(Icons.edit_outlined),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: selectedColor,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Choose a color',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 12,
                      runSpacing: 12,
                      children:
                          [
                            Colors.blue,
                            Colors.red,
                            Colors.green,
                            Colors.orange,
                            Colors.purple,
                            Colors.pink,
                            Colors.teal,
                            Colors.amber,
                          ].map((color) {
                            final selected = selectedColor == color;

                            return InkWell(
                              borderRadius: BorderRadius.circular(50),
                              onTap: () {
                                setDialogState(() {
                                  selectedColor = color;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                width: selected ? 25 : 20,
                                height: selected ? 25 : 20,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: selected
                                        ? Colors.black87
                                        : Colors.transparent,
                                    width: 3,
                                  ),
                                  boxShadow: selected
                                      ? [
                                          BoxShadow(
                                            color: color.withValues(alpha: .35),
                                            blurRadius: 10,
                                            spreadRadius: 2,
                                          ),
                                        ]
                                      : null,
                                ),
                                child: selected
                                    ? const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 20,
                                      )
                                    : null,
                              ),
                            );
                          }).toList(),
                    ),

                    const SizedBox(height: 32),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pop(dialogContext);
                              _showMenu();
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text('Cancel'),
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: selectedColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () async {
                              final name = controller.text.trim();

                              if (name.isEmpty) return;

                              try {
                                final label = existingLabel == null
                                    ? await _repository.createLabel(
                                        _songList.id,
                                        name,
                                        selectedColor,
                                      )
                                    : await _repository.updateLabel(
                                        _songList.id,
                                        existingLabel.copyWith(
                                          name: name,
                                          color: selectedColor,
                                        ),
                                      );
                                if (!mounted || !dialogContext.mounted) return;
                                setState(() {
                                  final labels = existingLabel == null
                                      ? [..._songList.labels, label]
                                      : _songList.labels
                                            .map(
                                              (item) => item.id == label.id
                                                  ? label
                                                  : item,
                                            )
                                            .toList();
                                  _songList = _songList.copyWith(
                                    labels: labels,
                                  );
                                });
                                Navigator.pop(dialogContext);
                                if (existingLabel == null) {
                                  AppSnackbar.showSuccess(
                                    context,
                                    'Label created',
                                  );
                                }
                                _showMenu();
                              } on Exception catch (error) {
                                if (mounted) _showError(error);
                              }
                            },
                            child: const Text(
                              'Save Label',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showColumnMenu(SongColumn column) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: AppColors.bgCard,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Rename'),
              onTap: () {
                Navigator.pop(ctx);
                _renameColumn(column);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () async {
                Navigator.pop(ctx);
                try {
                  await _repository.deleteColumn(column.id);
                  if (!mounted) return;
                  final columns = _songList.columns
                      .where((c) => c.id != column.id)
                      .toList();
                  setState(
                    () => _songList = _songList.copyWith(columns: columns),
                  );
                } on Exception catch (error) {
                  if (mounted) _showError(error);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _renameColumn(SongColumn column) async {
    final name = await showNamePrompt(
      context,
      title: 'Rename List',
      initialValue: column.title,
      label: 'List name',
    );
    if (name == null || name == column.title) return;
    final updatedColumn = column.copyWith(title: name);
    try {
      await _repository.updateColumn(updatedColumn);
      if (!mounted) return;
      final columns = _songList.columns
          .map((item) => item.id == column.id ? updatedColumn : item)
          .toList();
      setState(() => _songList = _songList.copyWith(columns: columns));
    } on Exception catch (error) {
      if (mounted) _showError(error);
    }
  }

  void _showSearch() {
    setState(() {
      _isSearchMode = true;
    });
  }

  void _closeSearch() {
    setState(() {
      _isSearchMode = false;
      _searchController.clear();
      _searchQuery = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.bg,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_loadError != null) {
      return Scaffold(
        backgroundColor: AppColors.bg,
        appBar: AppBar(),
        body: Center(
          child: FilledButton(
            onPressed: _loadBoard,
            child: const Text('Retry loading board'),
          ),
        ),
      );
    }

    final filteredColumns = BoardFilter.columns(
      _songList.columns,
      query: _searchQuery,
    );
    final hasFilters =
        _activeKey != null ||
        _activeAccidental != null ||
        _searchQuery.isNotEmpty;
    final canMutate = _songList.canEdit && (!_isViewMode || _isEditMode);
    final canReorder = !hasFilters && canMutate;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(_isSearchMode ? Icons.arrow_back : Icons.arrow_back),
          onPressed: _isSearchMode
              ? _closeSearch
              : () => Navigator.of(context).pop(),
        ),
        title: _isSearchMode
            ? TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                autofocus: true,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                cursorColor: const Color.fromARGB(255, 235, 234, 234),
                decoration: const InputDecoration(
                  hintText: 'Search songs and lists...',
                  hintStyle: TextStyle(color: Colors.white70, fontSize: 16),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  filled: true,
                  fillColor: Colors.transparent,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
                onSubmitted: (value) {
                  ref.read(searchHistoryProvider.notifier).addSearch(value);
                  _hideSuggestions();
                  _searchFocusNode.unfocus();
                },
              )
            : Text(_songList.name),
        actions: _isSearchMode
            ? [
                if (_searchQuery.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear, size: 22),
                    onPressed: () {
                      _searchController.clear();
                    },
                  ),
              ]
            : [
                // Search
                IconButton(
                  icon: const Icon(Icons.search, size: 22),
                  onPressed: _showSearch,
                ),
                // Menu (three dots)
                IconButton(
                  icon: const Icon(Icons.more_vert, size: 22),
                  onPressed: _showMenu,
                ),
                // Toggle between Edit and View icons
                if (_songList.canEdit)
                  IconButton(
                    icon: Icon(
                      _isViewMode && !_isEditMode
                          ? Icons.edit
                          : Icons.visibility,
                      size: _isViewMode && !_isEditMode ? 20 : 22,
                    ),
                    onPressed: () {
                      setState(() {
                        if (!_isViewMode) {
                          // Click eye icon Ã¢â€ â€™ enter view mode
                          _isViewMode = true;
                          _isEditMode = false;
                        } else if (!_isEditMode) {
                          // Click edit icon Ã¢â€ â€™ enter edit mode
                          _isEditMode = true;
                        } else {
                          // Click eye icon again Ã¢â€ â€™ exit edit mode, stay in view mode
                          _isEditMode = false;
                        }
                      });
                    },
                  ),
              ],
      ),
      body: Column(
        children: [
          // Search suggestions overlay
          if (_isSearchMode && _searchSuggestions.isNotEmpty)
            _buildSearchSuggestions(),

          // Key filter bar - hide when search has no results
          if (filteredColumns.isNotEmpty)
            KeyFilterBar(
              activeKey: _activeKey,
              activeAccidental: _activeAccidental,
              onKeySelected: (key) {
                setState(() => _activeKey = key);
              },
              onAccidentalSelected: (acc) {
                setState(() => _activeAccidental = acc);
              },
              onClear: () {
                setState(() {
                  _activeKey = null;
                  _activeAccidental = null;
                });
              },
            ),

          // Columns (horizontal scrolling)
          Expanded(
            child: filteredColumns.isEmpty
                ? _searchQuery.isNotEmpty
                      // Search returned no results
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 64,
                                color: Colors.white.withValues(alpha: 0.55),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'No results found',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Try a different search term',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        )
                      // Board is empty
                      : Center(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.view_column_outlined,
                                  size: 64,
                                  color: Colors.white.withValues(alpha: 0.55),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'No song lists yet',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Create your first song list to get started.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withValues(alpha: 0.7),
                                  ),
                                ),

                                if (canMutate) ...[
                                  const SizedBox(height: 24),
                                  ElevatedButton.icon(
                                    onPressed: _addColumn,
                                    icon: const Icon(Icons.add),
                                    label: const Text('Create Song List'),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        )
                // Board has columns
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...filteredColumns.map((column) {
                          final filteredSongs = BoardFilter.songs(
                            column.songs,
                            key: _activeKey,
                            accidental: _activeAccidental,
                          );
                          final filteredColumn = column.copyWith(
                            songs: filteredSongs,
                          );

                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: SongColumnWidget(
                              column: filteredColumn,
                              showArtist: _songList.showArtist,
                              showBpm: _songList.showBpm,
                              isViewMode: !canMutate,
                              availableLabels: _songList.labels,
                              onAddSong: () =>
                                  _addSongToColumn(filteredColumn.id),
                              onMenuTap: () => _showColumnMenu(filteredColumn),
                              onSongTap: !canMutate
                                  ? null
                                  : (song) {
                                      if (song.canEdit) {
                                        _editSong(song, column.id);
                                      }
                                    },
                              onMoveSong: !canMutate
                                  ? null
                                  : (song) => unawaited(
                                      _showMoveSongSheet(song, column.id),
                                    ),
                              onPersonalEdit: _editPersonalSong,
                              onReorderSongs: !canReorder
                                  ? null
                                  : (oldIndex, newIndex) => unawaited(
                                      _reorderSongs(
                                        column.id,
                                        oldIndex,
                                        newIndex,
                                      ),
                                    ),
                            ),
                          );
                        }),
                        if (canMutate) AddColumnButton(onTap: _addColumn),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
