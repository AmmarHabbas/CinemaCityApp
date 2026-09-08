import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'home_screen.dart';

class OtpScreen extends StatefulWidget {
  final String phone;
  final String verificationId;

  // Only needed when creating a new account.
  final String? name;

  // true = Sign Up
  // false = Sign In
  final bool isSignUp;

  const OtpScreen({
    super.key,
    required this.phone,
    required this.verificationId,
    this.name,
    required this.isSignUp,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> codes =
      List.generate(6, (_) => TextEditingController());

  final List<FocusNode> nodes = List.generate(6, (_) => FocusNode());

  Timer? timer;

  int seconds = 30;
  bool loading = false;

  String get code => codes.map((controller) => controller.text).join();

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (!mounted) return;

        if (seconds > 0) {
          setState(() {
            seconds--;
          });
        }
      },
    );

    // Focus first box automatically.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        nodes.first.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();

    for (final controller in codes) {
      controller.dispose();
    }

    for (final node in nodes) {
      node.dispose();
    }

    super.dispose();
  }

  // ============================================================
  // VERIFY OTP
  // ============================================================

  Future<void> verify() async {
    if (loading) return;

    final otp = code;

    if (otp.length != 6) {
      _showMessage(
        'Please enter the 6-digit verification code.',
      );
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      loading = true;
    });

    try {
      // Create Firebase phone credential.
      final credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: otp,
      );

      // Sign in to Firebase.
      //
      // For a new phone number Firebase creates the
      // Firebase Authentication account automatically.
      //
      // For an existing phone number Firebase signs
      // the existing user in.
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(
        credential,
      );

      final User? user = userCredential.user;

      if (user == null) {
        throw Exception('Firebase did not return a user.');
      }

      final userRef =
          FirebaseFirestore.instance.collection('users').doc(user.uid);

      final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;

// ==========================================================
// SIGN UP
// ==========================================================

      if (widget.isSignUp) {
        // If Firebase says this phone already has an account,
        // don't allow the user to create another account.
        if (!isNewUser) {
          await FirebaseAuth.instance.signOut();

          throw FirebaseAuthException(
            code: 'account-already-exists',
            message: 'An account with this phone number already exists. '
                'Please sign in instead.',
          );
        }

        // New Firebase account.
        await userRef.set({
          'uid': user.uid,
          'name': widget.name ?? '',
          'phoneNumber': widget.phone,
          'createdAt': FieldValue.serverTimestamp(),
        });

        debugPrint('New CinemaApp user created: ${user.uid}');
      }

// ==========================================================
// SIGN IN
// ==========================================================

      else {
        // Sign in does NOT search Firestore by phone number.

        final userSnapshot = await userRef.get();

        // If the Firebase Auth account exists but the Firestore
        // profile doesn't exist, create the profile.
        if (!userSnapshot.exists) {
          await userRef.set(
            {
              'uid': user.uid,
              'phoneNumber': widget.phone,
              'name': '',
              'createdAt': FieldValue.serverTimestamp(),
            },
            SetOptions(merge: true),
          );
        }

        debugPrint('CinemaApp user signed in: ${user.uid}');
      }

      if (!mounted) return;

      // FirebaseAuth.instance.currentUser is now set.
      //
      // Remove all authentication screens from the navigation
      // stack and open the application.
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        ),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      String message;

      switch (e.code) {
        case 'invalid-verification-code':
          message = 'The verification code is incorrect.';
          break;

        case 'session-expired':
          message =
              'This verification code has expired. Please request a new one.';
          break;

        case 'invalid-verification-id':
          message =
              'This verification session is invalid. Please request a new code.';
          break;
        case 'account-already-exists':
          message = 'An account with this phone number already exists. '
              'Please sign in instead.';
          break;

        case 'credential-already-in-use':
          message = 'This phone number is already associated with an account.';
          break;

        case 'too-many-requests':
          message = 'Too many verification attempts. Please try again later.';
          break;

        case 'network-request-failed':
          message = 'Network error. Please check your internet connection.';
          break;

        default:
          message = e.message ?? 'Verification failed. Please try again.';
      }

      _showMessage(message);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      _showMessage(
        'Something went wrong. Please try again.',
      );
    }
  }

  // ============================================================
  // RESEND
  // ============================================================

  void resend() {
    // The current verificationId cannot simply be reused.
    //
    // We return to the previous screen so it can call
    // FirebaseAuth.verifyPhoneNumber() again.
    if (seconds != 0) return;

    Navigator.pop(context);
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  // ============================================================
  // OTP INPUT
  // ============================================================

  void _onCodeChanged(String value, int index) {
    if (value.isNotEmpty) {
      if (index < 5) {
        nodes[index + 1].requestFocus();
      }
    } else {
      if (index > 0) {
        nodes[index - 1].requestFocus();
      }
    }

    // Verify automatically after the sixth digit.
    if (code.length == 6 && !loading) {
      verify();
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
          'Verify Phone',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(
          22,
          28,
          22,
          22,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.isSignUp ? 'Verify your phone' : 'Welcome back',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              'We sent a 6-digit verification code to ${widget.phone}.',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 35),

            // ==================================================
            // OTP BOXES
            // ==================================================

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                6,
                (i) {
                  return SizedBox(
                    width: 48,
                    height: 64,
                    child: TextField(
                      controller: codes[i],
                      focusNode: nodes[i],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      maxLength: 1,
                      style: const TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w900,
                      ),
                      onChanged: (value) {
                        _onCodeChanged(value, i);
                      },
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: const Color(0xFF111313),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(
                            color: Colors.white10,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(
                            color: Color(0xFFF3F0D6),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 25),

            // ==================================================
            // RESEND
            // ==================================================

            Row(
              children: [
                const Text(
                  'Didn’t receive it?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(width: 5),
                TextButton(
                  onPressed: seconds == 0 ? resend : null,
                  child: Text(
                    seconds == 0 ? 'Resend OTP' : 'Resend in ${seconds}s',
                    style: TextStyle(
                      color: seconds == 0
                          ? const Color(0xFFF3F0D6)
                          : Colors.white24,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),

            const Spacer(),

            const Text(
              'SECURE VERIFICATION',
              style: TextStyle(
                color: Colors.white24,
                fontSize: 8,
                letterSpacing: 2.5,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'The verification code is sent by Firebase to your phone.',
              style: TextStyle(
                color: Colors.white30,
                fontSize: 9,
              ),
            ),

            const SizedBox(height: 15),

            // ==================================================
            // VERIFY BUTTON
            // ==================================================

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: loading ? null : verify,
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
                        'Verify & Continue',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
