import 'package:flutter/material.dart';

import 'package:taskflow_mobile/app/theme/app_colors.dart';
import 'package:taskflow_mobile/l10n/gen/app_localizations.dart';

/// Shown before logging out while offline changes are still unsent, since
/// logging out discards them. Pops true to log out anyway.
class LogoutPendingDialog extends StatelessWidget {
  const LogoutPendingDialog({super.key, required this.pendingCount});

  final int pendingCount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      icon: Icon(
        Icons.cloud_off_rounded,
        color: context.readable(AppColors.warning),
      ),
      title: Text(l10n.logoutPendingTitle),
      content: Text(l10n.logoutPendingMessage(pendingCount)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: TextButton.styleFrom(
            foregroundColor: context.readable(AppColors.danger),
          ),
          child: Text(l10n.logoutAnyway),
        ),
      ],
    );
  }
}
