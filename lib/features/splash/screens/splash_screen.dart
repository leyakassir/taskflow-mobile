import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taskflow_mobile/app/theme/app_colors.dart';
import 'package:taskflow_mobile/app/theme/app_dimensions.dart';
import 'package:taskflow_mobile/app/theme/app_text_styles.dart';
import 'package:taskflow_mobile/features/splash/providers/splash_provider.dart';
import 'package:taskflow_mobile/features/splash/widgets/splash_background_painter.dart';
import 'package:taskflow_mobile/features/splash/widgets/splash_error_panel.dart';
import 'package:taskflow_mobile/features/splash/widgets/splash_loading_bar.dart';
import 'package:taskflow_mobile/features/splash/widgets/splash_logo.dart';
import 'package:taskflow_mobile/l10n/gen/app_localizations.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  /// The splash stays up at least this long, counted from when it is first
  /// shown (also on first launch, when there is no session to check).
  static const minimumDuration = Duration(seconds: 5);

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  ProviderSubscription<AsyncValue<String>>? _sub;
  bool _navigated = false;
  final _shownAt = Stopwatch()..start();

  late final AnimationController _introController;
  late final AnimationController _ambientController;
  late final AnimationController _pulseController;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _textFade;
  late final Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();

    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _logoScale = Tween<double>(begin: 0.6, end: 1).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0, 0.6, curve: Curves.elasticOut),
      ),
    );
    _logoFade = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0, 0.35, curve: Curves.easeOut),
    );
    _textFade = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.35, 0.8, curve: Curves.easeOut),
    );
    _textSlide = Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _introController,
            curve: const Interval(0.35, 0.9, curve: Curves.easeOutCubic),
          ),
        );

    _sub = ref.listenManual<AsyncValue<String>>(
      splashControllerProvider,
      (previous, next) => next.whenOrNull(data: _goWhenReady),
      fireImmediately: true,
    );
  }

  Future<void> _goWhenReady(String route) async {
    if (_navigated) return;
    _navigated = true;
    final remaining = SplashScreen.minimumDuration - _shownAt.elapsed;
    if (remaining > Duration.zero) await Future<void>.delayed(remaining);
    if (mounted) context.go(route);
  }

  @override
  void dispose() {
    _sub?.close();
    _introController.dispose();
    _ambientController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final splash = ref.watch(splashControllerProvider);
    const onBrand = Colors.white;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF7C8BFF),
                AppColors.brandBlue,
                AppColors.brandBlueDark,
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: SplashBackgroundPainter(
                    animation: _ambientController,
                    foregroundColor: onBrand,
                  ),
                ),
              ),
              SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(
                            AppDimensions.pagePadding,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              FadeTransition(
                                opacity: _logoFade,
                                child: ScaleTransition(
                                  scale: _logoScale,
                                  child: AnimatedBuilder(
                                    animation: _pulseController,
                                    builder: (context, _) => SplashLogo(
                                      label: l10n.appName,
                                      primaryColor: AppColors.brandBlue,
                                      foregroundColor: onBrand,
                                      glow: _pulseController.value,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppDimensions.space2),
                              FadeTransition(
                                opacity: _textFade,
                                child: SlideTransition(
                                  position: _textSlide,
                                  child: Text(
                                    l10n.splashTagline,
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.headingSmall.copyWith(
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.4,
                                      color: onBrand.withValues(alpha: 0.85),
                                    ),
                                  ),
                                ),
                              ),
                              if (splash.hasError) ...[
                                const SizedBox(height: AppDimensions.space7),
                                Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(
                                      AppDimensions.space5,
                                    ),
                                    child: SplashErrorPanel(
                                      error: splash.error!,
                                      onRetry: () => ref.invalidate(
                                        splashControllerProvider,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (!splash.hasError)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppDimensions.space7,
                          0,
                          AppDimensions.space7,
                          AppDimensions.space7,
                        ),
                        child: SplashLoadingBar(
                          label: l10n.splashLoading,
                          color: onBrand,
                          duration: SplashScreen.minimumDuration,
                        ),
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
