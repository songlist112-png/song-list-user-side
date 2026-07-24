import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/models/artist.dart';
import '../../../../shared/models/song.dart';
import '../../../../shared/models/song_column.dart';
import '../../../../shared/models/song_list.dart';

class BoardSelectorPage extends StatefulWidget {
  const BoardSelectorPage({super.key});

  @override
  State<BoardSelectorPage> createState() => _BoardSelectorPageState();
}

class _BoardSelectorPageState extends State<BoardSelectorPage> {
  // In-memory data — will be replaced with Supabase later
  final List<SongList> _songLists = [
    SongList(
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
              artistName: 'Ed Sheeran',
              attachments: ['file.pdf'],
            ),
          ],
          order: 0,
        ),
        const SongColumn(id: 'c2', title: 'New List', order: 1),
      ],
      artists: [const Artist(id: 'a1', name: 'Ed Sheeran')],
      showArtist: true,
      createdAt: DateTime.now(),
    ),
    SongList(
      id: '2',
      name: 'My own list',
      columns: [
        SongColumn(
          id: 'c3',
          title: 'List 1',
          songs: [
            const Song(
              id: 's2',
              title: 'Perfect',
              key: 'G#m',
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
    ),
  ];

  void _createNewSongList() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
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
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.library_music_rounded,
                    color: Colors.blue.shade700,
                    size: 34,
                  ),
                ),

                const SizedBox(height: 20),

                // Title
                const Text(
                  'Create New Board',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                    letterSpacing: -.3,
                  ),
                ),

                const SizedBox(height: 10),

                // Subtitle
                Text(
                  'Organize your songs by creating a new board.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 28),

                // TextField
                TextField(
                  controller: controller,
                  autofocus: true,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    hintText: 'Enter board name',
                    prefixIcon: const Icon(Icons.edit_outlined),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 18,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: Colors.blue.shade600,
                        width: 1.5,
                      ),
                    ),
                  ),
                  onSubmitted: (_) {
                    final name = controller.text.trim();

                    if (name.isEmpty) return;

                    setState(() {
                      _songLists.add(
                        SongList(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          name: name,
                          createdAt: DateTime.now(),
                        ),
                      );
                    });

                    Navigator.pop(dialogContext);
                  },
                ),

                const SizedBox(height: 28),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black87,
                          side: BorderSide(color: Colors.grey.shade300),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          final name = controller.text.trim();

                          if (name.isEmpty) return;

                          setState(() {
                            _songLists.add(
                              SongList(
                                id: DateTime.now().millisecondsSinceEpoch
                                    .toString(),
                                name: name,
                                createdAt: DateTime.now(),
                              ),
                            );
                          });

                          Navigator.pop(dialogContext);
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Create',
                          style: TextStyle(fontWeight: FontWeight.w700),
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
  }

  void _deleteSongList(String id) {
    setState(() {
      _songLists.removeWhere((l) => l.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Venue Boards'),
        centerTitle: true,
        actions: [
          Builder(
            builder: (context) {
              final user = Supabase.instance.client.auth.currentUser;
              final avatarUrl = user?.userMetadata?['avatar_url'];
              final email = user?.email ?? 'Unknown';
              final name =
                  user?.userMetadata?['full_name'] ??
                  user?.userMetadata?['name'] ??
                  'User';

              return PopupMenuButton<String>(
                offset: const Offset(0, 48),
                icon: Container(
                  width: 40, // Increased size for better visibility
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: .4),
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: .1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 18, // Slightly smaller to show the border
                    backgroundColor: Colors.white.withValues(alpha: .15),
                    backgroundImage: avatarUrl != null
                        ? NetworkImage(avatarUrl)
                        : null,
                    child: avatarUrl == null
                        ? Icon(
                            Icons.person,
                            color: Colors.white.withValues(alpha: .9),
                            size: 22,
                          )
                        : null,
                  ),
                ),
                onSelected: (value) async {
                  if (value == 'logout') {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => Center(
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.bgCard,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const CupertinoActivityIndicator(
                            radius: 16,
                            color: AppColors.accent,
                          ),
                        ),
                      ),
                    );
                    try {
                      await GoogleSignIn().signOut();
                    } catch (_) {}
                    await Supabase.instance.client.auth.signOut();
                    if (context.mounted) {
                      Navigator.of(context).pop(); // Dismiss loading dialog
                      context.go('/login');
                    }
                  }
                },
                itemBuilder: (context) {
                  return [
                    PopupMenuItem<String>(
                      enabled: false,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.text,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            email,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem<String>(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(
                            Icons.logout,
                            size: 18,
                            color: AppColors.textMuted,
                          ),
                          SizedBox(width: 10),
                          Text('Log Out'),
                        ],
                      ),
                    ),
                  ];
                },
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: _songLists.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.library_music_outlined,
                            size: 64,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No song lists yet',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Create your board to get started',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      itemCount: _songLists.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final list = _songLists[index];
                        return _SongListTile(
                          songList: list,
                          onTap: () {
                            context.push('/board/${list.id}');
                          },
                          onDelete: () => _deleteSongList(list.id),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),
            // Create new button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _createNewSongList,
                icon: const Icon(Icons.add),
                label: const Text('Create New Board'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: AppColors.bgDark,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
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

class _SongListTile extends StatelessWidget {
  final SongList songList;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _SongListTile({
    required this.songList,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.bgCard,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              const Icon(
                Icons.library_music,
                color: AppColors.accent,
                size: 22,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      songList.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${songList.columns.length} lists · ${songList.columns.fold<int>(0, (sum, c) => sum + c.songs.length)} songs',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert,
                  size: 20,
                  color: AppColors.textMuted,
                ),
                onSelected: (val) {
                  if (val == 'delete') onDelete();
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
