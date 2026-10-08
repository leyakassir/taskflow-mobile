import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taskflow_mobile/app/theme/app_dimensions.dart';
import 'package:taskflow_mobile/app/theme/app_text_styles.dart';
import 'package:taskflow_mobile/features/settings/providers/settings_provider.dart';
import 'package:taskflow_mobile/features/settings/widgets/language_selector.dart';
import 'package:taskflow_mobile/l10n/gen/app_localizations.dart';

class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).languageTitle)),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.pagePadding),
        children: [
          const SizedBox(height: AppDimensions.space6),
          Icon(Icons.translate_rounded, size: 56, color: colors.primary),
          const SizedBox(height: AppDimensions.space4),
          Text(
            AppLocalizations.of(context).languageHelp,
            textAlign: TextAlign.center,
            style: AppTextStyles.headingLarge.copyWith(color: colors.onSurface),
          ),
          const SizedBox(height: AppDimensions.space6),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.space4),
              child: LanguageSelector(
                value: settings.locale,
                onChanged: (locale) => ref
                    .read(settingsControllerProvider.notifier)
                    .setLocale(locale),
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.space5),
          FilledButton(
            onPressed: () => context.pop(),
            child: Text(AppLocalizations.of(context).save),
          ),
        ],
      ),
    );
  }
}
