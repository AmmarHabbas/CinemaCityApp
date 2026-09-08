import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendOtp({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
    required void Function(String message) onError,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            final result = await _auth.signInWithCredential(credential);

            final user = result.user;

            if (user != null) {
              await createUserIfNeeded(user);
            }
          } on FirebaseAuthException catch (e) {
            onError(e.message ?? 'Authentication failed.');
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          onError(
            e.message ?? 'Phone verification failed.',
          );
        },
        codeSent: (
          String verificationId,
          int? resendToken,
        ) {
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } on FirebaseAuthException catch (e) {
      onError(
        e.message ?? 'Unable to send verification code.',
      );
    } catch (e) {
      onError(
        'Something went wrong. Please try again.',
      );
    }
  }

  Future<User?> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    final result = await _auth.signInWithCredential(
      credential,
    );

    final user = result.user;

    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'Unable to sign in.',
      );
    }

    await createUserIfNeeded(user);

    return user;
  }

  Future<void> createUserIfNeeded(User user) async {
    final userRef = _firestore.collection('users').doc(user.uid);

    final snapshot = await userRef.get();

    if (!snapshot.exists) {
      await userRef.set({
        'uid': user.uid,
        'phoneNumber': user.phoneNumber,
        'displayName': user.displayName ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } else {
      await userRef.update({
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  User? get currentUser => _auth.currentUser;

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
