import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../pages/subscription_plans_page.dart';

class SubscriptionBadgeOverlay extends StatefulWidget {
  const SubscriptionBadgeOverlay({
    required this.child,
    this.visible = true,
    super.key,
  });

  final Widget child;
  final bool visible;

  @override
  State<SubscriptionBadgeOverlay> createState() =>
      _SubscriptionBadgeOverlayState();
}

class _SubscriptionBadgeOverlayState extends State<SubscriptionBadgeOverlay> {
  static const _badgeWidth = 100.0;
  static const _badgeHeight = 80.0;
  static const _horizontalMargin = 0.0;
  static const _edgeOverlap = 12.0;
  static const _verticalMargin = 12.0;

  final _stackKey = GlobalKey();
  bool _isOnLeft = false;
  bool _isDismissed = false;
  double? _top;
  double? _dragLeft;

  Future<void> _showPlans(BuildContext context) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    builder: (_) => const FractionallySizedBox(
      heightFactor: 0.94,
      child: SubscriptionPlansPage(),
    ),
  );

  @override
  Widget build(BuildContext context) {
    if (!widget.visible || _isDismissed) return widget.child;

    return LayoutBuilder(
      builder: (context, constraints) {
        final safePadding = MediaQuery.paddingOf(context);
        final minTop = safePadding.top + _verticalMargin;
        final maxTop =
            constraints.maxHeight -
            safePadding.bottom -
            _verticalMargin -
            _badgeHeight;
        final availableMaxTop = maxTop < minTop ? minTop : maxTop;
        final resolvedTop = (_top ?? minTop + ((availableMaxTop - minTop) / 2))
            .clamp(minTop, availableMaxTop);
        final horizontalBounds = _horizontalBounds(constraints.maxWidth);
        final edgeLeft = _isOnLeft
            ? horizontalBounds.min
            : horizontalBounds.max;
        final resolvedLeft = (_dragLeft ?? edgeLeft).clamp(
          horizontalBounds.min,
          horizontalBounds.max,
        );

        return Stack(
          key: _stackKey,
          children: [
            widget.child,
            Positioned(
              top: resolvedTop,
              left: resolvedLeft,
              child: GestureDetector(
                onPanStart: (_) => setState(() => _dragLeft = resolvedLeft),
                onPanUpdate: (details) => _moveBadge(
                  details.globalPosition,
                  constraints,
                  minTop,
                  availableMaxTop,
                ),
                onPanEnd: (_) => _snapToEdge(constraints.maxWidth),
                onPanCancel: () => _snapToEdge(constraints.maxWidth),
                child: Semantics(
                  button: true,
                  label: 'Open plans and billing. Draggable.',
                  hint: 'Drag up, down, left, or right to reposition.',
                  child: Tooltip(
                    message: 'Plans & Billing',
                    child: Material(
                      key: const ValueKey('subscription-badge-material'),
                      color: Colors.transparent,
                      child: SizedBox(
                        width: _badgeWidth,
                        height: _badgeHeight,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: InkWell(
                                onTap: () => _showPlans(context),
                                child: ClipRect(
                                  child: Lottie.asset(
                                    'assets/animations/Coins.lottie',
                                    decoder: _decodeDotLottie,
                                    fit: BoxFit.cover,
                                    repeat: true,
                                    animate: !MediaQuery.disableAnimationsOf(
                                      context,
                                    ),
                                    renderCache: RenderCache.raster,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(
                                              Icons.attach_money_rounded,
                                              color: Colors.white,
                                              size: 28,
                                            ),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 4,
                              left: _isOnLeft ? null : 4,
                              right: _isOnLeft ? 4 : null,
                              child: Tooltip(
                                message: 'Hide subscription shortcut',
                                child: Material(
                                  key: const ValueKey(
                                    'subscription-badge-close',
                                  ),
                                  color: const Color(0x99000000),
                                  shape: const CircleBorder(),
                                  clipBehavior: Clip.antiAlias,
                                  child: InkWell(
                                    onTap: () =>
                                        setState(() => _isDismissed = true),
                                    child: const SizedBox.square(
                                      dimension: 30,
                                      child: Icon(
                                        Icons.close_rounded,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _moveBadge(
    Offset globalPosition,
    BoxConstraints constraints,
    double minTop,
    double maxTop,
  ) {
    final renderObject = _stackKey.currentContext?.findRenderObject();
    if (renderObject is! RenderBox) return;
    final localPosition = renderObject.globalToLocal(globalPosition);
    final horizontalBounds = _horizontalBounds(constraints.maxWidth);
    setState(() {
      _dragLeft = (localPosition.dx - (_badgeWidth / 2)).clamp(
        horizontalBounds.min,
        horizontalBounds.max,
      );
      _top = (localPosition.dy - (_badgeHeight / 2)).clamp(minTop, maxTop);
    });
  }

  void _snapToEdge(double width) {
    final left = _dragLeft;
    if (left == null) return;
    setState(() {
      _isOnLeft = left + (_badgeWidth / 2) < width / 2;
      _dragLeft = null;
    });
  }

  ({double min, double max}) _horizontalBounds(double width) {
    final availableLeft = (width - _badgeWidth).clamp(0.0, double.infinity);
    final margin = _horizontalMargin.clamp(0.0, availableLeft / 2);
    return (
      min: margin - _edgeOverlap,
      max: availableLeft - margin + _edgeOverlap,
    );
  }
}

Future<LottieComposition?> _decodeDotLottie(List<int> bytes) =>
    LottieComposition.decodeZip(
      bytes,
      filePicker: (files) {
        for (final file in files) {
          if (file.name.startsWith('animations/') &&
              file.name.endsWith('.json')) {
            return file;
          }
        }
        return null;
      },
    );
