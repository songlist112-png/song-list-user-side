import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_app/features/boards/data/board_repository.dart';
import 'package:my_app/features/boards/data/last_board_store.dart';
import 'package:my_app/features/boards/presentation/pages/board_route_page.dart';
import 'package:my_app/features/boards/presentation/pages/board_view_page.dart';
import 'package:my_app/features/boards/presentation/widgets/song_column_widget.dart';
import 'package:my_app/features/settings/domain/entities/user_preferences.dart';
import 'package:my_app/features/settings/domain/repositories/settings_repository.dart';
import 'package:my_app/features/settings/presentation/providers/settings_provider.dart';
import 'package:my_app/features/songs/presentation/pages/add_edit_song_page.dart';
import 'package:my_app/shared/models/label.dart';
import 'package:my_app/shared/models/song.dart';
import 'package:my_app/shared/models/song_column.dart';
import 'package:my_app/shared/models/song_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockBoardRepository extends Mock implements BoardRepository {}

class _MockSettingsRepository extends Mock implements SettingsRepository {}

class _MockLastBoardStore extends Mock implements LastBoardStore {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  registerFallbackValue(const Song(id: 'fallback', title: 'Fallback'));

  testWidgets('glass confirms search and back arrow resets it', (tester) async {
    await _pumpBoardPage(tester);

    await tester.tap(find.byTooltip('Search'));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'Amazing');
    await tester.pump();

    expect(find.text('Amazing Grace'), findsOneWidget);
    expect(find.text('Way Maker'), findsNothing);

    await tester.tap(find.byTooltip('Search songs'));
    await tester.pumpAndSettle();

    expect(
      tester.widget<TextField>(find.byType(TextField)).controller?.text,
      'Amazing',
    );
    expect(find.text('Amazing Grace'), findsOneWidget);
    expect(find.text('Way Maker'), findsNothing);

    await tester.tap(find.byTooltip('Cancel search'));
    await tester.pump();

    expect(find.byType(TextField), findsNothing);
    expect(find.text('Amazing Grace'), findsOneWidget);
    expect(find.text('Way Maker'), findsOneWidget);

    await tester.tap(find.byTooltip('Search'));
    await tester.pump();

    expect(
      tester.widget<TextField>(find.byType(TextField)).controller?.text,
      '',
    );
  });

  testWidgets('expanded lyrics stay open across different searches', (
    tester,
  ) async {
    await _pumpBoardPage(tester);

    await tester.tap(find.byTooltip('Search'));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'Amazing');
    await tester.pump();
    await tester.tap(
      find.descendant(
        of: find.byType(SongColumnWidget),
        matching: find.text('Amazing Grace'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Amazing lyrics'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Way');
    await tester.pump();
    expect(
      find.descendant(
        of: find.byType(SongColumnWidget),
        matching: find.text('Amazing Grace'),
      ),
      findsOneWidget,
    );
    expect(find.text('Amazing lyrics'), findsOneWidget);
    final wayMakerSong = find.descendant(
      of: find.byType(SongColumnWidget),
      matching: find.text('Way Maker'),
    );
    expect(wayMakerSong, findsOneWidget);

    await tester.tap(wayMakerSong);
    await tester.pumpAndSettle();
    expect(find.text('Way lyrics'), findsOneWidget);
  });

  testWidgets('search centers the column containing the matched song', (
    tester,
  ) async {
    await _pumpBoardPage(
      tester,
      additionalColumns: const [
        SongColumn(
          id: 'worship',
          title: 'Worship',
          songs: [Song(id: 'build-my-life', title: 'Build My Life')],
        ),
      ],
    );

    await tester.tap(find.text('Amazing Grace'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Search'));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'Build My Life');
    await tester.pumpAndSettle();

    final controller = tester
        .widget<PageView>(find.byType(PageView))
        .controller!;
    expect(controller.page, 1);
    expect(find.text('Build My Life'), findsWidgets);
  });

  testWidgets('search suggestions scroll above keyboard without overflow', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(400, 640);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetViewInsets);
    await _pumpBoardPage(
      tester,
      additionalSongs: List.generate(
        8,
        (index) => Song(id: 'history-$index', title: 'History song $index'),
      ),
    );

    await tester.tap(find.byTooltip('Search'));
    tester.view.viewInsets = const FakeViewPadding(bottom: 320);
    await tester.pump();
    final columnTopBeforeSuggestions = tester
        .getTopLeft(find.byType(SongColumnWidget))
        .dy;
    await tester.enterText(find.byType(TextField), 'History');
    await tester.pump(const Duration(milliseconds: 301));

    expect(
      find.byKey(const ValueKey('search-suggestions-card')),
      findsOneWidget,
    );
    expect(find.widgetWithText(ListTile, 'History song 0'), findsOneWidget);
    expect(
      tester.getTopLeft(find.byType(SongColumnWidget)).dy,
      columnTopBeforeSuggestions,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('label dialog returns safely to Add Song editor', (tester) async {
    final repository = await _pumpBoardPage(
      tester,
      canEdit: true,
      stubLabelCreation: true,
    );

    await tester.tap(find.text('Add song'));
    await tester.pumpAndSettle();
    final addLabelButton = find.byTooltip('Add new label');
    await tester.scrollUntilVisible(
      addLabelButton,
      300,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(addLabelButton);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.enterText(
      find.widgetWithText(TextField, 'Label name'),
      'Worship',
    );
    await tester.tap(find.text('Save Label'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Worship'), findsOneWidget);
    verify(
      () => repository.createLabel('board', 'Worship', Colors.blue),
    ).called(1);

    await tester.enterText(
      find.widgetWithText(TextField, 'Enter song title'),
      'Created Song',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final savedSong =
        verify(
              () => repository.createSong('favorites', captureAny(), 2),
            ).captured.single
            as Song;
    expect(savedSong.labels, ['worship-label']);
    expect(find.byType(AddEditSongPage), findsNothing);
    expect(
      find.descendant(
        of: find.byType(SongColumnWidget),
        matching: find.text('Created Song'),
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('menu label creation waits for route teardown', (tester) async {
    final repository = await _pumpBoardPage(
      tester,
      canEdit: true,
      stubLabelCreation: true,
    );

    await tester.tap(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.byIcon(Icons.more_vert),
      ),
    );
    await tester.pumpAndSettle();
    final addLabelButton = find.text('Add Label');
    await tester.scrollUntilVisible(
      addLabelButton,
      300,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(addLabelButton);
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.enterText(
      find.widgetWithText(TextField, 'Label name'),
      'Worship',
    );
    await tester.tap(find.text('Save Label'));
    await tester.pumpAndSettle();

    verify(
      () => repository.createLabel('board', 'Worship', Colors.blue),
    ).called(1);
    expect(find.text('Worship'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('uses persisted view mode and wide column preferences', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(400, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await _pumpBoardPage(
      tester,
      canEdit: true,
      preferences: const UserPreferences(viewMode: true, wideSongColumns: true),
    );

    final column = tester.widget<SongColumnWidget>(
      find.byType(SongColumnWidget),
    );
    final pager = tester.widget<PageView>(find.byType(PageView));
    expect(column.isViewMode, isTrue);
    expect(pager.controller?.viewportFraction, 0.96);
  });

  testWidgets('board back clears remembered board and opens selector', (
    tester,
  ) async {
    final store = _MockLastBoardStore();
    when(store.clear).thenAnswer((_) async {});
    await _pumpRoutedBoardPage(tester, store: store);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expect(find.text('Board selector'), findsOneWidget);
    verify(store.clear).called(1);
  });

  testWidgets('system back clears remembered board and opens selector', (
    tester,
  ) async {
    final store = _MockLastBoardStore();
    when(store.clear).thenAnswer((_) async {});
    await _pumpRoutedBoardPage(tester, store: store);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('Board selector'), findsOneWidget);
    verify(store.clear).called(1);
  });

  testWidgets('missing restored board clears state and opens selector', (
    tester,
  ) async {
    final store = _MockLastBoardStore();
    when(store.clear).thenAnswer((_) async {});
    await _pumpRoutedBoardPage(
      tester,
      store: store,
      restored: true,
      loadError: StateError('Board not available offline'),
    );

    expect(find.text('Board selector'), findsOneWidget);
    verify(store.clear).called(1);
  });

  testWidgets('restored board opens remembered column', (tester) async {
    final store = _MockLastBoardStore();
    when(store.clear).thenAnswer((_) async {});
    when(store.readColumnIndex).thenAnswer((_) async => 1);
    when(() => store.saveColumnIndex(any())).thenAnswer((_) async {});
    await _pumpRoutedBoardPage(tester, store: store, stubColumnStore: false);

    final controller = tester
        .widget<PageView>(find.byType(PageView))
        .controller!;
    expect(controller.page, 1);
  });
}

Future<_MockBoardRepository> _pumpBoardPage(
  WidgetTester tester, {
  List<Song> additionalSongs = const [],
  List<SongColumn> additionalColumns = const [],
  bool canEdit = false,
  bool stubLabelCreation = false,
  UserPreferences preferences = const UserPreferences(),
}) async {
  SharedPreferences.setMockInitialValues({});
  final boardChanges = StreamController<void>();
  addTearDown(boardChanges.close);
  final boardRepository = _MockBoardRepository();
  final settingsRepository = _MockSettingsRepository();
  final lastBoardStore = _MockLastBoardStore();
  when(lastBoardStore.readColumnIndex).thenAnswer((_) async => 0);
  when(() => lastBoardStore.saveColumnIndex(any())).thenAnswer((_) async {});
  when(boardRepository.watchChanges).thenAnswer((_) => boardChanges.stream);
  when(() => boardRepository.fetchBoard('board')).thenAnswer(
    (_) async => SongList(
      id: 'board',
      ownerId: 'user',
      name: 'Set List',
      canEdit: canEdit,
      columns: [
        SongColumn(
          id: 'favorites',
          title: 'Favorites',
          songs: <Song>[
            const Song(
              id: 'amazing-grace',
              title: 'Amazing Grace',
              lyrics: 'Amazing lyrics',
            ),
            const Song(
              id: 'way-maker',
              title: 'Way Maker',
              lyrics: 'Way lyrics',
            ),
            ...additionalSongs,
          ],
        ),
        ...additionalColumns,
      ],
      createdAt: DateTime.utc(2026),
    ),
  );
  if (stubLabelCreation) {
    when(
      () => boardRepository.createLabel('board', 'Worship', Colors.blue),
    ).thenAnswer(
      (_) async => const Label(id: 'worship-label', name: 'Worship'),
    );
    when(() => boardRepository.createSong('favorites', any(), 2)).thenAnswer((
      invocation,
    ) async {
      final song = invocation.positionalArguments[1] as Song;
      return song.copyWith(id: 'created-song');
    });
  }
  when(
    () => settingsRepository.load(preferRemote: any(named: 'preferRemote')),
  ).thenAnswer((_) async => preferences);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        boardRepositoryProvider.overrideWithValue(boardRepository),
        settingsRepositoryProvider.overrideWithValue(settingsRepository),
        lastBoardStoreProvider.overrideWithValue(lastBoardStore),
      ],
      child: const MaterialApp(home: BoardViewPage(boardId: 'board')),
    ),
  );
  await tester.pumpAndSettle();
  return boardRepository;
}

Future<void> _pumpRoutedBoardPage(
  WidgetTester tester, {
  required LastBoardStore store,
  bool restored = false,
  StateError? loadError,
  bool stubColumnStore = true,
}) async {
  SharedPreferences.setMockInitialValues({});
  final boardChanges = StreamController<void>();
  addTearDown(boardChanges.close);
  final boardRepository = _MockBoardRepository();
  final settingsRepository = _MockSettingsRepository();
  when(boardRepository.watchChanges).thenAnswer((_) => boardChanges.stream);
  when(() => boardRepository.fetchBoard('board')).thenAnswer((_) async {
    if (loadError != null) throw loadError;
    return _board();
  });
  when(
    () => settingsRepository.load(preferRemote: any(named: 'preferRemote')),
  ).thenAnswer((_) async => const UserPreferences());
  if (stubColumnStore) {
    when(store.readColumnIndex).thenAnswer((_) async => 0);
    when(() => store.saveColumnIndex(any())).thenAnswer((_) async {});
  }
  final router = GoRouter(
    initialLocation: restored ? '/board/board?restored=true' : '/board/board',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => const Scaffold(body: Text('Board selector')),
      ),
      GoRoute(
        path: '/board/:id',
        builder: (_, state) => BoardRoutePage(
          boardId: state.pathParameters['id']!,
          restoredFromPreviousSession:
              state.uri.queryParameters['restored'] == 'true',
        ),
      ),
    ],
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        boardRepositoryProvider.overrideWithValue(boardRepository),
        settingsRepositoryProvider.overrideWithValue(settingsRepository),
        lastBoardStoreProvider.overrideWithValue(store),
      ],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
}

SongList _board() => SongList(
  id: 'board',
  ownerId: 'user',
  name: 'Set List',
  canEdit: false,
  columns: const [
    SongColumn(
      id: 'favorites',
      title: 'Favorites',
      songs: [
        Song(id: 'amazing-grace', title: 'Amazing Grace'),
        Song(id: 'way-maker', title: 'Way Maker'),
      ],
    ),
    SongColumn(
      id: 'encore',
      title: 'Encore',
      songs: [Song(id: 'firm-foundation', title: 'Firm Foundation')],
    ),
  ],
  createdAt: DateTime.utc(2026),
);
