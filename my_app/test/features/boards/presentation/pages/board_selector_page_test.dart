import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_app/core/services/sync_service.dart';
import 'package:my_app/database/local/models/profile.dart';
import 'package:my_app/features/boards/data/board_repository.dart';
import 'package:my_app/features/boards/presentation/pages/board_selector_page.dart';
import 'package:my_app/features/profile/providers/current_profile_provider.dart';
import 'package:my_app/shared/models/song_list.dart';

class _MockBoardRepository extends Mock implements BoardRepository {}

class _FakeSongList extends Fake implements SongList {}

void main() {
  setUpAll(() => registerFallbackValue(_FakeSongList()));

  testWidgets('shows sync progress until first account data reaches Isar', (
    tester,
  ) async {
    final boardChanges = StreamController<void>();
    final syncStatuses = StreamController<SyncStatus>();
    addTearDown(boardChanges.close);
    addTearDown(syncStatuses.close);
    final boards = <SongList>[];
    final repository = _stubRepository(boardChanges, boards);

    await _pumpSelector(
      tester,
      repository,
      syncStatuses: syncStatuses.stream,
      settle: false,
      openMyBoards: false,
    );
    expect(find.text('Loading your song library'), findsOneWidget);

    syncStatuses.add(
      const SyncStatus(phase: SyncPhase.offline, isInitialSync: true),
    );
    await tester.pump();
    expect(find.text('Waiting for a connection'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);

    syncStatuses.add(
      const SyncStatus(phase: SyncPhase.synchronizing, isInitialSync: true),
    );
    await tester.pump();
    boards.add(_libraryBoard());
    boardChanges.add(null);
    await tester.pump(const Duration(milliseconds: 130));
    await tester.pump();
    expect(find.text('Venue Library'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);

    syncStatuses.add(
      const SyncStatus(phase: SyncPhase.completed, isInitialSync: true),
    );
    boardChanges.add(null);
    await tester.pump(const Duration(milliseconds: 130));
    await tester.pumpAndSettle();
    expect(find.text('Venue Library'), findsOneWidget);

    syncStatuses.add(
      const SyncStatus(phase: SyncPhase.synchronizing, isInitialSync: false),
    );
    await tester.pump();
    await tester.pump();
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });

  for (final platform in const [TargetPlatform.android, TargetPlatform.iOS]) {
    testWidgets(
      'user can create, rename, and delete a board on ${platform.name}',
      (tester) async {
        debugDefaultTargetPlatformOverride = platform;
        try {
          await _exerciseBoardCrud(tester);
        } finally {
          debugDefaultTargetPlatformOverride = null;
        }
      },
    );
  }
}

Future<void> _exerciseBoardCrud(WidgetTester tester) async {
  final changes = StreamController<void>();
  addTearDown(changes.close);
  final boards = <SongList>[];
  final repository = _stubRepository(changes, boards);

  await _pumpSelector(tester, repository);
  await _createBoard(tester);
  await _renameBoard(tester);
  await _deleteBoard(tester);

  verify(() => repository.createBoard('First Board')).called(1);
  verify(
    () => repository.updateBoard(
      any(
        that: isA<SongList>().having(
          (board) => board.name,
          'name',
          'Updated Board',
        ),
      ),
    ),
  ).called(1);
  verify(() => repository.deleteBoard('board')).called(1);
}

_MockBoardRepository _stubRepository(
  StreamController<void> changes,
  List<SongList> boards,
) {
  final repository = _MockBoardRepository();
  when(repository.watchChanges).thenAnswer((_) => changes.stream);
  when(repository.fetchBoards).thenAnswer((_) async => List.of(boards));
  when(() => repository.createBoard(any())).thenAnswer((invocation) async {
    final board = SongList(
      id: 'board',
      ownerId: 'user',
      name: invocation.positionalArguments.single as String,
      createdAt: DateTime.utc(2026),
    );
    boards.add(board);
    return board;
  });
  when(() => repository.updateBoard(any())).thenAnswer((invocation) async {
    final board = invocation.positionalArguments.single as SongList;
    boards[boards.indexWhere((item) => item.id == board.id)] = board;
  });
  when(() => repository.deleteBoard(any())).thenAnswer((invocation) async {
    final id = invocation.positionalArguments.single as String;
    boards.removeWhere((board) => board.id == id);
  });
  return repository;
}

Future<void> _pumpSelector(
  WidgetTester tester,
  BoardRepository repository, {
  Stream<SyncStatus>? syncStatuses,
  bool settle = true,
  bool openMyBoards = true,
}) async {
  final profile = Profile()
    ..userId = 'user'
    ..role = 'user'
    ..createdAt = DateTime.utc(2026)
    ..updatedAt = DateTime.utc(2026);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        boardRepositoryProvider.overrideWithValue(repository),
        currentProfileProvider.overrideWith((_) => Stream.value(profile)),
        syncStatusProvider.overrideWith(
          (_) =>
              syncStatuses ??
              Stream.value(
                const SyncStatus(
                  phase: SyncPhase.completed,
                  isInitialSync: false,
                ),
              ),
        ),
      ],
      child: const MaterialApp(home: BoardSelectorPage()),
    ),
  );
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
    await tester.pump();
  }
  if (openMyBoards) {
    await tester.tap(find.text('My Boards'));
    await tester.pumpAndSettle();
  }
}

SongList _libraryBoard() => SongList(
  id: 'library-board',
  ownerId: 'admin',
  name: 'Venue Library',
  canEdit: false,
  creatorType: BoardCreatorType.admin,
  createdAt: DateTime.utc(2026),
);

Future<void> _createBoard(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Create a new song list'));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextField), 'First Board');
  await tester.tap(find.text('Save'));
  await tester.pumpAndSettle();
  expect(find.text('First Board'), findsOneWidget);
}

Future<void> _renameBoard(WidgetTester tester) async {
  await tester.longPress(find.text('First Board'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Rename'));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextField), 'Updated Board');
  await tester.tap(find.text('Save'));
  await tester.pumpAndSettle();
  expect(find.text('Updated Board'), findsOneWidget);
  expect(find.text('First Board'), findsNothing);
}

Future<void> _deleteBoard(WidgetTester tester) async {
  await tester.longPress(find.text('Updated Board'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Delete'));
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
  await tester.pumpAndSettle();
  expect(find.text('Updated Board'), findsNothing);
  expect(find.text('No songs created yet'), findsOneWidget);
}
