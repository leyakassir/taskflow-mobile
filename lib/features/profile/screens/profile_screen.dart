import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taskflow_mobile/app/theme/app_colors.dart';
import 'package:taskflow_mobile/features/profile/widgets/profile_logout_button.dart';
import 'package:taskflow_mobile/features/profile/widgets/profile_menu_section.dart';
import 'package:taskflow_mobile/features/tasks/widgets/task_card_skeleton.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:taskflow_mobile/app/router/route_names.dart';
import 'package:taskflow_mobile/app/theme/app_dimensions.dart';
import 'package:taskflow_mobile/core/network/api_exceptions.dart';
import 'package:taskflow_mobile/core/widgets/error_view.dart';
import 'package:taskflow_mobile/core/widgets/photo_source_sheet.dart';
import 'package:taskflow_mobile/features/auth/providers/auth_provider.dart';
import 'package:taskflow_mobile/features/profile/providers/profile_provider.dart';
import 'package:taskflow_mobile/features/profile/widgets/change_password_dialog.dart';
import 'package:taskflow_mobile/features/profile/widgets/profile_header.dart';
import 'package:taskflow_mobile/features/profile/widgets/profile_header_skeleton.dart';
import 'package:taskflow_mobile/features/profile/widgets/profile_menu_item.dart';
import 'package:taskflow_mobile/l10n/gen/app_localizations.dart';
import 'package:taskflow_mobile/core/network/api_exception_l10n.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileControllerProvider);
    final l10n = AppLocalizations.of(context);
    final languageName = Localizations.localeOf(context).languageCode == 'ar'
        ? l10n.languageArabic
        : l10n.languageEnglish;

    // The gradient header runs under the status bar, so use light icons.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: profile.when(
          loading: () => ListView(
            padding: EdgeInsets.zero,
            children: const [
              ProfileHeaderSkeleton(),
              Padding(
                padding: EdgeInsets.all(AppDimensions.pagePadding),
                child: TaskCardSkeleton(lines: 3),
              ),
            ],
          ),
          error: (error, _) => SafeArea(
            child: ErrorView(
              onRetry: () =>
                  ref.read(profileControllerProvider.notifier).refresh(),
            ),
          ),
          data: (value) => RefreshIndicator(
            onRefresh: () =>
                ref.read(profileControllerProvider.notifier).refresh(),
            child: ListView(
              padding: EdgeInsets.zero,
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                ProfileHeader(
                  profile: value,
                  onEditTap: () => context.push(RouteNames.profileEdit),
                  onPhotoTap: () => _changeProfilePhoto(context, ref),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimensions.pagePadding,
                    AppDimensions.space6,
                    AppDimensions.pagePadding,
                    AppDimensions.space7,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ProfileMenuSection(
                        title: l10n.accountTitle,
                        children: [
                          ProfileMenuItem(
                            icon: Icons.person_outline_rounded,
                            title: l10n.editProfileTitle,
                            subtitle: value.fullName,
                            onTap: () => context.push(RouteNames.profileEdit),
                          ),
                          ProfileMenuItem(
                            icon: Icons.photo_camera_outlined,
                            title: l10n.changeProfilePhoto,
                            color: AppColors.success,
                            onTap: () => _changeProfilePhoto(context, ref),
                          ),
                          ProfileMenuItem(
                            icon: Icons.lock_outline_rounded,
                            title: l10n.changePassword,
                            color: AppColors.warning,
                            onTap: () => _changePassword(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.sectionSpacing),
                      ProfileMenuSection(
                        title: l10n.profilePreferences,
                        children: [
                          ProfileMenuItem(
                            icon: Icons.translate_rounded,
                            title: l10n.languageTitle,
                            subtitle: languageName,
                            onTap: () => context.push(RouteNames.language),
                          ),
                          ProfileMenuItem(
                            icon: Icons.tune_rounded,
                            title: l10n.settingsTitle,
                            subtitle: l10n.profileSettingsSubtitle,
                            color: AppColors.neutral,
                            onTap: () => context.push(RouteNames.settings),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.sectionSpacing),
                      ProfileLogoutButton(
                        onPressed: () async {
                          await ref
                              .read(authControllerProvider.notifier)
                              .signOut();
                          if (context.mounted) context.go(RouteNames.login);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _changeProfilePhoto(BuildContext context, WidgetRef ref) async {
    final source = await showPhotoSourceSheet(context);
    if (source == null || !context.mounted) return;
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final photo = await ImagePicker().pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 2000,
        maxHeight: 2000,
      );
      if (photo == null) return;
      await ref
          .read(profileControllerProvider.notifier)
          .uploadAvatar(filePath: photo.path);
      messenger.showSnackBar(SnackBar(content: Text(l10n.profilePhotoUpdated)));
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            error is ApiException
                ? error.localized(l10n)
                : l10n.profilePhotoUploadFailed,
          ),
        ),
      );
    }
  }

  Future<void> _changePassword(BuildContext context) async {
    final changed = await showDialog<bool>(
      context: context,
      builder: (_) => const ChangePasswordDialog(),
    );
    if (changed == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).passwordChanged)),
      );
    }
  }
}
