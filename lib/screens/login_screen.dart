import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cinema_ui_reference/screens/home_screen.dart';
import 'package:cinema_ui_reference/screens/signup_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'auth_widgets.dart';
import 'otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController phone = TextEditingController();

  bool loading = false;

  String? verificationId;

  @override
  void dispose() {
    phone.dispose();
    super.dispose();
  }

  // ============================================================
  // PHONE NORMALIZATION
  // ============================================================

  String _normalizePhone(String value) {
    String result = value.trim();

    // Remove spaces.
    result = result.replaceAll(' ', '');

    // Remove dashes.
    result = result.replaceAll('-', '');

    // Remove parentheses.
    result = result.replaceAll('(', '');
    result = result.replaceAll(')', '');

    // Convert 00XXXXXXXX to +XXXXXXXX.
    if (result.startsWith('00')) {
      result = '+${result.substring(2)}';
    }

    return result;
  }

  // ============================================================
  // PHONE VALIDATION
  // ============================================================

  String? validatePhone(String value) {
    final cleaned = _normalizePhone(value);

    if (cleaned.isEmpty) {
      return 'Please enter your phone number.';
    }

    // E.164 format:
    //
    // +15551234567
    // +96170123456
    // +819012345678
    //
    final phoneRegex = RegExp(
      r'^\+[1-9]\d{7,14}$',
    );

    if (!phoneRegex.hasMatch(cleaned)) {
      return 'Enter a valid international phone number.\n'
          'Example: +15551234567';
    }

    return null;
  }

  // ============================================================
  // SEND OTP
  // ============================================================

  Future<void> _sendOtp() async {
    if (loading) return;

    FocusScope.of(context).unfocus();

    final phoneNumber = _normalizePhone(phone.text);

    final phoneError = validatePhone(phoneNumber);

    if (phoneError != null) {
      _showError(phoneError);
      return;
    }

    setState(() {
      loading = true;
    });

    debugPrint('================================');
    debugPrint('CINEMA APP LOGIN');
    debugPrint('Phone: $phoneNumber');
    debugPrint('================================');

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,

        // ======================================================
        // AUTOMATIC VERIFICATION
        // ======================================================

        verificationCompleted: (PhoneAuthCredential credential) async {
          debugPrint(
            'Firebase automatic verification completed.',
          );

          try {
            final UserCredential credentialResult =
                await FirebaseAuth.instance.signInWithCredential(
              credential,
            );

            final User? user = credentialResult.user;

            if (user == null) {
              throw FirebaseAuthException(
                code: 'user-null',
                message: 'Firebase did not return a user.',
              );
            }

            await _finishLogin(user);
          } on FirebaseAuthException catch (e) {
            debugPrint(
              'Automatic login Firebase error: ${e.code}',
            );

            if (!mounted) return;

            setState(() {
              loading = false;
            });

            _showError(
              _firebaseError(e),
            );
          } catch (e) {
            debugPrint(
              'Automatic login error: $e',
            );

            if (!mounted) return;

            setState(() {
              loading = false;
            });

            _showError(
              'Could not sign in. Please try again.',
            );
          }
        },

        // ======================================================
        // VERIFICATION FAILED
        // ======================================================

        verificationFailed: (FirebaseAuthException e) {
          debugPrint('================================');
          debugPrint('PHONE AUTH FAILED');
          debugPrint('Code: ${e.code}');
          debugPrint('Message: ${e.message}');
          debugPrint('================================');

          if (!mounted) return;

          setState(() {
            loading = false;
          });

          _showError(
            _firebaseError(e),
          );
        },

        // ======================================================
        // OTP SENT
        // ======================================================

        codeSent: (
          String id,
          int? resendToken,
        ) {
          debugPrint(
            'Firebase login OTP sent.',
          );

          verificationId = id;

          if (!mounted) return;

          setState(() {
            loading = false;
          });

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OtpScreen(
                phone: phoneNumber,
                verificationId: id,

                // This is a LOGIN flow.
                isSignUp: false,
              ),
            ),
          );
        },

        // ======================================================
        // TIMEOUT
        // ======================================================

        codeAutoRetrievalTimeout: (String id) {
          debugPrint(
            'Firebase SMS auto retrieval timeout.',
          );

          verificationId = id;
        },
      );
    } on FirebaseAuthException catch (e) {
      debugPrint(
        'LOGIN FirebaseAuthException: ${e.code}',
      );

      if (!mounted) return;

      setState(() {
        loading = false;
      });

      _showError(
        _firebaseError(e),
      );
    } catch (e) {
      debugPrint(
        'LOGIN ERROR: $e',
      );

      if (!mounted) return;

      setState(() {
        loading = false;
      });

      _showError(
        'Unable to send verification code.\n$e',
      );
    }
  }

  // ============================================================
  // FINISH LOGIN
  // ============================================================

  Future<void> _finishLogin(User user) async {
    debugPrint(
      'Firebase user UID: ${user.uid}',
    );

    // Look for the user's CinemaApp profile.
    final DocumentSnapshot<Map<String, dynamic>> userDoc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

    // ==========================================================
    // USER DOES NOT HAVE A CINEMAAPP ACCOUNT
    // ==========================================================

    if (!userDoc.exists) {
      // Sign the Firebase user back out because this is
      // the SIGN-IN flow and this phone doesn't have a
      // CinemaApp account yet.
      await FirebaseAuth.instance.signOut();

      if (!mounted) return;

      setState(() {
        loading = false;
      });

      _showError(
        'No CinemaApp account was found for this phone number. '
        'Please create an account first.',
      );

      return;
    }

    // ==========================================================
    // USER EXISTS
    // ==========================================================

    debugPrint(
      'CinemaApp account found.',
    );

    if (!mounted) return;

    setState(() {
      loading = false;
    });

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const HomeScreen(),
      ),
      (route) => false,
    );
  }

  // ============================================================
  // FIREBASE ERRORS
  // ============================================================

  String _firebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-phone-number':
        return 'The phone number is invalid. '
            'Check the country code and number.';

      case 'operation-not-allowed':
        return 'Phone Authentication is not enabled in Firebase Console.';

      case 'too-many-requests':
        return 'Too many attempts. Please wait and try again later.';

      case 'quota-exceeded':
        return 'Firebase SMS quota has been exceeded.';

      case 'app-not-authorized':
        return 'This app is not authorized to use Firebase Phone Authentication.';

      case 'captcha-check-failed':
        return 'Firebase could not verify this device.';

      case 'network-request-failed':
        return 'Network error. Check your internet connection.';

      case 'invalid-verification-code':
        return 'The verification code is incorrect.';

      case 'session-expired':
        return 'The verification code has expired. Please request a new one.';

      default:
        return e.message ?? 'Phone verification failed.';
    }
  }

  // ============================================================
  // ERROR MESSAGE
  // ============================================================

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050606),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: const BackButton(),
        title: const Text(
          'Sign In',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          22,
          25,
          22,
          30,
        ),
        children: [
          const Text(
            'Welcome back.',
            style: TextStyle(
              fontSize: 31,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            'Enter your phone number and we’ll send you '
            'a verification code.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 34),

          // ======================================================
          // PHONE
          // ======================================================

          AuthTextField(
            label: 'PHONE NUMBER',
            hint: '+1 555 123 4567',
            keyboardType: TextInputType.phone,
            controller: phone,
          ),

          const SizedBox(height: 8),

          const Text(
            'Use international format, for example +15551234567.',
            style: TextStyle(
              color: Colors.white38,
              fontSize: 9,
            ),
          ),

          const SizedBox(height: 25),

          // ======================================================
          // SEND OTP
          // ======================================================

          SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: loading ? null : _sendOtp,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF3F0D6),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black,
                      ),
                    )
                  : const Text(
                      'Send OTP',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 18),

          // ======================================================
          // SIGN UP
          // ======================================================

          Center(
            child: TextButton(
              onPressed: loading
                  ? null
                  : () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SignUpScreen(),
                        ),
                      );
                    },
              child: const Text(
                'New here? Create an account',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 11,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
