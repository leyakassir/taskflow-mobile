import 'package:flutter/material.dart';

import 'package:taskflow_mobile/app/theme/app_colors.dart';

/// A small dot: filled in the priority color, or a danger-colored ring when
/// the item is overdue, so overdue reads by shape as well as color.
class CalendarMarkerDot extends StatelessWidget {
  const CalendarMarkerDot({
    super.key,
    required this.color,
    this.overdue = false,
    this.size = 6,
  });

  final Color color;
  final bool overdue;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: overdue ? null : color,
        border: overdue
            ? Border.all(color: AppColors.danger, width: size / 4)
            : null,
      ),
    );
  }
}
