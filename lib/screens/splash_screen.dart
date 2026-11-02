import 'dart:async';

import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  final Widget nextScreen;

  const SplashScreen({super.key, required this.nextScreen});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late AnimationController _fadeController;
  late AnimationController _glowController;
  late AnimationController _rotationController;

  late Animation<double> _bounceAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();

    // Animasi bola voli.
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    _bounceAnimation = Tween<double>(begin: 0, end: -22).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOutSine),
    );

    // Animasi kemunculan tulisan VCLUB.
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _scaleAnimation = Tween<double>(begin: 0.88, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic),
    );

    // Efek cahaya di belakang bola.
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.12, end: 0.28).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // Rotasi bola yang sangat halus.
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000),
    )..repeat();

    _rotationAnimation = Tween<double>(begin: -0.08, end: 0.08).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.easeInOutSine),
    );

    _startAnimation();
  }

  Future<void> _startAnimation() async {
    _bounceController.repeat(reverse: true);

    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    _fadeController.forward();

    // Splash Screen tampil sekitar 6 detik.
    await Future.delayed(const Duration(milliseconds: 5500));

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, animation, secondaryAnimation) {
          return widget.nextScreen;
        },
        transitionsBuilder: (_, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 650),
      ),
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _fadeController.dispose();
    _glowController.dispose();
    _rotationController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0B1220), Color(0xFF142B4A), Color(0xFF0B1729)],
            stops: [0.0, 0.55, 1.0],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Bola voli dengan animasi.
              AnimatedBuilder(
                animation: Listenable.merge([
                  _bounceAnimation,
                  _rotationAnimation,
                  _glowAnimation,
                ]),
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _bounceAnimation.value),
                    child: Transform.rotate(
                      angle: _rotationAnimation.value,
                      child: Container(
                        width: 132,
                        height: 132,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.055),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF8ECAE6,
                              ).withOpacity(_glowAnimation.value),
                              blurRadius: 48,
                              spreadRadius: 8,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.sports_volleyball_rounded,
                            color: Colors.white,
                            size: 92,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 35),

              // Tulisan VCLUB.
              FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: const Text(
                    'VCLUB',
                    style: TextStyle(
                      fontSize: 39,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 9,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
