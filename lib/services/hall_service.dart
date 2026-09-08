import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/hall.dart';

class HallService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Hall?> getHall(String hallId) async {
    final doc = await _firestore.collection('halls').doc(hallId).get();

    if (!doc.exists) {
      return null;
    }

    return Hall.fromFirestore(doc);
  }
}
