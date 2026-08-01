import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/models/song_list.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../data/board_repository.dart';
import '../widgets/name_prompt_dialog.dart';

class BoardSelectorPage extends ConsumerStatefulWidget {
  const BoardSelectorPage({super.key});

  @override
  ConsumerState<BoardSelectorPage> createState() => _BoardSelectorPageState();
}

class _BoardSelectorPageState extends ConsumerState<BoardSelectorPage> {
  late Future<List<SongList>> _boards;
  StreamSubscription<void>? _boardSubscription;

  BoardRepository get _repository => ref.read(boardRepositoryProvider);

  @override
  void initState() {
    super.initState();
    _boards = _repository.fetchBoards();
    _boardSubscription = _repository.watchChanges().listen((_) {
      if (mounted) _reload();
    });
  }

  @override
  void dispose() {
    _boardSubscription?.cancel();
    super.dispose();
  }

  void _reload() {
    setState(() {
      _boards = _repository.fetchBoards();
    });
  }

  Future<void> _createBoard() async {
    final name = await showNamePrompt(
      context,
      title: 'Create Board',
      label: 'Board name',
    );
    if (name == null) return;
    await _runMutation(
      () => _repository.createBoard(name),
      successMessage: 'Board created',
    );
  }

  Future<void> _renameBoard(SongList board) async {
    final name = await showNamePrompt(
      context,
      title: 'Rename Board',
      initialValue: board.name,
      label: 'Board name',
    );
    if (name == null || name == board.name) return;
    await _runMutation(
      () => _repository.updateBoard(board.copyWith(name: name)),
    );
  }

  Future<void> _deleteBoard(SongList board) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete board?'),
        content: Text('"${board.name}" and all its content will be deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _runMutation(() => _repository.deleteBoard(board.id));
    }
  }

  Future<void> _runMutation(
    Future<Object?> Function() mutation, {
    String? successMessage,
  }) async {
    try {
      await mutation();
      if (mounted) {
        _reload();
        if (successMessage != null) {
          AppSnackbar.showSuccess(context, successMessage);
        }
      }
    } on Exception catch (error) {
      if (mounted) _showError(error);
    }
  }

  void _showError(Object error) {
    debugPrint('Board operation failed: $error');
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Could not save change: $error')));
  }

  Future<void> _signOut() async {
    await ref.read(authControllerProvider).signOut();
    if (mounted) {
      AppSnackbar.showSuccess(context, 'Signed out successfully');
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Venue Boards'),
        centerTitle: true,
        actions: [_ProfileMenu(onSignOut: _signOut)],
      ),
      body: FutureBuilder<List<SongList>>(
        future: _boards,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _LoadError(onRetry: _reload);
          }
          final boards = snapshot.data ?? const [];
          return RefreshIndicator(
            onRefresh: () async {
              _reload();
              await _boards;
            },
            child: boards.isEmpty
                ? const _EmptyBoards()
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: boards.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final board = boards[index];
                      return _BoardTile(
                        board: board,
                        onTap: () async {
                          await context.push('/board/${board.id}');
                          if (mounted) _reload();
                        },
                        onRename: board.canEdit
                            ? () => _renameBoard(board)
                            : null,
                        onDelete: board.canEdit
                            ? () => _deleteBoard(board)
                            : null,
                      );
                    },
                  ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: ElevatedButton.icon(
          onPressed: _createBoard,
          icon: const Icon(Icons.add),
          label: const Text('Create New Board'),
        ),
      ),
    );
  }
}

class _BoardTile extends StatelessWidget {
  const _BoardTile({
    required this.board,
    required this.onTap,
    this.onRename,
    this.onDelete,
  });

  final SongList board;
  final VoidCallback onTap;
  final VoidCallback? onRename;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final songCount = board.columns.fold<int>(
      0,
      (total, column) => total + column.songs.length,
    );
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: const Icon(Icons.library_music, color: AppColors.accent),
        title: Row(
          children: [
            Expanded(child: Text(board.name)),
            const SizedBox(width: 8),
            _BoardCreatorBadge(board: board),
          ],
        ),
        subtitle: Text('${board.columns.length} lists · $songCount songs'),
        trailing: onDelete == null
            ? const Icon(Icons.chevron_right)
            : PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'rename') onRename?.call();
                  if (value == 'delete') onDelete?.call();
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'rename', child: Text('Rename')),
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
      ),
    );
  }
}

class _BoardCreatorBadge extends StatelessWidget {
  const _BoardCreatorBadge({required this.board});

  final SongList board;

  @override
  Widget build(BuildContext context) {
    final bool isUserCreated = board.creatorType == BoardCreatorType.user;

    final bool isReadOnly = !isUserCreated && !board.canEdit;

    late final Color color;
    late final IconData icon;
    late final String text;

    if (isUserCreated) {
      color = Colors.green;
      icon = Icons.person_rounded;
      text = 'Mine';
    } else if (isReadOnly) {
      color = Colors.orange;
      icon = Icons.lock_outline_rounded;
      text = 'Read Only';
    } else {
      color = AppColors.accent;
      icon = Icons.verified_user_rounded;
      text = 'Official';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withValues(alpha: .28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: .2,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileMenu extends StatelessWidget {
  const _ProfileMenu({required this.onSignOut});

  final Future<void> Function() onSignOut;

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    final metadata = user?.userMetadata ?? {};

    final avatarUrl = metadata['avatar_url'] as String?;

    final displayName =
        (metadata['full_name'] ??
                metadata['name'] ??
                user?.email?.split('@').first ??
                'User')
            .toString();

    final email = user?.email ?? '';

    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'logout') {
          onSignOut();
        }
      },
      offset: const Offset(0, 60),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      icon: Container(
        padding: const EdgeInsets.all(2.5),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: CircleAvatar(
          radius: 18,
          backgroundColor: Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest,
          backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
          child: avatarUrl == null
              ? Text(
                  displayName[0].toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                )
              : null,
        ),
      ),
      itemBuilder: (_) => [
        const PopupMenuItem<String>(
          enabled: false,
          padding: EdgeInsets.zero,
          height: 12,
          child: SizedBox.shrink(),
        ),
        PopupMenuItem<String>(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displayName,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              Text(email, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout_rounded, color: Colors.red),
              SizedBox(width: 12),
              Text('Log Out', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }
}

class _EmptyBoards extends StatelessWidget {
  const _EmptyBoards();

  @override
  Widget build(BuildContext context) => ListView(
    children: const [
      SizedBox(height: 180),
      Icon(Icons.library_music_outlined, size: 64, color: Colors.white54),
      SizedBox(height: 16),
      Center(
        child: Text(
          'No boards available',
          style: TextStyle(color: Colors.white70, fontSize: 18),
        ),
      ),
    ],
  );
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Could not load boards'),
        const SizedBox(height: 8),
        FilledButton(onPressed: onRetry, child: const Text('Retry')),
      ],
    ),
  );
}
