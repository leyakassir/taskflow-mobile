import 'package:flutter/material.dart';
import 'package:taskflow_mobile/app/theme/app_dimensions.dart';
import 'package:taskflow_mobile/app/theme/app_text_styles.dart';
import 'package:taskflow_mobile/features/auth/widgets/login_form.dart';
import 'package:taskflow_mobile/l10n/gen/app_localizations.dart';

/// Indigo header (40% of the screen) with the wordmark, and a surface card
/// with rounded top corners that slides up over it with the form.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  static const _cardRadius = 28.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.primary,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final headerHeight = constraints.maxHeight * 0.4;
          return SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: headerHeight,
                  child: SafeArea(
                    bottom: false,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppDimensions.pagePadding,
                          0,
                          AppDimensions.pagePadding,
                          _cardRadius,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              l10n.appName,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.displayLarge.copyWith(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: colors.onPrimary,
                              ),
                            ),
                            const SizedBox(height: AppDimensions.space2),
                            Text(
                              l10n.loginTagline,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: colors.onPrimary.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 450),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) => Transform.translate(
                    offset: Offset(0, (1 - value) * 80),
                    child: child,
                  ),
                  child: Container(
                    width: double.infinity,
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - headerHeight,
                    ),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(_cardRadius),
                      ),
                    ),
                    child: SafeArea(
                      top: false,
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 440),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(
                              AppDimensions.space6,
                              AppDimensions.space7,
                              AppDimensions.space6,
                              AppDimensions.space6,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  l10n.loginWelcomeBack,
                                  style: AppTextStyles.displaySmall.copyWith(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: colors.onSurface,
                                  ),
                                ),
                                const SizedBox(height: AppDimensions.space1),
                                Text(
                                  l10n.loginSubtitle,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: AppDimensions.space6),
                                const LoginForm(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
