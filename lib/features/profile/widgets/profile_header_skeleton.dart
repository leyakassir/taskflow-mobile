import 'package:flutter/material.dart';

import 'package:taskflow_mobile/app/theme/app_dimensions.dart';
import 'package:taskflow_mobile/features/profile/widgets/profile_header.dart';

/// Loading placeholder shaped like the profile header: the same gradient
/// with soft white blocks where the avatar, name and chips go.
class ProfileHeaderSkeleton extends StatelessWidget {
  const ProfileHeaderSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    Widget block(double w, double h, {double r = 8}) => Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(r),
      ),
    );

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: ProfileHeader.gradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.pagePadding,
            AppDimensions.space5,
            AppDimensions.pagePadding,
            AppDimensions.space7,
          ),
          child: Column(
            children: [
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: block(90, 20),
              ),
              const SizedBox(height: AppDimensions.space6),
              block(106, 106, r: 53),
              const SizedBox(height: AppDimensions.space4),
              block(170, 22),
              const SizedBox(height: AppDimensions.space2),
              block(200, 12),
              const SizedBox(height: AppDimensions.space4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  block(80, 28, r: 14),
                  const SizedBox(width: AppDimensions.space2),
                  block(80, 28, r: 14),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
