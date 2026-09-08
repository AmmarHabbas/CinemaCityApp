import 'package:flutter/material.dart';
import 'onboarding_screen.dart';
import 'auth_gate.dart';

class SplashScreen extends StatefulWidget {
  final bool onboardingCompleted;

  const SplashScreen({
    super.key,
    required this.onboardingCompleted,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoAnimation;
  late Animation<double> _textAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _logoAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    _textAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(
        0.35,
        1.0,
        curve: Curves.easeOut,
      ),
    );

    _controller.forward();

    _goNext();
  }

  Future<void> _goNext() async {
    await Future.delayed(
      const Duration(seconds: 3),
    );

    if (!mounted) return;

    // ==========================================================
    // FIRST TIME OPENING THE APP
    // ==========================================================
    //
    // Show onboarding first.
    //
    if (!widget.onboardingCompleted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const OnboardingScreen(),
        ),
      );

      return;
    }

    // ==========================================================
    // ONBOARDING ALREADY COMPLETED
    // ==========================================================
    //
    // Let Firebase decide whether the user is logged in.
    //
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const AuthGate(
          showAuthChoice: true,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050606),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _logoAnimation,
              child: FadeTransition(
                opacity: _logoAnimation,
                child: Image.asset(
                  'assets/logo/cinemacitylogo.png',
                  width: 180,
                  height: 180,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 24),
            FadeTransition(
              opacity: _textAnimation,
              child: const Column(
                children: [
                  Text(
                    'CINEMA CITY',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'YOUR MOVIE EXPERIENCE',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2.5,
                      color: Colors.white38,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
