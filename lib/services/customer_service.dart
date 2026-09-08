import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CustomerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Map<String, String>> getCurrentCustomer() async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User is not signed in.');
    }

    final doc = await _firestore.collection('users').doc(user.uid).get();

    final data = doc.data() ?? {};

    return {
      'name': data['name'] ?? 'Customer',
      'phone': data['phoneNumber'] ?? user.phoneNumber ?? '',
    };
  }
}
