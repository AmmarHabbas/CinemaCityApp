import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'auth_widgets.dart';
import 'otp_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController phone = TextEditingController();
  final TextEditingController name = TextEditingController();

  bool loading = false;

  @override
  void dispose() {
    phone.dispose();
    name.dispose();
    super.dispose();
  }

  // ============================================================
  // NAME VALIDATION
  // ============================================================

  bool _isValidName(String value) {
    final parts = value
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    // Must contain at least:
    // First name + Second name
    if (parts.length < 2) {
      return false;
    }

    for (final part in parts) {
      if (!RegExp(r"^[a-zA-ZÀ-ÿ'-]+$").hasMatch(part)) {
        return false;
      }
    }

    return true;
  }

  // ============================================================
  // PHONE NORMALIZATION
  // ============================================================

  String _normalizePhone(String value) {
    String result = value.trim();

    // Remove spaces, dashes and parentheses.
    result = result.replaceAll(
      RegExp(r'[\s\-\(\)]'),
      '',
    );

    // Convert:
    // 00963982708372
    // to:
    // +963982708372
    if (result.startsWith('00')) {
      result = '+${result.substring(2)}';
    }

    return result;
  }

  // ============================================================
  // PHONE VALIDATION
  // ============================================================

  bool _isValidPhone(String value) {
    // Firebase Phone Auth expects an international
    // E.164-style phone number.
    //
    // Examples:
    //
    // +14155552671
    // +96170123456
    // +963982708372
    // +819012345678

    return RegExp(r'^\+[1-9]\d{7,14}$').hasMatch(value);
  }

  // ============================================================
  // SHOW MESSAGE
  // ============================================================

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  // ============================================================
  // CREATE FIRESTORE USER PROFILE
  // ============================================================

  Future<void> _createUserProfile({
    required User user,
    required String enteredName,
    required String enteredPhone,
  }) async {
    final userRef =
        FirebaseFirestore.instance.collection('users').doc(user.uid);

    await userRef.set(
      {
        'uid': user.uid,
        'name': enteredName,
        'phoneNumber': enteredPhone,
        'createdAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    debugPrint('================================');
    debugPrint('FIRESTORE USER PROFILE CREATED');
    debugPrint('UID: ${user.uid}');
    debugPrint('Name: $enteredName');
    debugPrint('Phone: $enteredPhone');
    debugPrint('================================');
  }

  // ============================================================
  // SEND SIGN UP OTP
  // ============================================================

  Future<void> _continue() async {
    if (loading) return;

    FocusScope.of(context).unfocus();

    final enteredName = name.text.trim();
    final enteredPhone = _normalizePhone(phone.text);

    // ==========================================================
    // VALIDATE NAME
    // ==========================================================

    if (enteredName.isEmpty) {
      _showMessage(
        'Please enter your full name.',
      );
      return;
    }

    if (!_isValidName(enteredName)) {
      _showMessage(
        'Please enter your first name and second name.',
      );
      return;
    }

    // ==========================================================
    // VALIDATE PHONE
    // ==========================================================

    if (enteredPhone.isEmpty) {
      _showMessage(
        'Please enter your phone number.',
      );
      return;
    }

    if (!_isValidPhone(enteredPhone)) {
      _showMessage(
        'Enter a valid international phone number.\n'
        'Example: +14155552671',
      );
      return;
    }

    setState(() {
      loading = true;
    });

    debugPrint('================================');
    debugPrint('CINEMA APP SIGN UP');
    debugPrint('Name: $enteredName');
    debugPrint('Phone: $enteredPhone');
    debugPrint('================================');

    try {
      // ========================================================
      // IMPORTANT
      // ========================================================
      //
      // DO NOT QUERY FIRESTORE HERE.
      //
      // There is intentionally NO:
      //
      // FirebaseFirestore.instance
      //     .collection('users')
      //     .where('phoneNumber', ...)
      //
      // Firebase Authentication handles the phone verification.
      // ========================================================

      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: enteredPhone,

        // ======================================================
        // AUTOMATIC VERIFICATION
        // ======================================================

        verificationCompleted: (
          PhoneAuthCredential credential,
        ) async {
          debugPrint(
            'Firebase automatic verification completed.',
          );

          try {
            final UserCredential result =
                await FirebaseAuth.instance.signInWithCredential(
              credential,
            );

            final User? user = result.user;

            if (user == null) {
              throw Exception(
                'Firebase did not return a user.',
              );
            }

            // Create the Firestore profile.
            await _createUserProfile(
              user: user,
              enteredName: enteredName,
              enteredPhone: enteredPhone,
            );

            if (!mounted) return;

            setState(() {
              loading = false;
            });

            Navigator.pushNamedAndRemoveUntil(
              context,
              '/home',
              (route) => false,
            );
          } on FirebaseAuthException catch (e) {
            debugPrint(
              'Automatic signup Firebase error: ${e.code}',
            );

            if (!mounted) return;

            setState(() {
              loading = false;
            });

            _showMessage(
              _firebaseError(e),
            );
          } catch (e) {
            debugPrint(
              'Automatic signup error: $e',
            );

            if (!mounted) return;

            setState(() {
              loading = false;
            });

            _showMessage(
              'Account creation failed. Please try again.',
            );
          }
        },

        // ======================================================
        // VERIFICATION FAILED
        // ======================================================

        verificationFailed: (
          FirebaseAuthException e,
        ) {
          debugPrint('================================');
          debugPrint('SIGN UP PHONE AUTH FAILED');
          debugPrint('Code: ${e.code}');
          debugPrint('Message: ${e.message}');
          debugPrint('================================');

          if (!mounted) return;

          setState(() {
            loading = false;
          });

          _showMessage(
            _firebaseError(e),
          );
        },

        // ======================================================
        // OTP SENT
        // ======================================================

        codeSent: (
          String verificationId,
          int? resendToken,
        ) {
          debugPrint(
            'Firebase signup OTP sent.',
          );

          if (!mounted) return;

          setState(() {
            loading = false;
          });

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OtpScreen(
                phone: enteredPhone,
                verificationId: verificationId,
                name: enteredName,
                isSignUp: true,
              ),
            ),
          );
        },

        // ======================================================
        // AUTO RETRIEVAL TIMEOUT
        // ======================================================

        codeAutoRetrievalTimeout: (
          String verificationId,
        ) {
          debugPrint(
            'Firebase SMS auto retrieval timeout.',
          );
        },
      );
    } on FirebaseAuthException catch (e) {
      debugPrint(
        'SIGN UP FirebaseAuthException: ${e.code}',
      );

      if (!mounted) return;

      setState(() {
        loading = false;
      });

      _showMessage(
        _firebaseError(e),
      );
    } catch (e) {
      debugPrint(
        'SIGN UP ERROR: $e',
      );

      if (!mounted) return;

      setState(() {
        loading = false;
      });

      _showMessage(
        'Unable to send verification code.\n$e',
      );
    }
  }

  // ============================================================
  // FIREBASE ERROR MESSAGES
  // ============================================================

  String _firebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-phone-number':
        return 'The phone number is invalid. Check the country code.';

      case 'too-many-requests':
        return 'Too many attempts. Please wait and try again later.';

      case 'quota-exceeded':
        return 'Firebase SMS quota has been exceeded.';

      case 'operation-not-allowed':
        return 'Phone Authentication is not enabled in Firebase Console.';

      case 'app-not-authorized':
        return 'This app is not authorized for Firebase Phone Authentication.';

      case 'network-request-failed':
        return 'Network error. Check your internet connection.';

      case 'captcha-check-failed':
        return 'Firebase could not verify this device. Please try again.';

      default:
        return e.message ?? 'Phone verification failed.';
    }
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
          'Create Account',
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
            'Let’s get you started.',
            style: TextStyle(
              fontSize: 29,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            'Enter your first and second name and a valid phone number. '
            'We’ll send you a verification code.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 32),

          // ======================================================
          // FULL NAME
          // ======================================================

          AuthTextField(
            label: 'FULL NAME',
            hint: 'John Smith',
            controller: name,
          ),

          const SizedBox(height: 8),

          const Text(
            'Enter at least your first name and second name.',
            style: TextStyle(
              color: Colors.white38,
              fontSize: 9,
            ),
          ),

          const SizedBox(height: 17),

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
            'Use international format, for example +14155552671.',
            style: TextStyle(
              color: Colors.white38,
              fontSize: 9,
            ),
          ),

          const SizedBox(height: 25),

          // ======================================================
          // CONTINUE
          // ======================================================

          SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: loading ? null : _continue,
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
                      'Continue',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 18),

          Center(
            child: TextButton(
              onPressed: loading ? null : () => Navigator.pop(context),
              child: const Text(
                'Already have an account? Sign in',
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
