import 'package:flutter/material.dart';

import 'package:taskflow_mobile/app/theme/app_dimensions.dart';
import 'package:taskflow_mobile/app/theme/app_text_styles.dart';

/// Rounded progress bar with a caption and percentage. It fills over
/// [duration] (the splash's minimum display time) and then stays full until
/// the app navigates away.
class SplashLoadingBar extends StatefulWidget {
  const SplashLoadingBar({
    super.key,
    required this.label,
    required this.color,
    this.duration = const Duration(seconds: 5),
  });

  final String label;
  final Color color;
  final Duration duration;

  @override
  State<SplashLoadingBar> createState() => _SplashLoadingBarState();
}

class _SplashLoadingBarState extends State<SplashLoadingBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final value = Curves.easeInOut.transform(_controller.value);
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.label,
                    style: AppTextStyles.labelLarge.copyWith(
                      color: widget.color.withValues(alpha: 0.85),
                    ),
                  ),
                ),
                Text(
                  '${(value * 100).round()}%',
                  style: AppTextStyles.labelLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    color: widget.color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.space2),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: value,
                minHeight: 6,
                color: widget.color,
                backgroundColor: widget.color.withValues(alpha: 0.2),
              ),
            ),
          ],
        );
      },
    );
  }
}
