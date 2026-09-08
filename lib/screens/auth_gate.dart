import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'login_screen.dart';
import 'auth_choice_screen.dart';

class AuthGate extends StatelessWidget {
  final bool showAuthChoice;

  const AuthGate({
    super.key,
    this.showAuthChoice = false,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Firebase is checking authentication state.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF050606),
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFFF3F0D6),
              ),
            ),
          );
        }

        // ======================================================
        // USER IS LOGGED IN
        // ======================================================

        if (snapshot.hasData) {
          return const HomeScreen();
        }

        // ======================================================
        // USER IS NOT LOGGED IN
        // ======================================================

        if (showAuthChoice) {
          return const AuthChoiceScreen();
        }

        return const LoginScreen();
      },
    );
  }
}
