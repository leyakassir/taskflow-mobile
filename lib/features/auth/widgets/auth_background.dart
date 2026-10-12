import 'package:flutter/material.dart';

import 'package:taskflow_mobile/app/theme/app_colors.dart';
import 'package:taskflow_mobile/features/splash/widgets/splash_background_painter.dart';

/// Brand gradient with slowly drifting shapes, shared by the splash and the
/// sign-in screens so the app opens into one continuous look.
class AuthBackground extends StatefulWidget {
  const AuthBackground({super.key, required this.child});

  final Widget child;

  static const gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7C8BFF), AppColors.brandBlue, AppColors.brandBlueDark],
  );

  @override
  State<AuthBackground> createState() => _AuthBackgroundState();
}

class _AuthBackgroundState extends State<AuthBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ambient = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 14),
  )..repeat();

  @override
  void dispose() {
    _ambient.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AuthBackground.gradient),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: SplashBackgroundPainter(
                animation: reduceMotion
                    ? const AlwaysStoppedAnimation(0)
                    : _ambient,
                foregroundColor: Colors.white,
              ),
            ),
          ),
          widget.child,
        ],
      ),
    );
  }
}
