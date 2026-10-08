import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:taskflow_mobile/app/theme/app_dimensions.dart';
import 'package:taskflow_mobile/app/theme/app_text_styles.dart';
import 'package:taskflow_mobile/features/home/widgets/notification_bell_button.dart';
import 'package:taskflow_mobile/features/profile/providers/profile_provider.dart';
import 'package:taskflow_mobile/l10n/gen/app_localizations.dart';

/// "Good morning, Name" with today's date below and the notification bell.
/// The name comes from the already-cached profile; until it loads (or if it
/// fails) only the greeting is shown.
class WelcomeHeader extends ConsumerWidget {
  const WelcomeHeader({super.key, required this.onNotificationsTap});

  final VoidCallback onNotificationsTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final now = DateTime.now();
    final greeting = switch (now.hour) {
      < 12 => l10n.homeGreetingMorning,
      < 17 => l10n.homeGreetingAfternoon,
      _ => l10n.homeGreetingEvening,
    };
    final fullName = ref.watch(profileControllerProvider).valueOrNull?.fullName;
    final firstName = fullName?.trim().split(RegExp(r'\s+')).first ?? '';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                firstName.isEmpty
                    ? greeting
                    : l10n.homeGreetingNamed(greeting, firstName),
                style: AppTextStyles.displaySmall.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: AppDimensions.space1),
              Text(
                DateFormat.yMMMMEEEEd(locale).format(now),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppDimensions.space3),
        NotificationBellButton(onPressed: onNotificationsTap),
      ],
    );
  }
}
