import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/features/boards/presentation/widgets/magnetic_column_pager.dart';

void main() {
  testWidgets('snaps selected column to center with neighbor edges visible', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 500,
            child: MagneticColumnPager(
              itemCount: 5,
              itemBuilder: (_, index) => Container(
                key: ValueKey('column-$index'),
                width: double.infinity,
                height: 300,
                color: Colors.blue,
              ),
            ),
          ),
        ),
      ),
    );

    await tester.drag(find.byType(PageView), const Offset(-360, 0));
    await tester.pumpAndSettle();

    final selected = tester.getRect(find.byKey(const ValueKey('column-1')));
    final leftNeighbor = tester.getRect(find.byKey(const ValueKey('column-0')));
    final rightNeighbor = tester.getRect(
      find.byKey(const ValueKey('column-2')),
    );

    expect(selected.center.dx, closeTo(200, 0.1));
    expect(leftNeighbor.right, greaterThan(0));
    expect(rightNeighbor.left, lessThan(400));
  });

  testWidgets('updates width while preserving selected column', (tester) async {
    var wide = false;
    late StateSetter update;

    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            update = setState;
            return Scaffold(
              body: SizedBox(
                width: 400,
                height: 500,
                child: MagneticColumnPager(
                  viewportFraction: wide
                      ? MagneticColumnPager.wideViewportFraction
                      : MagneticColumnPager.normalViewportFraction,
                  itemCount: 5,
                  itemBuilder: (_, index) => ColoredBox(
                    key: ValueKey('column-$index'),
                    color: Colors.blue,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );

    await tester.drag(find.byType(PageView), const Offset(-360, 0));
    await tester.pumpAndSettle();
    expect(
      tester.widget<PageView>(find.byType(PageView)).controller!.page,
      closeTo(1, 0.01),
    );

    update(() => wide = true);
    await tester.pumpAndSettle();

    final controller = tester
        .widget<PageView>(find.byType(PageView))
        .controller!;
    expect(
      controller.viewportFraction,
      MagneticColumnPager.wideViewportFraction,
    );
    expect(controller.page, closeTo(1, 0.01));
  });

  testWidgets('restores initial column and reports page changes', (
    tester,
  ) async {
    var selectedPage = -1;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 500,
            child: MagneticColumnPager(
              initialPage: 2,
              itemCount: 4,
              onPageChanged: (index) => selectedPage = index,
              itemBuilder: (_, index) => ColoredBox(
                key: ValueKey('column-$index'),
                color: Colors.blue,
              ),
            ),
          ),
        ),
      ),
    );

    final controller = tester
        .widget<PageView>(find.byType(PageView))
        .controller!;
    expect(controller.page, 2);

    await tester.drag(find.byType(PageView), const Offset(-360, 0));
    await tester.pumpAndSettle();
    expect(selectedPage, 3);
  });
}
