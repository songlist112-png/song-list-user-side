import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/models/artist.dart';
import '../../../../shared/models/label.dart';
import '../../../../shared/models/song.dart';
import '../../../../shared/models/song_column.dart';
import '../../../../shared/models/song_list.dart';
import '../../../songs/presentation/pages/add_edit_song_page.dart';
import '../widgets/add_column_button.dart';
import '../widgets/key_filter_bar.dart';
import '../widgets/menu_bottom_sheet.dart';
import '../widgets/song_column_widget.dart';

class BoardViewPage extends StatefulWidget {
  final String boardId;

  const BoardViewPage({super.key, required this.boardId});

  @override
  State<BoardViewPage> createState() => _BoardViewPageState();
}

class _BoardViewPageState extends State<BoardViewPage> {
  // Sample data — will be replaced with real data later
  late SongList _songList;

  // Key filter state
  String? _activeKey;
  String? _activeAccidental;

  // View mode state
  bool _isViewMode = false;
  bool _isEditMode = false;

  // Search state
  bool _isSearchMode = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Load sample data based on board ID
    _songList = _loadSampleData();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  SongList _loadSampleData() {
    if (widget.boardId == '2') {
      return SongList(
        id: '2',
        name: 'My own list',
        columns: [
          SongColumn(
            id: 'c3',
            title: 'List 1',
            songs: [
              const Song(
                id: 's2',
                title: 'Perfectt',
                key: 'G',
                keyType: 'Minor',
                artistName: 'Ed Sheeran',
                attachments: ['file.pdf'],
              ),
            ],
            order: 0,
          ),
          const SongColumn(id: 'c4', title: 'New List', order: 1),
        ],
        artists: [const Artist(id: 'a1', name: 'Ed Sheeran')],
        showArtist: true,
        createdAt: DateTime.now(),
      );
    }
    return SongList(
      id: '1',
      name: 'My Song List',
      columns: [
        SongColumn(
          id: 'c1',
          title: 'List 1',
          songs: [
            const Song(
              id: 's1',
              title: 'Perfect',
              key: 'G',
              keyType: 'Minor',
              lyrics: ' Lyrics here He...Lyrics here He... Lyrics here He...',
              artistName: 'Ed Sheeran',
              attachments: ['file.pdf'],
            ),
            const Song(
              id: 's2',
              title: 'The Hard Way',
              key: 'C',
              keyType: 'Minor',
              lyrics:
                  ' The Hard way yeah yeah ohh oh nono make me hard so close.',
              artistName: 'Paul',
              attachments: ['file.pdf'],
            ),
          ],
          order: 0,
        ),
        const SongColumn(
          id: 'c2',
          title: 'New List',
          songs: [
            Song(
              id: 's1',
              title: 'Im Board',
              key: 'A',
              keyType: 'Minor',
              lyrics: ' Lyrics here He...Lyrics here He... Lyrics here He...',
              artistName: 'Mr. Cupido',
              attachments: ['file.pdf'],
            ),
          ],
          order: 1,
        ),
        const SongColumn(id: 'c5', title: 'New List', order: 2),
      ],
      artists: [const Artist(id: 'a1', name: 'Ed Sheeran')],
      showArtist: true,
      createdAt: DateTime.now(),
    );
  }

  void _addColumn() {
    final controller = TextEditingController(text: 'New List');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add List'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'List name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                setState(() {
                  final newColumns = List<SongColumn>.from(_songList.columns)
                    ..add(
                      SongColumn(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        title: name,
                        order: _songList.columns.length,
                      ),
                    );
                  _songList = _songList.copyWith(columns: newColumns);
                });
              }
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
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
        onSave: (song) {
          setState(() {
            final columns = _songList.columns.map((col) {
              if (col.id == columnId) {
                return col.copyWith(
                  songs: List<Song>.from(col.songs)..add(song),
                );
              }
              return col;
            }).toList();
            _songList = _songList.copyWith(columns: columns);
          });
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
        onSave: (updatedSong) {
          setState(() {
            final columns = _songList.columns.map((col) {
              if (col.id == columnId) {
                final updatedSongs = col.songs.map((s) {
                  return s.id == updatedSong.id ? updatedSong : s;
                }).toList();
                return col.copyWith(songs: updatedSongs);
              }
              return col;
            }).toList();
            _songList = _songList.copyWith(columns: columns);
          });
        },
      ),
    );
  }

  void _reorderSongs(String columnId, int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    setState(() {
      final columns = _songList.columns.map((col) {
        if (col.id == columnId) {
          final songs = List<Song>.from(col.songs);
          final song = songs.removeAt(oldIndex);
          songs.insert(newIndex, song);
          return col.copyWith(songs: songs);
        }
        return col;
      }).toList();
      _songList = _songList.copyWith(columns: columns);
    });
  }

  void _showMenu() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true, // ADD THIS - keeps content away from status bar
      backgroundColor: AppColors.bgCard,
      builder: (_) => MenuBottomSheet(
        showArtist: _songList.showArtist,
        showBpm: _songList.showBpm,
        darkMode: _songList.darkMode,
        artists: _songList.artists,
        labels: _songList.labels,
        onShowArtistChanged: (val) {
          setState(() {
            _songList = _songList.copyWith(showArtist: val);
          });
        },
        onShowBpmChanged: (val) {
          setState(() {
            _songList = _songList.copyWith(showBpm: val);
          });
        },
        onDarkModeChanged: (val) {
          setState(() {
            _songList = _songList.copyWith(darkMode: val);
          });
        },
        onAddArtist: (name) {
          // Will show a text field to add artist name
          _showAddArtistDialog();
        },
        onRemoveArtist: (id) {
          setState(() {
            final updatedArtists = _songList.artists
                .where((a) => a.id != id)
                .toList();
            _songList = _songList.copyWith(artists: updatedArtists);
          });
          Navigator.pop(context);
          _showMenu(); // Re-open to reflect changes
        },
        onUpdateArtist: (_) {},
        onAddLabel: (name) {
          _showAddLabelDialog();
        },
        onRemoveLabel: (id) {
          setState(() {
            final updatedLabels = _songList.labels
                .where((l) => l.id != id)
                .toList();
            _songList = _songList.copyWith(labels: updatedLabels);
          });
          Navigator.pop(context);
          _showMenu(); // Re-open to reflect changes
        },
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

  void _showAddArtistDialog() {
    Navigator.pop(context); // Close menu first

    final controller = TextEditingController();
    final themeColor = const Color.fromARGB(255, 16, 135, 225);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            // Get screen size for responsive design
            final screenWidth = MediaQuery.of(context).size.width;
            final bool isSmallScreen = screenWidth < 380;

            // Responsive sizing
            final double iconSize = isSmallScreen ? 46 : 58;
            final double titleFontSize = isSmallScreen ? 20 : 24;
            final double subtitleFontSize = isSmallScreen ? 13 : 15;
            final double spacing = isSmallScreen ? 12 : 20;
            final double padding = isSmallScreen ? 16 : 24;

            return Dialog(
              backgroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: EdgeInsets.all(padding),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon
                    Container(
                      width: iconSize,
                      height: iconSize,
                      decoration: BoxDecoration(
                        color: themeColor.withValues(alpha: .12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.person_add_alt_1_rounded,
                        color: themeColor,
                        size: iconSize * 0.5,
                      ),
                    ),

                    SizedBox(height: spacing),

                    // Title
                    Text(
                      'Add Artist',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),

                    SizedBox(height: spacing * 0.4),

                    // Subtitle
                    Text(
                      'Add a new artist to your collection.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: subtitleFontSize,
                        color: Colors.grey,
                        height: 1.5,
                      ),
                    ),

                    SizedBox(height: spacing * 1.2),

                    // TextField
                    TextField(
                      controller: controller,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Artist name',
                        hintStyle: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                        prefixIcon: Icon(
                          Icons.music_note_outlined,
                          size: isSmallScreen ? 18 : 24,
                          color: themeColor,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 12 : 16,
                          vertical: isSmallScreen ? 12 : 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: themeColor, width: 1.5),
                        ),
                      ),
                      onSubmitted: (value) {
                        _addArtist(controller, dialogContext);
                      },
                    ),

                    SizedBox(height: spacing * 1.6),

                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pop(dialogContext);
                              _showMenu();
                            },
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                vertical: isSmallScreen ? 12 : 15,
                                horizontal: isSmallScreen ? 8 : 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              textStyle: TextStyle(
                                fontSize: isSmallScreen ? 13 : 14,
                              ),
                              side: BorderSide(color: themeColor),
                            ),
                            child: Text(
                              'Cancel',
                              style: TextStyle(color: themeColor),
                            ),
                          ),
                        ),

                        SizedBox(width: isSmallScreen ? 8 : 12),

                        Expanded(
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: themeColor,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                vertical: isSmallScreen ? 12 : 15,
                                horizontal: isSmallScreen ? 8 : 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              textStyle: TextStyle(
                                fontSize: isSmallScreen ? 13 : 14,
                              ),
                            ),
                            onPressed: () {
                              _addArtist(controller, dialogContext);
                            },
                            child: Text(
                              'Add Artist',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: isSmallScreen ? 13 : 14,
                              ),
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

  // Helper method to add artist
  void _addArtist(
    TextEditingController controller,
    BuildContext dialogContext,
  ) {
    final name = controller.text.trim();

    if (name.isEmpty) return;

    setState(() {
      final updatedArtists = List<Artist>.from(_songList.artists)
        ..add(
          Artist(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: name,
          ),
        );
      _songList = _songList.copyWith(artists: updatedArtists);
    });

    Navigator.pop(dialogContext);
    _showMenu(); // Re-open menu
  }

  void _showAddLabelDialog() {
    Navigator.pop(context); // Close menu first

    final controller = TextEditingController();
    Color selectedColor = Colors.blue;

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
                            onPressed: () {
                              final name = controller.text.trim();

                              if (name.isEmpty) return;

                              setState(() {
                                final updatedLabels =
                                    List<Label>.from(_songList.labels)..add(
                                      Label(
                                        id: DateTime.now()
                                            .millisecondsSinceEpoch
                                            .toString(),
                                        name: name,
                                        color: selectedColor,
                                      ),
                                    );

                                _songList = _songList.copyWith(
                                  labels: updatedLabels,
                                );
                              });

                              Navigator.pop(dialogContext);
                              _showMenu();
                            },
                            child: const Text(
                              'Add Label',
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
              onTap: () {
                Navigator.pop(ctx);
                setState(() {
                  final columns = _songList.columns
                      .where((c) => c.id != column.id)
                      .toList();
                  _songList = _songList.copyWith(columns: columns);
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  void _renameColumn(SongColumn column) {
    final controller = TextEditingController(text: column.title);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename List'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                setState(() {
                  final columns = _songList.columns.map((c) {
                    return c.id == column.id ? c.copyWith(title: name) : c;
                  }).toList();
                  _songList = _songList.copyWith(columns: columns);
                });
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
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
    final filteredColumns = _getFilteredColumns();
    final bool hasFilters = _activeKey != null || _activeAccidental != null || _searchQuery.isNotEmpty;

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
                IconButton(
                  icon: Icon(
                    _isViewMode && !_isEditMode ? Icons.edit : Icons.visibility,
                    size: _isViewMode && !_isEditMode ? 20 : 22,
                  ),
                  onPressed: () {
                    setState(() {
                      if (!_isViewMode) {
                        // Click eye icon → enter view mode
                        _isViewMode = true;
                        _isEditMode = false;
                      } else if (!_isEditMode) {
                        // Click edit icon → enter edit mode
                        _isEditMode = true;
                      } else {
                        // Click eye icon again → exit edit mode, stay in view mode
                        _isEditMode = false;
                      }
                    });
                  },
                ),
              ],
      ),
      body: Column(
        children: [
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
            child: _getFilteredColumns().isEmpty
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

                                if (!_isViewMode || _isEditMode) ...[
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
                        ..._getFilteredColumns().map((column) {
                          final filteredSongs = _filterSongs(column.songs);
                          final filteredColumn = column.copyWith(
                            songs: filteredSongs,
                          );

                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: SongColumnWidget(
                              column: filteredColumn,
                              showArtist: _songList.showArtist,
                              showBpm: _songList.showBpm,
                              isViewMode: _isViewMode && !_isEditMode,
                              availableLabels: _songList.labels,
                              onAddSong: () =>
                                  _addSongToColumn(filteredColumn.id),
                              onMenuTap: () => _showColumnMenu(filteredColumn),
                              onSongTap: _isViewMode && !_isEditMode
                                  ? null
                                  : (song) => _editSong(song, column.id),
                              onReorderSongs: hasFilters
                                  ? null
                                  : (oldIndex, newIndex) =>
                                      _reorderSongs(column.id, oldIndex, newIndex),
                            ),
                          );
                        }),
                        if (!_isViewMode || _isEditMode)
                          AddColumnButton(onTap: _addColumn),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  List<Song> _filterSongs(List<Song> songs) {
    if (_activeKey == null && _activeAccidental == null) return songs;

    return songs.where((song) {
      if (song.key == null || song.key!.isEmpty) return false;

      if (_activeKey != null) {
        if (!song.key!.startsWith(_activeKey!)) return false;
      }

      if (_activeAccidental != null) {
        if (_activeAccidental == 'flat' && !song.key!.contains('b')) {
          return false;
        }
        if (_activeAccidental == 'sharp' && !song.key!.contains('#')) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  List<SongColumn> _getFilteredColumns() {
    if (_searchQuery.isEmpty) {
      return _songList.columns;
    }

    final query = _searchQuery.toLowerCase();
    final filteredColumns = <SongColumn>[];

    for (var column in _songList.columns) {
      // Check if column title matches
      final columnMatches = column.title.toLowerCase().contains(query);

      // Filter songs in this column
      final filteredSongs = column.songs.where((song) {
        // Search in song title
        if (song.title.toLowerCase().contains(query)) return true;
        // Search in artist name
        if (song.artistName != null &&
            song.artistName!.toLowerCase().contains(query)) {
          return true;
        }
        // Search in key
        if (song.key != null && song.key!.toLowerCase().contains(query)) {
          return true;
        }
        return false;
      }).toList();

      // Include column if it matches or has matching songs
      if (columnMatches || filteredSongs.isNotEmpty) {
        filteredColumns.add(
          column.copyWith(songs: columnMatches ? column.songs : filteredSongs),
        );
      }
    }

    return filteredColumns;
  }
}
