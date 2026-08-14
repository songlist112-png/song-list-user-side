import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
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

    expect(find.text('Admin-created board · read only'), findsOneWidget);
    expect(
      tester
          .widgetList<Switch>(find.byType(Switch))
          .every((control) => control.onChanged == null),
      isTrue,
    );
    expect(find.text('Add Artist'), findsNothing);
    expect(find.byTooltip('Edit'), findsNothing);
  });
}
