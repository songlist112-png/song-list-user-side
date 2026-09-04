import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/app/theme/app_colors.dart';
import 'package:my_app/features/boards/presentation/widgets/menu_bottom_sheet.dart';
import 'package:my_app/shared/models/artist.dart';

void main() {
  testWidgets('only user-owned artists expose management actions', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: MenuBottomSheet(
            showArtist: true,
            showBpm: false,
            darkMode: false,
            viewMode: false,
            wideColumns: false,
            artists: const [
              Artist(id: 'user', name: 'User Artist'),
              Artist(id: 'admin', name: 'Admin Artist', canEdit: false),
            ],
            labels: const [],
            onShowArtistChanged: (_) async => true,
            onShowBpmChanged: (_) async => true,
            onDarkModeChanged: (_) async => true,
            onViewModeChanged: (_) {},
            onWideColumnsChanged: (_) {},
            onAddArtist: () {},
            onRemoveArtist: (_) async {},
            onUpdateArtist: (_) {},
            onAddLabel: (_) {},
            onUpdateLabel: (_) {},
            onRemoveLabel: (_) async {},
          ),
        ),
      ),
    );

    await tester.scrollUntilVisible(
      find.text('Admin Artist'),
      200,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.byTooltip('Edit'), findsOneWidget);
    expect(find.byTooltip('Admin artist · read only'), findsOneWidget);
  });

  testWidgets('admin-created board menu is visible but read only', (
    tester,
  ) async {
    var darkModeEnabled = false;
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: MenuBottomSheet(
            readOnly: true,
            showArtist: true,
            showBpm: false,
            darkMode: false,
            viewMode: true,
            wideColumns: false,
            artists: const [Artist(id: 'artist', name: 'Artist')],
            labels: const [],
            onShowArtistChanged: (_) async => true,
            onShowBpmChanged: (_) async => true,
            onDarkModeChanged: (enabled) async {
              darkModeEnabled = enabled;
              return true;
            },
            onViewModeChanged: (_) {},
            onWideColumnsChanged: (_) {},
            onAddArtist: () {},
            onRemoveArtist: (_) async {},
            onUpdateArtist: (_) {},
            onAddLabel: (_) {},
            onUpdateLabel: (_) {},
            onRemoveLabel: (_) async {},
          ),
        ),
      ),
    );

    expect(find.text('Admin-created board · read only'), findsOneWidget);
    final switches = tester.widgetList<Switch>(find.byType(Switch)).toList();
    expect(switches[0].onChanged, isNull);
    expect(switches[1].onChanged, isNotNull);
    expect(switches[2].onChanged, isNull);
    expect(switches[3].onChanged, isNull);
    expect(switches.last.onChanged, isNotNull);
    await tester.tap(find.byType(Switch).last);
    await tester.pumpAndSettle();
    expect(darkModeEnabled, isTrue);
    expect(find.text('Add Artist'), findsNothing);
    expect(find.byTooltip('Edit'), findsNothing);
  });

  testWidgets('dark mode changes surfaces but preserves blue brand colors', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: MenuBottomSheet(
            showArtist: true,
            showBpm: false,
            darkMode: false,
            viewMode: false,
            wideColumns: false,
            artists: const [],
            labels: const [],
            onShowArtistChanged: (_) async => true,
            onShowBpmChanged: (_) async => true,
            onDarkModeChanged: (_) async => true,
            onViewModeChanged: (_) {},
            onWideColumnsChanged: (_) {},
            onAddArtist: () {},
            onRemoveArtist: (_) async {},
            onUpdateArtist: (_) {},
            onAddLabel: (_) {},
            onUpdateLabel: (_) {},
            onRemoveLabel: (_) async {},
          ),
        ),
      ),
    );

    expect(
      tester.widgetList<Scaffold>(find.byType(Scaffold)).last.backgroundColor,
      AppColors.bgCard,
    );

    await tester.tap(find.byType(Switch).last);
    await tester.pumpAndSettle();

    final darkScaffold = tester
        .widgetList<Scaffold>(find.byType(Scaffold))
        .last;
    expect(darkScaffold.backgroundColor, AppColors.bgCardDark);
    expect(
      Theme.of(tester.element(find.text('Dark Mode'))).brightness,
      Brightness.dark,
    );
    expect(AppColors.bg, const Color(0xFF005A9E));
    expect(AppColors.bgDark, const Color(0xFF004A80));
  });

  testWidgets('view mode toggle reports changes', (tester) async {
    bool? viewMode;
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: MenuBottomSheet(
            showArtist: true,
            showBpm: false,
            darkMode: false,
            viewMode: false,
            wideColumns: false,
            artists: const [],
            labels: const [],
            onShowArtistChanged: (_) async => true,
            onShowBpmChanged: (_) async => true,
            onDarkModeChanged: (_) async => true,
            onViewModeChanged: (enabled) => viewMode = enabled,
            onWideColumnsChanged: (_) {},
            onAddArtist: () {},
            onRemoveArtist: (_) async {},
            onUpdateArtist: (_) {},
            onAddLabel: (_) {},
            onUpdateLabel: (_) {},
            onRemoveLabel: (_) async {},
          ),
        ),
      ),
    );

    await tester.tap(find.byType(Switch).first);
    await tester.pump();

    expect(viewMode, isTrue);
    expect(tester.widget<Switch>(find.byType(Switch).first).value, isTrue);
  });

  testWidgets('wide columns toggle reports changes', (tester) async {
    bool? wideColumns;
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: MenuBottomSheet(
            showArtist: true,
            showBpm: false,
            darkMode: false,
            viewMode: false,
            wideColumns: false,
            artists: const [],
            labels: const [],
            onShowArtistChanged: (_) async => true,
            onShowBpmChanged: (_) async => true,
            onDarkModeChanged: (_) async => true,
            onViewModeChanged: (_) {},
            onWideColumnsChanged: (enabled) => wideColumns = enabled,
            onAddArtist: () {},
            onRemoveArtist: (_) async {},
            onUpdateArtist: (_) {},
            onAddLabel: (_) {},
            onUpdateLabel: (_) {},
            onRemoveLabel: (_) async {},
          ),
        ),
      ),
    );

    await tester.tap(find.byType(Switch).at(1));
    await tester.pump();

    expect(wideColumns, isTrue);
    expect(tester.widget<Switch>(find.byType(Switch).at(1)).value, isTrue);
  });

  for (final viewport in const {
    'narrow Android': Size(320, 568),
    'compact iOS': Size(375, 667),
  }.entries) {
    testWidgets('${viewport.key} keeps controls visible and sheet scrollable', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = viewport.value;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        ProviderScope(child: MaterialApp(home: _buildMenuBottomSheet())),
      );

      final viewModeSwitch = find.byType(Switch).first;
      final switchBounds = tester.getRect(viewModeSwitch);
      expect(find.text('View Mode'), findsOneWidget);
      expect(switchBounds.left, greaterThanOrEqualTo(0));
      expect(switchBounds.right, lessThanOrEqualTo(viewport.value.width));
      expect(tester.takeException(), isNull);

      await tester.scrollUntilVisible(
        find.text('Add Label'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.text('Add Label'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}

MenuBottomSheet _buildMenuBottomSheet() => MenuBottomSheet(
  showArtist: true,
  showBpm: false,
  darkMode: false,
  viewMode: false,
  wideColumns: false,
  artists: const [],
  labels: const [],
  onShowArtistChanged: (_) async => true,
  onShowBpmChanged: (_) async => true,
  onDarkModeChanged: (_) async => true,
  onViewModeChanged: (_) {},
  onWideColumnsChanged: (_) {},
  onAddArtist: () {},
  onRemoveArtist: (_) async {},
  onUpdateArtist: (_) {},
  onAddLabel: (_) {},
  onUpdateLabel: (_) {},
  onRemoveLabel: (_) async {},
);
