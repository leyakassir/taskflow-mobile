import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taskflow_mobile/app/router/route_names.dart';
import 'package:taskflow_mobile/app/theme/app_dimensions.dart';
import 'package:taskflow_mobile/features/onboarding/providers/onboarding_provider.dart';
import 'package:taskflow_mobile/features/onboarding/widgets/onboarding_card.dart';
import 'package:taskflow_mobile/features/onboarding/widgets/onboarding_indicator.dart';
import 'package:taskflow_mobile/l10n/gen/app_localizations.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await ref.read(onboardingControllerProvider.notifier).markSeen();
    if (mounted) context.go(RouteNames.login);
  }

  Future<void> _next(bool isLast) async {
    if (isLast) return _finish();
    await _controller.nextPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final slides = [
      OnboardingCardData(
        icon: Icons.task_alt_rounded,
        title: l10n.onboardingTitle1,
        description: l10n.onboardingDesc1,
      ),
      OnboardingCardData(
        icon: Icons.upload_file_rounded,
        title: l10n.onboardingTitle2,
        description: l10n.onboardingDesc2,
      ),
      OnboardingCardData(
        icon: Icons.notifications_active_outlined,
        title: l10n.onboardingTitle3,
        description: l10n.onboardingDesc3,
      ),
    ];
    final isLast = _index == slides.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip: top end, text only. Hidden on the last page, where the
            // main button already finishes onboarding.
            SizedBox(
              height: 56,
              child: Align(
                alignment: AlignmentDirectional.centerEnd,
                child: AnimatedOpacity(
                  opacity: isLast ? 0 : 1,
                  duration: const Duration(milliseconds: 200),
                  child: TextButton(
                    onPressed: isLast ? null : _finish,
                    style: TextButton.styleFrom(
                      foregroundColor: colors.onSurfaceVariant,
                    ),
                    child: Text(l10n.skip),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 540),
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: slides.length,
                    onPageChanged: (index) => setState(() => _index = index),
                    // Pages fade as they slide: fully visible when centered.
                    itemBuilder: (context, index) => AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        final page =
                            _controller.hasClients &&
                                _controller.position.haveDimensions
                            ? _controller.page ?? _index.toDouble()
                            : _index.toDouble();
                        final distance = (page - index).abs().clamp(0.0, 1.0);
                        return Opacity(
                          opacity: 1 - distance * 0.6,
                          child: child,
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.pagePadding,
                          vertical: AppDimensions.space2,
                        ),
                        child: OnboardingCard(data: slides[index]),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.space5),
            OnboardingIndicator(count: slides.length, index: _index),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.pagePadding,
                AppDimensions.space5,
                AppDimensions.pagePadding,
                AppDimensions.space5,
              ),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => _next(isLast),
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(isLast ? l10n.getStarted : l10n.next),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
