import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'package:taskflow_mobile/app/router/route_names.dart';
import 'package:taskflow_mobile/app/theme/app_dimensions.dart';
import 'package:taskflow_mobile/app/theme/app_text_styles.dart';
import 'package:taskflow_mobile/features/auth/widgets/auth_background.dart';
import 'package:taskflow_mobile/features/auth/widgets/login_brand_header.dart';
import 'package:taskflow_mobile/features/auth/widgets/login_form.dart';
import 'package:taskflow_mobile/features/auth/widgets/login_language_toggle.dart';
import 'package:taskflow_mobile/l10n/gen/app_localizations.dart';

/// Brand gradient with the logo up top, and the sign-in form on a rounded
/// sheet that always reaches the bottom of the screen (no gradient below
/// it), however tall the phone is.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  static const _sheetRadius = 32.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: AuthBackground(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final short = constraints.maxHeight < 640;
              return SingleChildScrollView(
                // No bounce past the bottom, which would show the gradient.
                physics: const ClampingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        SafeArea(
                          bottom: false,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(
                              AppDimensions.pagePadding,
                              AppDimensions.space2,
                              AppDimensions.pagePadding,
                              0,
                            ),
                            child: const Align(
                              alignment: AlignmentDirectional.centerEnd,
                              child: LoginLanguageToggle(),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                            AppDimensions.pagePadding,
                            short ? AppDimensions.space4 : AppDimensions.space7,
                            AppDimensions.pagePadding,
                            short ? AppDimensions.space6 : AppDimensions.space8,
                          ),
                          child: LoginBrandHeader(compact: short),
                        ),
                        // The sheet takes all remaining height down to the
                        // bottom edge.
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: colors.surface,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(_sheetRadius),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.12),
                                  blurRadius: 24,
                                  offset: const Offset(0, -6),
                                ),
                              ],
                            ),
                            child: SafeArea(
                              top: false,
                              child: Align(
                                alignment: Alignment.topCenter,
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 460,
                                  ),
                                  child: TweenAnimationBuilder<double>(
                                    tween: Tween(begin: 0, end: 1),
                                    duration: const Duration(milliseconds: 500),
                                    curve: Curves.easeOutCubic,
                                    builder: (context, t, child) => Opacity(
                                      opacity: t,
                                      child: Transform.translate(
                                        offset: Offset(0, (1 - t) * 24),
                                        child: child,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        AppDimensions.space6,
                                        AppDimensions.space3,
                                        AppDimensions.space6,
                                        AppDimensions.space6,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Center(
                                            child: Container(
                                              width: 40,
                                              height: 4,
                                              decoration: BoxDecoration(
                                                color: colors.outlineVariant,
                                                borderRadius:
                                                    BorderRadius.circular(2),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: AppDimensions.space5,
                                          ),
                                          Text(
                                            l10n.loginWelcomeBack,
                                            style: AppTextStyles.displaySmall
                                                .copyWith(
                                                  fontWeight: FontWeight.w800,
                                                  color: colors.onSurface,
                                                ),
                                          ),
                                          const SizedBox(
                                            height: AppDimensions.space1,
                                          ),
                                          Text(
                                            l10n.loginSubtitle,
                                            style: AppTextStyles.bodyMedium
                                                .copyWith(
                                                  color:
                                                      colors.onSurfaceVariant,
                                                ),
                                          ),
                                          const SizedBox(
                                            height: AppDimensions.space6,
                                          ),
                                          const LoginForm(),
                                          Center(
                                            child: TextButton.icon(
                                              onPressed: () => context.push(
                                                RouteNames.signupRequest,
                                              ),
                                              icon: const Icon(
                                                Icons.person_add_alt_1_rounded,
                                                size: 18,
                                              ),
                                              label: Text(l10n.signupLink),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: AppDimensions.space2,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.verified_user_outlined,
                                                size: 16,
                                                color: colors.onSurfaceVariant,
                                              ),
                                              const SizedBox(
                                                width: AppDimensions.space1,
                                              ),
                                              Flexible(
                                                child: Text(
                                                  l10n.loginSecureNote,
                                                  style: AppTextStyles
                                                      .labelMedium
                                                      .copyWith(
                                                        color: colors
                                                            .onSurfaceVariant,
                                                      ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
