import 'package:cloud_firestore/cloud_firestore.dart';

class SeatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============================================================
  // REAL-TIME BOOKED SEATS
  // ============================================================

  Stream<Set<String>> watchBookedSeats(
    String showtimeId,
  ) {
    return _firestore
        .collection('showtimes')
        .doc(showtimeId)
        .collection('seatLocks')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => doc.id).toSet();
    });
  }
}
