import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/app_theme.dart';
import 'dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _pulseController;
  late AnimationController _particleController;

  late Animation<double> _iconScale;
  late Animation<double> _iconRotation;
  late Animation<double> _titleOpacity;
  late Animation<Offset> _titleSlide;
  late Animation<double> _subtitleOpacity;
  late Animation<Offset> _subtitleSlide;
  late Animation<double> _fadeOut;
  late Animation<double> _glowOpacity;

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat();

    _iconScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 1.15,
        ).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.15,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 10,
      ),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 50),
    ]).animate(_mainController);

    _iconRotation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: -0.1,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 60),
    ]).animate(_mainController);

    _glowOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.6), weight: 30),
      TweenSequenceItem(tween: ConstantTween(0.6), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 0.6, end: 0.0), weight: 30),
    ]).animate(_mainController);

    _titleOpacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.3, 0.55, curve: Curves.easeOut),
      ),
    );
    _titleSlide = Tween(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.3, 0.55, curve: Curves.easeOutCubic),
      ),
    );

    _subtitleOpacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.42, 0.65, curve: Curves.easeOut),
      ),
    );
    _subtitleSlide = Tween(begin: const Offset(0, 0.5), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _mainController,
            curve: const Interval(0.42, 0.65, curve: Curves.easeOutCubic),
          ),
        );

    _fadeOut = Tween(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.82, 1.0, curve: Curves.easeIn),
      ),
    );

    _mainController.forward().then((_) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) =>
                const DashboardScreen(),
            transitionDuration: const Duration(milliseconds: 600),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Theme-aware colors
    final bgColor1 = isDark ? const Color(0xFF0A0A0F) : const Color(0xFFF0F2F8);
    final bgColor2 = isDark ? const Color(0xFF0F1628) : const Color(0xFFE8ECF6);
    final textColor = isDark ? Colors.white : const Color(0xFF18181B);
    final subtitleColor = isDark
        ? Colors.white.withValues(alpha: 0.5)
        : const Color(0xFF71717A);
    final barBgColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : const Color(0xFF18181B).withValues(alpha: 0.08);

    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _mainController,
          _pulseController,
          _particleController,
        ]),
        builder: (context, child) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [bgColor1, bgColor2, bgColor1],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
            child: FadeTransition(
              opacity: _fadeOut,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Animated particles
                  ..._buildParticles(isDark),
                  // Main content
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // Pulsating glow
                          Container(
                            width: 140 + (_pulseController.value * 20),
                            height: 140 + (_pulseController.value * 20),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  AppTheme.primaryColor.withValues(
                                    alpha:
                                        _glowOpacity.value *
                                        (isDark ? 0.4 : 0.25),
                                  ),
                                  AppTheme.primaryColor.withValues(
                                    alpha:
                                        _glowOpacity.value *
                                        (isDark ? 0.1 : 0.08),
                                  ),
                                  Colors.transparent,
                                ],
                                stops: const [0.0, 0.5, 1.0],
                              ),
                            ),
                          ),
                          // Icon container
                          Transform.scale(
                            scale: _iconScale.value,
                            child: Transform.rotate(
                              angle: _iconRotation.value,
                              child: Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  gradient: AppTheme.mainGradient,
                                  borderRadius: BorderRadius.circular(28),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.primaryColor.withValues(
                                        alpha: isDark ? 0.4 : 0.3,
                                      ),
                                      blurRadius: 30,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.account_balance_wallet_rounded,
                                  color: Colors.white,
                                  size: 42,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 36),
                      // Title
                      SlideTransition(
                        position: _titleSlide,
                        child: FadeTransition(
                          opacity: _titleOpacity,
                          child: Text(
                            'Finance Tracker',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: textColor,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Subtitle
                      SlideTransition(
                        position: _subtitleSlide,
                        child: FadeTransition(
                          opacity: _subtitleOpacity,
                          child: Text(
                            'Harcamalarını akıllıca yönet',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: subtitleColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Bottom loading bar
                  Positioned(
                    bottom: 80,
                    child: FadeTransition(
                      opacity: _subtitleOpacity,
                      child: _buildLoadingBar(barBgColor),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingBar(Color barBgColor) {
    final progress = Tween(begin: 0.0, end: 1.0)
        .animate(
          CurvedAnimation(
            parent: _mainController,
            curve: const Interval(0.45, 0.85, curve: Curves.easeInOut),
          ),
        )
        .value;

    return Container(
      width: 120,
      height: 3,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        color: barBgColor,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          width: 120 * progress,
          height: 3,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            gradient: const LinearGradient(
              colors: [Color(0xFF2D6AEE), Color(0xFF8B5CF6)],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildParticles(bool isDark) {
    final particles = <Widget>[];
    final rng = math.Random(42);

    for (int i = 0; i < 12; i++) {
      final x = rng.nextDouble() * 2 - 1;
      final y = rng.nextDouble() * 2 - 1;
      final size = 2.0 + rng.nextDouble() * 3;
      final delay = rng.nextDouble();

      final opacity =
          math.sin((_particleController.value + delay) * math.pi * 2).abs() *
          (isDark ? 0.3 : 0.2);

      particles.add(
        Positioned(
          left: MediaQuery.of(context).size.width * (0.5 + x * 0.4),
          top: MediaQuery.of(context).size.height * (0.5 + y * 0.35),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:
                  (i.isEven ? AppTheme.primaryColor : const Color(0xFF8B5CF6))
                      .withValues(alpha: opacity),
            ),
          ),
        ),
      );
    }
    return particles;
  }
}
