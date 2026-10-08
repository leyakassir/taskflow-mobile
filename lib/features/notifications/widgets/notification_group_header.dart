import 'package:flutter/material.dart';

import 'package:taskflow_mobile/app/theme/app_dimensions.dart';
import 'package:taskflow_mobile/app/theme/app_text_styles.dart';
import 'package:taskflow_mobile/features/notifications/domain/entities/notification.dart';
import 'package:taskflow_mobile/l10n/gen/app_localizations.dart';

class NotificationGroupHeader extends StatelessWidget {
  const NotificationGroupHeader({super.key, required this.day});

  final NotificationDay day;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final label = switch (day) {
      NotificationDay.today => l10n.notificationsGroupToday,
      NotificationDay.yesterday => l10n.notificationsGroupYesterday,
      NotificationDay.earlier => l10n.notificationsGroupEarlier,
    };

    return Padding(
      padding: const EdgeInsetsDirectional.only(
        start: AppDimensions.space1,
        top: AppDimensions.space2,
        bottom: AppDimensions.space2,
      ),
      child: Text(
        label,
        style: AppTextStyles.labelLarge.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
