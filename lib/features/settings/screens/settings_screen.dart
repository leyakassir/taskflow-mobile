import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taskflow_mobile/app/router/route_names.dart';
import 'package:taskflow_mobile/app/theme/app_dimensions.dart';
import 'package:taskflow_mobile/app/theme/app_text_styles.dart';
import 'package:taskflow_mobile/features/auth/providers/auth_provider.dart';
import 'package:taskflow_mobile/features/settings/providers/settings_provider.dart';
import 'package:taskflow_mobile/features/settings/widgets/legal_link_tile.dart';
import 'package:taskflow_mobile/features/settings/widgets/settings_section.dart';
import 'package:taskflow_mobile/features/settings/widgets/theme_selector.dart';
import 'package:taskflow_mobile/features/settings/widgets/language_selector.dart';
import 'package:taskflow_mobile/l10n/gen/app_localizations.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
    final settings = ref.watch(settingsControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.pagePadding),
        children: [
          Text(
            l10n.settingsHeadline,
            style: AppTextStyles.displaySmall.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppDimensions.space1),
          Text(
            l10n.settingsSubhead,
            style: AppTextStyles.bodyMedium.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppDimensions.space6),
          SettingsSection(
            title: l10n.appearanceTitle,
            icon: Icons.palette_outlined,
            child: ThemeSelector(
              value: settings.themeMode,
              onChanged: controller.setThemeMode,
            ),
          ),
          const SizedBox(height: AppDimensions.space4),
          SettingsSection(
            title: l10n.languageTitle,
            icon: Icons.translate_rounded,
            child: LanguageSelector(
              value: settings.locale,
              onChanged: controller.setLocale,
            ),
          ),
          const SizedBox(height: AppDimensions.space4),
          SettingsSection(
            title: l10n.legalAboutTitle,
            icon: Icons.info_outline_rounded,
            child: Column(
              children: [
                LegalLinkTile(
                  title: l10n.legalTerms,
                  icon: Icons.description_outlined,
                  onTap: () => context.push(RouteNames.legalPath('terms')),
                ),
                LegalLinkTile(
                  title: l10n.legalPrivacy,
                  icon: Icons.privacy_tip_outlined,
                  onTap: () => context.push(RouteNames.legalPath('privacy')),
                ),
                LegalLinkTile(
                  title: l10n.legalAbout,
                  icon: Icons.info_outline_rounded,
                  onTap: () => context.push(RouteNames.legalPath('about')),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.space4),
          SettingsSection(
            title: l10n.sessionTitle,
            icon: Icons.person_outline_rounded,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.logout_rounded),
              title: Text(l10n.logOut),
              onTap: () async {
                await ref.read(authControllerProvider.notifier).signOut();
                if (context.mounted) context.go(RouteNames.login);
              },
            ),
          ),
        ],
      ),
    );
  }
}
