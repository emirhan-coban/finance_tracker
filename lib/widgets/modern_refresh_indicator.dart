import 'package:flutter/material.dart';
import 'dart:math' as math;

/// A modern, custom pull-to-refresh widget with a sleek animated indicator.
class ModernRefreshIndicator extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onRefresh;

  const ModernRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
  });

  @override
  State<ModernRefreshIndicator> createState() => _ModernRefreshIndicatorState();
}

class _ModernRefreshIndicatorState extends State<ModernRefreshIndicator>
    with SingleTickerProviderStateMixin {
  static const double _triggerOffset = 100.0;
  static const double _maxOffset = 140.0;

  double _dragOffset = 0;
  bool _isRefreshing = false;
  late AnimationController _spinController;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    _spinController.repeat();

    try {
      await widget.onRefresh();
    } finally {
      if (mounted) {
        _spinController.stop();
        setState(() {
          _isRefreshing = false;
          _dragOffset = 0;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = (_dragOffset / _triggerOffset).clamp(0.0, 1.0);

    return Stack(
      children: [
        // Refresh indicator
        AnimatedPositioned(
          duration: _isRefreshing
              ? Duration.zero
              : const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          top: -60 + (_isRefreshing ? 60 + 20 : _dragOffset * 0.6),
          left: 0,
          right: 0,
          child: Center(
            child: AnimatedOpacity(
              opacity: _isRefreshing ? 1.0 : progress,
              duration: const Duration(milliseconds: 150),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.15),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.1),
                  ),
                ),
                child: _isRefreshing
                    ? AnimatedBuilder(
                        animation: _spinController,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _spinController.value * 2 * math.pi,
                            child: child,
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      )
                    : Transform.rotate(
                        angle: progress * 2 * math.pi,
                        child: Icon(
                          Icons.arrow_downward_rounded,
                          color: Color.lerp(
                            theme.colorScheme.onSurface.withValues(alpha: 0.3),
                            theme.colorScheme.primary,
                            progress,
                          ),
                          size: 22,
                        ),
                      ),
              ),
            ),
          ),
        ),
        // Content with gesture detection
        NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (_isRefreshing) return false;

            if (notification is ScrollUpdateNotification) {
              if (notification.metrics.pixels < 0) {
                setState(() {
                  _dragOffset = (-notification.metrics.pixels).clamp(
                    0,
                    _maxOffset,
                  );
                });
              }
            }
            if (notification is ScrollEndNotification) {
              if (_dragOffset >= _triggerOffset) {
                _handleRefresh();
              } else {
                setState(() => _dragOffset = 0);
              }
            }
            return false;
          },
          child: AnimatedPadding(
            duration: _isRefreshing
                ? const Duration(milliseconds: 300)
                : const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            padding: EdgeInsets.only(top: _isRefreshing ? 70 : 0),
            child: widget.child,
          ),
        ),
      ],
    );
  }
}
