import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );

  // Logo
  late final Animation<double> _logoScale = Tween<double>(
    begin: 0.55,
    end: 1.0,
  ).animate(CurvedAnimation(
    parent: _ctrl,
    curve: const Interval(0.0, 0.55, curve: Curves.elasticOut),
  ));

  late final Animation<double> _logoFade = Tween<double>(
    begin: 0.0,
    end: 1.0,
  ).animate(CurvedAnimation(
    parent: _ctrl,
    curve: const Interval(0.0, 0.25, curve: Curves.easeIn),
  ));

  // Glow pulse behind logo (subtle)
  late final Animation<double> _glowOpacity = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.55), weight: 30),
    TweenSequenceItem(tween: Tween(begin: 0.55, end: 0.3), weight: 70),
  ]).animate(CurvedAnimation(
    parent: _ctrl,
    curve: const Interval(0.0, 0.6),
  ));

  // Title
  late final Animation<Offset> _titleSlide = Tween<Offset>(
    begin: const Offset(0, 0.35),
    end: Offset.zero,
  ).animate(CurvedAnimation(
    parent: _ctrl,
    curve: const Interval(0.3, 0.65, curve: Curves.easeOutCubic),
  ));

  late final Animation<double> _titleFade = Tween<double>(
    begin: 0.0,
    end: 1.0,
  ).animate(CurvedAnimation(
    parent: _ctrl,
    curve: const Interval(0.3, 0.58, curve: Curves.easeIn),
  ));

  // Tagline
  late final Animation<double> _taglineFade = Tween<double>(
    begin: 0.0,
    end: 1.0,
  ).animate(CurvedAnimation(
    parent: _ctrl,
    curve: const Interval(0.52, 0.75, curve: Curves.easeIn),
  ));

  // Dots loader
  late final Animation<double> _dotsFade = Tween<double>(
    begin: 0.0,
    end: 1.0,
  ).animate(CurvedAnimation(
    parent: _ctrl,
    curve: const Interval(0.72, 0.92, curve: Curves.easeIn),
  ));

  @override
  void initState() {
    super.initState();
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) => Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1E1B4B), // indigo-950
                Color(0xFF0F172A), // slate-900
                Color(0xFF0F172A),
              ],
              stops: [0.0, 0.45, 1.0],
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                // Centered content
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ── Logo ───────────────────────────────────────
                      FadeTransition(
                        opacity: _logoFade,
                        child: ScaleTransition(
                          scale: _logoScale,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Glow
                              Opacity(
                                opacity: _glowOpacity.value,
                                child: Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary
                                            .withAlpha(160),
                                        blurRadius: 60,
                                        spreadRadius: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Icon container
                              Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      AppColors.primary,
                                      AppColors.primary.withAlpha(200),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(26),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withAlpha(100),
                                      blurRadius: 24,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.location_on_rounded,
                                  color: Colors.white,
                                  size: 46,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // ── App name ────────────────────────────────────
                      SlideTransition(
                        position: _titleSlide,
                        child: FadeTransition(
                          opacity: _titleFade,
                          child: const Text(
                            'Tourist Pass Cyprus',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // ── Tagline ─────────────────────────────────────
                      FadeTransition(
                        opacity: _taglineFade,
                        child: const Text(
                          'Exclusive discounts across Cyprus',
                          style: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 15,
                          ),
                        ),
                      ),

                      const SizedBox(height: 64),

                      // ── Pulsing dots ────────────────────────────────
                      FadeTransition(
                        opacity: _dotsFade,
                        child: const _PulsingDots(),
                      ),
                    ],
                  ),
                ),

                // Bottom branding
                Positioned(
                  bottom: 24,
                  left: 0,
                  right: 0,
                  child: FadeTransition(
                    opacity: _taglineFade,
                    child: const Text(
                      'by Malaka Cyprus · malaka.cy',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF334155),
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Pulsing 3-dot loader ──────────────────────────────────────────────────────

class _PulsingDots extends StatefulWidget {
  const _PulsingDots();

  @override
  State<_PulsingDots> createState() => _PulsingDotsState();
}

class _PulsingDotsState extends State<_PulsingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  )..repeat();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          // Each dot's peak is at 1/3, 2/3, 3/3 of the cycle
          final phase = i / 3.0;
          final t = (_ctrl.value - phase) % 1.0;
          // Sine pulse: 0 → 1 → 0 over the cycle
          final pulse = math.sin(math.pi * (t < 0.5 ? t * 2 : 0.0));
          final opacity = 0.25 + 0.75 * pulse;
          final scale = 0.7 + 0.3 * pulse;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Transform.scale(
              scale: scale,
              child: Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha((opacity * 255).round()),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
