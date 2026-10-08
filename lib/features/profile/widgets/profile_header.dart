import 'package:flutter/material.dart';

import 'package:taskflow_mobile/app/theme/app_colors.dart';
import 'package:taskflow_mobile/app/theme/app_dimensions.dart';
import 'package:taskflow_mobile/app/theme/app_text_styles.dart';
import 'package:taskflow_mobile/core/constants/api_constants.dart';
import 'package:taskflow_mobile/features/profile/domain/entities/profile.dart';
import 'package:taskflow_mobile/features/profile/widgets/profile_header_chip.dart';
import 'package:taskflow_mobile/l10n/gen/app_localizations.dart';

/// Indigo gradient header with rounded bottom corners: screen title and
/// edit button, a ringed avatar with a camera badge, name, email, and role
/// and status chips. Draws behind the status bar.
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.profile,
    this.onEditTap,
    this.onPhotoTap,
  });

  final Profile profile;
  final VoidCallback? onEditTap;
  final VoidCallback? onPhotoTap;

  static const gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7C8BFF), AppColors.brandBlue, AppColors.brandBlueDark],
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    const onHeader = Colors.white;
    final hasAvatar =
        profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty;
    final initials = profile.fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part.characters.first.toUpperCase())
        .join();
    final role = switch (profile.role.toUpperCase()) {
      'ADMIN' => l10n.commentRoleAdmin,
      'MANAGER' => l10n.commentRoleManager,
      'WORKER' => l10n.roleWorker,
      _ => profile.role,
    };

    return Container(
      decoration: const BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.pagePadding,
            AppDimensions.space2,
            AppDimensions.space2,
            AppDimensions.space7,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.profileTitle,
                      style: AppTextStyles.headingLarge.copyWith(
                        fontWeight: FontWeight.w800,
                        color: onHeader,
                      ),
                    ),
                  ),
                  if (onEditTap != null)
                    IconButton(
                      tooltip: l10n.editProfileTitle,
                      onPressed: onEditTap,
                      color: onHeader,
                      icon: const Icon(Icons.edit_outlined),
                    ),
                ],
              ),
              const SizedBox(height: AppDimensions.space3),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: onHeader.withValues(alpha: 0.35),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: onHeader,
                      ),
                      child: CircleAvatar(
                        radius: 46,
                        backgroundColor: const Color(0xFFE4E7FD),
                        backgroundImage: hasAvatar
                            ? NetworkImage(
                                ApiConstants.absoluteUrl(profile.avatarUrl!),
                              )
                            : null,
                        child: hasAvatar
                            ? null
                            : Text(
                                initials.isEmpty ? '?' : initials,
                                style: AppTextStyles.displaySmall.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.brandBlueDark,
                                ),
                              ),
                      ),
                    ),
                  ),
                  if (onPhotoTap != null)
                    PositionedDirectional(
                      end: -4,
                      bottom: -4,
                      child: Material(
                        color: onHeader,
                        shape: const CircleBorder(),
                        elevation: 2,
                        child: IconButton(
                          tooltip: l10n.changeProfilePhoto,
                          onPressed: onPhotoTap,
                          color: AppColors.brandBlue,
                          iconSize: 20,
                          icon: const Icon(Icons.photo_camera_rounded),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppDimensions.space4),
              Padding(
                padding: const EdgeInsetsDirectional.only(
                  end: AppDimensions.space2,
                ),
                child: Column(
                  children: [
                    Text(
                      profile.fullName,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.displaySmall.copyWith(
                        fontWeight: FontWeight.w800,
                        color: onHeader,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      profile.email,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: onHeader.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.space3),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: AppDimensions.space2,
                      runSpacing: AppDimensions.space2,
                      children: [
                        ProfileHeaderChip(
                          icon: Icons.badge_outlined,
                          label: role,
                        ),
                        ProfileHeaderChip(
                          icon: profile.isActive
                              ? Icons.verified_rounded
                              : Icons.block_rounded,
                          label: profile.isActive
                              ? l10n.profileActive
                              : l10n.profileInactive,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
