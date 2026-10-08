import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskflow_mobile/features/notifications/providers/notifications_provider.dart';
import 'package:taskflow_mobile/l10n/gen/app_localizations.dart';

/// AppBar action; disabled when nothing is unread.
class MarkAllReadButton extends ConsumerWidget {
  const MarkAllReadButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final unread = ref.watch(unreadNotificationCountProvider);

    Future<void> markAll() async {
      final messenger = ScaffoldMessenger.of(context);
      try {
        await ref.read(notificationsControllerProvider.notifier).markAllRead();
      } catch (_) {
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.notificationsMarkAllReadFailed)),
        );
      }
    }

    return IconButton(
      tooltip: l10n.notificationsMarkAllRead,
      onPressed: unread == 0 ? null : markAll,
      icon: const Icon(Icons.done_all_rounded),
    );
  }
}
