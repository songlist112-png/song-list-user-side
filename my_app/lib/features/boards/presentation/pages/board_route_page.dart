import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/last_board_store.dart';
import 'board_view_page.dart';

class BoardRoutePage extends ConsumerStatefulWidget {
  const BoardRoutePage({
    required this.boardId,
    this.restoredFromPreviousSession = false,
    super.key,
  });

  final String boardId;
  final bool restoredFromPreviousSession;

  @override
  ConsumerState<BoardRoutePage> createState() => _BoardRoutePageState();
}

class _BoardRoutePageState extends ConsumerState<BoardRoutePage> {
  bool _isLeaving = false;

  Future<void> _leaveBoard() async {
    if (_isLeaving) return;
    _isLeaving = true;
    try {
      await ref.read(lastBoardStoreProvider).clear();
    } on Exception catch (error, stackTrace) {
      debugPrint('Could not clear remembered board: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) => PopScope<Object?>(
    canPop: false,
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop) unawaited(_leaveBoard());
    },
    child: BoardViewPage(
      boardId: widget.boardId,
      onExit: _leaveBoard,
      onRestoredBoardUnavailable: widget.restoredFromPreviousSession
          ? _leaveBoard
          : null,
    ),
  );
}
