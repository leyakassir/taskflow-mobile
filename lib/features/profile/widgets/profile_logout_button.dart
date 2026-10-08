import 'package:flutter/material.dart';

import 'package:taskflow_mobile/app/theme/app_colors.dart';
import 'package:taskflow_mobile/app/theme/app_dimensions.dart';
import 'package:taskflow_mobile/l10n/gen/app_localizations.dart';

/// Full-width, softly tinted red "Log out" button at the end of Profile.
class ProfileLogoutButton extends StatelessWidget {
  const ProfileLogoutButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final danger = context.readable(AppColors.danger);
    return TextButton.icon(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: danger,
        backgroundColor: AppColors.danger.withValues(alpha: 0.1),
        minimumSize: const Size.fromHeight(AppDimensions.buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
        ),
      ),
      icon: const Icon(Icons.logout_rounded),
      label: Text(AppLocalizations.of(context).logOut),
    );
  }
}
