import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taskflow_mobile/app/theme/app_text_styles.dart';
import 'package:taskflow_mobile/features/settings/providers/settings_provider.dart';
import 'package:taskflow_mobile/l10n/gen/app_localizations.dart';

/// Translucent pill on the sign-in screen that switches English / Arabic,
/// so someone can read the screen before they have an account open.
class LoginLanguageToggle extends ConsumerWidget {
  const LoginLanguageToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return Material(
      color: Colors.white.withValues(alpha: 0.16),
      shape: StadiumBorder(
        side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: () => ref
            .read(settingsControllerProvider.notifier)
            .setLocale(Locale(isArabic ? 'en' : 'ar')),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.translate_rounded,
                  size: 16,
                  color: Colors.white,
                ),
                const SizedBox(width: 6),
                Text(
                  l10n.loginLanguageToggle,
                  style: AppTextStyles.labelLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
