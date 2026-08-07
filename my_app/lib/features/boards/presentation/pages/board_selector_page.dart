import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/services/sync_service.dart';
import '../../../../shared/models/song_list.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../profile/providers/current_profile_provider.dart';
import '../../data/board_repository.dart';
import '../widgets/name_prompt_dialog.dart';

class BoardSelectorPage extends ConsumerStatefulWidget {
  const BoardSelectorPage({super.key});

  @override
  ConsumerState<BoardSelectorPage> createState() => _BoardSelectorPageState();
}

class _BoardSelectorPageState extends ConsumerState<BoardSelectorPage>
    with SingleTickerProviderStateMixin {
  static const _libraryTabIndex = 0;
  static const _mySongsTabIndex = 1;

  late Future<List<SongList>> _boards;
  late final TabController _tabController;
  StreamSubscription<void>? _boardSubscription;
  Timer? _reloadDebounce;
  List<SongList> _visibleBoards = const [];
  bool _hasLoaded = false;
  int _selectedTabIndex = _libraryTabIndex;

  BoardRepository get _repository => ref.read(boardRepositoryProvider);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this)
      ..addListener(_handleTabChanged);
    _boards = _fetchBoards();
    _boardSubscription = _repository.watchChanges().listen((_) {
      _reloadDebounce?.cancel();
      _reloadDebounce = Timer(const Duration(milliseconds: 120), () {
        if (mounted) _reload();
      });
    });
  }

  @override
  void dispose() {
    _tabController
      ..removeListener(_handleTabChanged)
      ..dispose();
    _boardSubscription?.cancel();
    _reloadDebounce?.cancel();
    super.dispose();
  }

  Future<List<SongList>> _fetchBoards() async {
    try {
      final boards = await _repository.fetchBoards();
      _visibleBoards = boards;
      return boards;
    } finally {
      _hasLoaded = true;
    }
  }

  void _reload() {
    _reloadDebounce?.cancel();
    setState(() {
      _boards = _fetchBoards();
    });
  }

  void _handleTabChanged() {
    if (!mounted || _selectedTabIndex == _tabController.index) return;
    setState(() => _selectedTabIndex = _tabController.index);
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

  Future<void> _showBoardActions(SongList board) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Rename'),
              onTap: () => Navigator.pop(context, 'rename'),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () => Navigator.pop(context, 'delete'),
            ),
          ],
        ),
      ),
    );
    if (!mounted) return;
    if (action == 'rename') await _renameBoard(board);
    if (action == 'delete') await _deleteBoard(board);
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
    final profile = ref.watch(currentProfileProvider).asData?.value;
    final canCreateBoard = profile != null && profile.role != 'admin';
    final showCreateButton =
        _selectedTabIndex == _mySongsTabIndex && canCreateBoard;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _WelcomeHeader(onSignOut: _signOut),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF4F4F4),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    _BoardTabs(controller: _tabController),
                    Expanded(
                      child: FutureBuilder<List<SongList>>(
                        future: _boards,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState !=
                                  ConnectionState.done &&
                              !_hasLoaded) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          if (snapshot.hasError && !_hasLoaded) {
                            return _LoadError(onRetry: _reload);
                          }

                          final boards = snapshot.data ?? _visibleBoards;

                          final libraryBoards = boards
                              .where(
                                (board) =>
                                    board.creatorType == BoardCreatorType.admin,
                              )
                              .toList(growable: false);

                          final userBoards = boards
                              .where(
                                (board) =>
                                    board.creatorType == BoardCreatorType.user,
                              )
                              .toList(growable: false);

                          return TabBarView(
                            controller: _tabController,
                            children: [
                              _BoardList(
                                boards: libraryBoards,
                                emptyMessage: 'No library songs available',
                                onRefresh: _refreshBoards,
                                onOpen: _openBoard,
                              ),
                              _BoardList(
                                boards: userBoards,
                                emptyMessage: 'No songs created yet',
                                onRefresh: _refreshBoards,
                                onOpen: _openBoard,
                                onLongPress: _showBoardActions,
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: showCreateButton
          ? FloatingActionButton(
              onPressed: _createBoard,
              tooltip: 'Create a new song list',
              backgroundColor: const Color(0xFF062A68),
              foregroundColor: Colors.white,
              shape: const CircleBorder(),
              child: const Icon(Icons.add, size: 30),
            )
          : null,
    );
  }

  Future<void> _refreshBoards() async {
    _reload();
    await _boards;
  }

  Future<void> _openBoard(SongList board) async {
    await context.push('/board/${board.id}');
    if (mounted) _reload();
  }
}

class _WelcomeHeader extends ConsumerWidget {
  const _WelcomeHeader({required this.onSignOut});

  final Future<void> Function() onSignOut;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final profile = ref.watch(currentProfileProvider).asData?.value;
    // final fullName = profile?.fullName?.trim();
    // final email = profile?.email ?? '';
    // final displayName = fullName != null && fullName.isNotEmpty
    //     ? fullName
    //     : email.isNotEmpty
    //     ? email.split('@').first
    //     : 'Song List user';

    return SizedBox(
      height: 132,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 12, 28),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Venue Boards',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.6,
                    ),
                  ),
                  // const SizedBox(height: 2),
                  // Text(
                  //   displayName,
                  //   maxLines: 1,
                  //   overflow: TextOverflow.ellipsis,
                  //   style: const TextStyle(color: Colors.white, fontSize: 16),
                  // ),
                ],
              ),
            ),
            _ProfileMenu(onSignOut: onSignOut),
          ],
        ),
      ),
    );
  }
}

class _BoardTabs extends StatelessWidget {
  const _BoardTabs({required this.controller});

  final TabController controller;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 80,
    child: TabBar(
      controller: controller,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      indicatorColor: AppColors.accent,
      indicatorSize: TabBarIndicatorSize.label,
      indicatorWeight: 3,
      dividerColor: Colors.transparent,
      labelColor: Colors.black,
      unselectedLabelColor: Colors.black,
      labelStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
      tabs: const [
        Tab(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.library_music_rounded),
              SizedBox(width: 8),
              Text('Boards'),
            ],
          ),
        ),
        Tab(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.queue_music_rounded),
              SizedBox(width: 8),
              Text('My Boards'),
            ],
          ),
        ),
      ],
    ),
  );
}

class _BoardList extends StatelessWidget {
  const _BoardList({
    required this.boards,
    required this.emptyMessage,
    required this.onRefresh,
    required this.onOpen,
    this.onLongPress,
  });

  final List<SongList> boards;
  final String emptyMessage;
  final Future<void> Function() onRefresh;
  final Future<void> Function(SongList board) onOpen;
  final Future<void> Function(SongList board)? onLongPress;

  @override
  Widget build(BuildContext context) => RefreshIndicator(
    onRefresh: onRefresh,
    child: boards.isEmpty
        ? _EmptyBoards(message: emptyMessage)
        : ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 96),
            itemCount: boards.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final board = boards[index];
              return _BoardTile(
                board: board,
                onTap: () => onOpen(board),
                onLongPress: board.canEdit && onLongPress != null
                    ? () => onLongPress!(board)
                    : null,
              );
            },
          ),
  );
}

class _BoardTile extends StatelessWidget {
  const _BoardTile({
    required this.board,
    required this.onTap,
    this.onLongPress,
  });

  final SongList board;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final songCount = board.columns.fold<int>(
      0,
      (total, column) => total + column.songs.length,
    );
    return Card(
      elevation: 3,
      shadowColor: Colors.black45,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: onTap,
        onLongPress: onLongPress,
        minTileHeight: 72,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: const Icon(
          Icons.music_note_rounded,
          color: Colors.black,
          size: 30,
        ),
        title: Text(
          board.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w400),
        ),
        subtitle: Text(
          '${board.columns.length} ${board.columns.length == 1 ? 'List' : 'Lists'}'
          '   $songCount ${songCount == 1 ? 'Song' : 'Songs'}',
          style: const TextStyle(fontSize: 11, color: Colors.black54),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: Colors.black,
          size: 28,
        ),
      ),
    );
  }
}

class _ProfileMenu extends ConsumerWidget {
  const _ProfileMenu({required this.onSignOut});

  static final _subscriptionUri = Uri.parse(
    'http://172.28.112.1:3000/user-subs',
  );

  final Future<void> Function() onSignOut;

  Future<void> _openSubscription(BuildContext context) async {
    try {
      final opened = await launchUrl(
        _subscriptionUri,
        mode: LaunchMode.externalApplication,
      );
      if (!opened && context.mounted) {
        _showLaunchError(context);
      }
    } on Exception {
      if (context.mounted) _showLaunchError(context);
    }
  }

  void _showLaunchError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not open subscription page')),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentProfileProvider).asData?.value;
    final fullName = profile?.fullName?.trim();
    final email = profile?.email ?? '';
    final displayName = fullName != null && fullName.isNotEmpty
        ? fullName
        : email.isNotEmpty
        ? email.split('@').first
        : 'User';
    final avatarPath = profile?.avatarLocalPath;
    final avatarFile = avatarPath == null ? null : File(avatarPath);
    final hasCachedAvatar = avatarFile?.existsSync() ?? false;
    final ImageProvider<Object>? avatarImage = hasCachedAvatar
        ? FileImage(avatarFile!)
        : null;

    if (!hasCachedAvatar && profile?.avatarUrl?.isNotEmpty == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(
          ref.read(syncServiceProvider).cacheProfileAvatar(profile!).catchError(
            (Object error) {
              debugPrint('Avatar cache failed: $error');
              return null;
            },
          ),
        );
      });
    }

    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'subscription') {
          unawaited(_openSubscription(context));
        } else if (value == 'support') {
          context.push('/support');
        } else if (value == 'logout') {
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
          radius: 20,
          backgroundColor: Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest,
          backgroundImage: avatarImage,
          child: avatarImage == null
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
          value: 'subscription',
          child: Row(
            children: [
              Icon(Icons.workspace_premium_outlined),
              SizedBox(width: 12),
              Text('Subscription'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'support',
          child: Row(
            children: [
              Icon(Icons.help_outline_rounded),
              SizedBox(width: 12),
              Text('Help & Feedback'),
            ],
          ),
        ),
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
  const _EmptyBoards({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => ListView(
    physics: const AlwaysScrollableScrollPhysics(),
    padding: const EdgeInsets.symmetric(horizontal: 24),
    children: [
      const SizedBox(height: 150),
      const Icon(Icons.library_music_outlined, size: 58, color: Colors.black26),
      const SizedBox(height: 14),
      Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.black45, fontSize: 16),
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
