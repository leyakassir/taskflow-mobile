import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taskflow_mobile/app/theme/app_dimensions.dart';
import 'package:taskflow_mobile/core/widgets/error_view.dart';
import 'package:taskflow_mobile/features/notifications/domain/entities/notification.dart';
import 'package:taskflow_mobile/features/notifications/providers/notifications_provider.dart';
import 'package:taskflow_mobile/features/notifications/widgets/mark_all_read_button.dart';
import 'package:taskflow_mobile/features/notifications/widgets/notification_card_skeleton.dart';
import 'package:taskflow_mobile/features/notifications/widgets/notification_empty_state.dart';
import 'package:taskflow_mobile/features/notifications/widgets/notification_list.dart';
import 'package:taskflow_mobile/l10n/gen/app_localizations.dart';

/// Pushed from the bell on Home (has a back button; not a tab).
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final notificationsAsync = ref.watch(notificationsControllerProvider);

    void open(AppNotification notification) {
      final destination = ref
          .read(notificationOpenerProvider)
          .open(
            notificationId: notification.id,
            kind: notification.kind,
            taskId: notification.taskId,
          );
      if (destination == null) {
        if (notification.kind == NotificationKind.taskUnassigned) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.notificationTaskUnavailable)),
          );
        }
      } else if (destination.isTab) {
        context.go(destination.path);
      } else {
        context.push(destination.path);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notificationsTab),
        actions: const [MarkAllReadButton()],
      ),
      body: notificationsAsync.when(
        loading: () => ListView.separated(
          padding: const EdgeInsets.all(AppDimensions.pagePadding),
          itemCount: 5,
          separatorBuilder: (_, _) =>
              const SizedBox(height: AppDimensions.itemSpacing),
          itemBuilder: (_, _) => const NotificationCardSkeleton(),
        ),
        error: (_, _) => ErrorView(
          message: l10n.notificationsLoadError,
          onRetry: () => ref.invalidate(notificationsControllerProvider),
        ),
        data: (notifications) => RefreshIndicator(
          onRefresh: ref.read(notificationsControllerProvider.notifier).refresh,
          child: notifications.isEmpty
              ? const NotificationEmptyState()
              : NotificationList(notifications: notifications, onTap: open),
        ),
      ),
    );
  }
}
