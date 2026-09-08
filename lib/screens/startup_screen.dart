import 'package:cinema_ui_reference/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_screen.dart';
import 'onboarding_screen.dart';

class StartupScreen extends StatefulWidget {
  const StartupScreen({super.key});

  @override
  State<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen> {
  @override
  void initState() {
    super.initState();

    _checkStartup();
  }

  Future<void> _checkStartup() async {
    final prefs = await SharedPreferences.getInstance();

    final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;

    final currentUser = FirebaseAuth.instance.currentUser;

    if (!mounted) return;

    // ==========================================================
    // FIRST EVER APP OPEN
    // ==========================================================

    if (!onboardingCompleted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const OnboardingScreen(),
        ),
      );

      return;
    }

    // ==========================================================
    // USER IS ALREADY SIGNED IN
    // ==========================================================

    if (currentUser != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        ),
      );

      return;
    }

    // ==========================================================
    // ONBOARDING DONE BUT USER IS NOT SIGNED IN
    // ==========================================================

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF050606),
      body: Center(
        child: CircularProgressIndicator(
          color: Color(0xFFF3F0D6),
        ),
      ),
    );
  }
}
