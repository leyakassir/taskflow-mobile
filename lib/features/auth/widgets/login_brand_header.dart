import 'package:flutter/material.dart';

import 'package:taskflow_mobile/app/theme/app_dimensions.dart';
import 'package:taskflow_mobile/app/theme/app_text_styles.dart';
import 'package:taskflow_mobile/l10n/gen/app_localizations.dart';

/// The app logo with a soft glow, the TaskFlow name and tagline. Fades and
/// scales in once when the screen opens.
class LoginBrandHeader extends StatelessWidget {
  const LoginBrandHeader({super.key, this.compact = false});

  /// Smaller logo for short screens (e.g. keyboard open, landscape).
  final bool compact;

  static const logoAsset = 'assets/icons/taskflow_icon.png';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final logoSize = compact ? 64.0 : 92.0;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutBack,
      builder: (context, t, child) => Opacity(
        opacity: t.clamp(0.0, 1.0),
        child: Transform.scale(scale: 0.85 + 0.15 * t, child: child),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(logoSize * 0.28),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.35),
                  blurRadius: 32,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(logoSize * 0.28),
              child: Image.asset(
                logoAsset,
                width: logoSize,
                height: logoSize,
                fit: BoxFit.cover,
                semanticLabel: l10n.appName,
              ),
            ),
          ),
          SizedBox(
            height: compact ? AppDimensions.space3 : AppDimensions.space4,
          ),
          Text(
            l10n.appName,
            textAlign: TextAlign.center,
            style: AppTextStyles.displayLarge.copyWith(
              fontSize: compact ? 28 : 34,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppDimensions.space1),
          Text(
            l10n.loginTagline,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}
