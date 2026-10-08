import 'package:flutter/material.dart';

import 'package:taskflow_mobile/app/theme/app_colors.dart';
import 'package:taskflow_mobile/app/theme/app_dimensions.dart';
import 'package:taskflow_mobile/app/theme/app_text_styles.dart';
import 'package:taskflow_mobile/features/tasks/domain/entities/task.dart';
import 'package:taskflow_mobile/l10n/gen/app_localizations.dart';

/// A small pill showing a task's current status, using a soft tinted
/// background with a saturated foreground color/icon — consistent with
/// the app's dark, modern design language.
class TaskStatusChip extends StatelessWidget {
  const TaskStatusChip({
    super.key,
    required this.status,
    this.prominent = false,
  });

  final TaskStatus status;

  /// Larger pill for the top of the task details screen.
  final bool prominent;

  @override
  Widget build(BuildContext context) {
    final style = _styleFor(context, status);
    final foreground = context.readable(style.foreground);

    return Container(
      padding: prominent
          ? const EdgeInsets.symmetric(
              horizontal: AppDimensions.space3,
              vertical: AppDimensions.space2,
            )
          : const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(style.icon, size: prominent ? 16 : 12, color: foreground),
          SizedBox(width: prominent ? 6 : 4),
          Text(
            style.label,
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: prominent ? 13 : 11,
              color: foreground,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  _StatusStyle _styleFor(BuildContext context, TaskStatus status) {
    switch (status) {
      case TaskStatus.assigned:
        return _StatusStyle(
          label: AppLocalizations.of(context).statusAssigned,
          icon: Icons.inbox_outlined,
          foreground: AppColors.info,
          background: AppColors.infoBg,
        );
      case TaskStatus.inProgress:
        return _StatusStyle(
          label: AppLocalizations.of(context).statusInProgress,
          icon: Icons.autorenew_rounded,
          foreground: AppColors.warning,
          background: AppColors.warningBg,
        );
      case TaskStatus.completed:
        return _StatusStyle(
          label: AppLocalizations.of(context).statusCompleted,
          icon: Icons.check_circle_outline_rounded,
          foreground: AppColors.success,
          background: AppColors.successBg,
        );
      case TaskStatus.overdue:
        return _StatusStyle(
          label: AppLocalizations.of(context).statusOverdue,
          icon: Icons.error_outline_rounded,
          foreground: AppColors.danger,
          background: AppColors.dangerBg,
        );
      case TaskStatus.cancelled:
        return _StatusStyle(
          label: AppLocalizations.of(context).statusCancelled,
          icon: Icons.block_rounded,
          foreground: AppColors.neutral,
          background: AppColors.neutralBg,
        );
    }
  }
}

class _StatusStyle {
  const _StatusStyle({
    required this.label,
    required this.icon,
    required this.foreground,
    required this.background,
  });

  final String label;
  final IconData icon;
  final Color foreground;
  final Color background;
}
