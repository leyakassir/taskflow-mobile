import 'package:flutter/material.dart';

import 'package:taskflow_mobile/app/theme/app_dimensions.dart';
import 'package:taskflow_mobile/app/theme/app_text_styles.dart';

/// Titled card used for each section of the task details screen.
class TaskSectionCard extends StatelessWidget {
  const TaskSectionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Header: small uppercase, letter-spaced label followed by a hairline.
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.space4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: colorScheme.onSurfaceVariant),
                const SizedBox(width: AppDimensions.space2),
                Flexible(
                  child: Text(
                    title.toUpperCase(),
                    style: AppTextStyles.labelSmall.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.space3),
                Expanded(
                  child: Divider(
                    height: 1,
                    thickness: 1,
                    color: colorScheme.outlineVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.space3),
            child,
          ],
        ),
      ),
    );
  }
}
