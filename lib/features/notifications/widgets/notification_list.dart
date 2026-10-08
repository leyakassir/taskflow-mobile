import 'package:flutter/material.dart';

import 'package:taskflow_mobile/app/theme/app_dimensions.dart';
import 'package:taskflow_mobile/features/notifications/domain/entities/notification.dart';
import 'package:taskflow_mobile/features/notifications/widgets/notification_card.dart';
import 'package:taskflow_mobile/features/notifications/widgets/notification_group_header.dart';

/// Notifications newest first, under Today / Yesterday / Earlier headers.
/// Always scrollable so pull-to-refresh works with few items.
class NotificationList extends StatelessWidget {
  const NotificationList({
    super.key,
    required this.notifications,
    required this.onTap,
  });

  final List<AppNotification> notifications;
  final ValueChanged<AppNotification> onTap;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final sorted = [...notifications]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final rows = <Widget>[];
    NotificationDay? currentDay;
    for (final notification in sorted) {
      final day = notification.dayRelativeTo(now);
      if (day != currentDay) {
        currentDay = day;
        rows.add(NotificationGroupHeader(day: day));
      }
      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: AppDimensions.itemSpacing),
          child: NotificationCard(
            key: ValueKey(notification.id),
            notification: notification,
            onTap: () => onTap(notification),
          ),
        ),
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppDimensions.pagePadding),
      children: rows,
    );
  }
}
