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
            artists: const [
              Artist(id: 'user', name: 'User Artist'),
              Artist(id: 'admin', name: 'Admin Artist', canEdit: false),
            ],
            labels: const [],
            onShowArtistChanged: (_) async => true,
            onShowBpmChanged: (_) async => true,
            onDarkModeChanged: (_) async => true,
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
            artists: const [Artist(id: 'artist', name: 'Artist')],
            labels: const [],
            onShowArtistChanged: (_) async => true,
            onShowBpmChanged: (_) async => true,
            onDarkModeChanged: (enabled) async {
              darkModeEnabled = enabled;
              return true;
            },
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
    expect(
      switches.take(2).every((control) => control.onChanged == null),
      true,
    );
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
            artists: const [],
            labels: const [],
            onShowArtistChanged: (_) async => true,
            onShowBpmChanged: (_) async => true,
            onDarkModeChanged: (_) async => true,
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
}
