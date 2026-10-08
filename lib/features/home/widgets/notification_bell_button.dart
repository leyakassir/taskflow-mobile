import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskflow_mobile/app/theme/app_text_styles.dart';
import 'package:taskflow_mobile/features/notifications/providers/notifications_provider.dart';
import 'package:taskflow_mobile/l10n/gen/app_localizations.dart';

/// The only entry point to notifications. Shows the unread count, which
/// updates live (pushes, marking read) and is refreshed when the app comes
/// back to the foreground, since tray pushes don't reach a backgrounded app.
class NotificationBellButton extends ConsumerStatefulWidget {
  const NotificationBellButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  ConsumerState<NotificationBellButton> createState() =>
      _NotificationBellButtonState();
}

class _NotificationBellButtonState
    extends ConsumerState<NotificationBellButton> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      onResume: () =>
          ref.read(notificationsControllerProvider.notifier).refresh(),
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final unread = ref.watch(unreadNotificationCountProvider);

    return Semantics(
      label: unread > 0
          ? l10n.notificationsUnreadLabel(unread)
          : l10n.notificationsTab,
      button: true,
      excludeSemantics: true,
      child: IconButton.filledTonal(
        tooltip: l10n.notificationsTab,
        onPressed: widget.onPressed,
        style: IconButton.styleFrom(
          foregroundColor: colorScheme.primary,
          backgroundColor: colorScheme.primary.withValues(alpha: 0.10),
          minimumSize: const Size(48, 48),
        ),
        icon: Badge(
          isLabelVisible: unread > 0,
          backgroundColor: colorScheme.error,
          textColor: colorScheme.onError,
          textStyle: AppTextStyles.labelSmall.copyWith(
            fontWeight: FontWeight.w700,
          ),
          label: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) =>
                ScaleTransition(scale: animation, child: child),
            child: Text(unread > 99 ? '99+' : '$unread', key: ValueKey(unread)),
          ),
          child: Icon(
            unread > 0
                ? Icons.notifications_active_outlined
                : Icons.notifications_none_rounded,
          ),
        ),
      ),
    );
  }
}
