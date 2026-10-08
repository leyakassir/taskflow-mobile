import 'package:flutter/material.dart';

/// Page dots: the active page is an indigo pill (24 wide), the others are
/// small circles in the secondary text color.
class OnboardingIndicator extends StatelessWidget {
  const OnboardingIndicator({
    super.key,
    required this.count,
    required this.index,
  });

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (i) {
        final isActive = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: isActive ? 24 : 8,
          decoration: BoxDecoration(
            color: isActive
                ? colors.primary
                : colors.onSurfaceVariant.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}
