import 'package:flutter/material.dart';

import 'package:taskflow_mobile/core/widgets/empty_state.dart';
import 'package:taskflow_mobile/l10n/gen/app_localizations.dart';

/// Shown when the user has no notifications. Scrollable so pull-to-refresh
/// still works on an empty list.
class NotificationEmptyState extends StatelessWidget {
  const NotificationEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.sizeOf(context).height * .6,
          child: EmptyState(
            icon: Icons.notifications_none_rounded,
            title: l10n.notificationsEmptyTitle,
            message: l10n.notificationsEmptyMessage,
          ),
        ),
      ],
    );
  }
}
