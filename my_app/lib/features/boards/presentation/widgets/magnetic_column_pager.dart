import 'package:flutter/material.dart';

/// Horizontally pages board columns while keeping adjacent edges visible.
class MagneticColumnPager extends StatefulWidget {
  const MagneticColumnPager({
    required this.itemCount,
    required this.itemBuilder,
    this.viewportFraction = normalViewportFraction,
    this.trailing,
    super.key,
  }) : assert(viewportFraction > 0 && viewportFraction <= 1);

  static const double normalViewportFraction = 0.80;
  static const double wideViewportFraction = 0.96;

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final double viewportFraction;
  final Widget? trailing;

  @override
  State<MagneticColumnPager> createState() => _MagneticColumnPagerState();
}

class _MagneticColumnPagerState extends State<MagneticColumnPager> {
  late PageController _controller;

  int get _pageCount => widget.itemCount + (widget.trailing == null ? 0 : 1);

  @override
  void initState() {
    super.initState();
    _controller = _createController();
  }

  @override
  void didUpdateWidget(covariant MagneticColumnPager oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.viewportFraction != oldWidget.viewportFraction) {
      _replaceController();
    }
    final oldPageCount =
        oldWidget.itemCount + (oldWidget.trailing == null ? 0 : 1);
    if (_pageCount < oldPageCount) _keepCurrentPageInRange();
  }

  PageController _createController({int initialPage = 0}) => PageController(
    initialPage: initialPage,
    viewportFraction: widget.viewportFraction,
  );

  void _replaceController() {
    final previousController = _controller;
    final currentPage = previousController.hasClients
        ? (previousController.page ?? previousController.initialPage).round()
        : previousController.initialPage;
    final lastPage = _pageCount > 0 ? _pageCount - 1 : 0;
    _controller = _createController(
      initialPage: currentPage.clamp(0, lastPage),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      previousController.dispose();
    });
  }

  void _keepCurrentPageInRange() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_controller.hasClients || _pageCount == 0) return;
      final currentPage = (_controller.page ?? 0).round();
      final lastPage = _pageCount - 1;
      if (currentPage > lastPage) _controller.jumpToPage(lastPage);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _controller,
      itemCount: _pageCount,
      padEnds: true,
      pageSnapping: true,
      allowImplicitScrolling: true,
      itemBuilder: (context, index) {
        final child = index < widget.itemCount
            ? widget.itemBuilder(context, index)
            : widget.trailing!;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Align(alignment: Alignment.topCenter, child: child),
        );
      },
    );
  }
}
