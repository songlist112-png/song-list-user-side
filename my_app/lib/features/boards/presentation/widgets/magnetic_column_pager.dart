import 'package:flutter/material.dart';

/// Horizontally pages board columns while keeping adjacent edges visible.
class MagneticColumnPager extends StatefulWidget {
  const MagneticColumnPager({
    required this.itemCount,
    required this.itemBuilder,
    this.trailing,
    super.key,
  });

  static const double viewportFraction = 0.80;

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final Widget? trailing;

  @override
  State<MagneticColumnPager> createState() => _MagneticColumnPagerState();
}

class _MagneticColumnPagerState extends State<MagneticColumnPager> {
  late final PageController _controller;

  int get _pageCount => widget.itemCount + (widget.trailing == null ? 0 : 1);

  @override
  void initState() {
    super.initState();
    _controller = PageController(
      viewportFraction: MagneticColumnPager.viewportFraction,
    );
  }

  @override
  void didUpdateWidget(covariant MagneticColumnPager oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldPageCount =
        oldWidget.itemCount + (oldWidget.trailing == null ? 0 : 1);
    if (_pageCount < oldPageCount) _keepCurrentPageInRange();
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
