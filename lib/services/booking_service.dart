import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/booking.dart';
import '../models/showtime.dart';

class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ============================================================
  // GENERATE BOOKING CODE
  // ============================================================

  String _generateBookingCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

    final random = Random();

    return List.generate(
      8,
      (_) => chars[random.nextInt(chars.length)],
    ).join();
  }

  // ============================================================
  // CREATE BOOKING
  // ============================================================

  Future<Booking> createBooking({
    required Showtime showtime,
    required List<String> seats,
    required String customerName,
    required String customerPhone,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('You must be signed in to book.');
    }

    if (seats.isEmpty) {
      throw Exception('Please select at least one seat.');
    }

    final uniqueSeats = seats.toSet().toList();

    final bookingRef = _firestore.collection('bookings').doc();

    final bookingCode = _generateBookingCode();

    final total = uniqueSeats.length * showtime.price;

    final booking = Booking(
      id: bookingRef.id,
      bookingCode: bookingCode,
      userId: user.uid,
      customerName: customerName,
      customerPhone: customerPhone,
      movieId: showtime.movieId,
      movieTitle: showtime.movieTitle,
      hallId: showtime.hallId,
      hallName: showtime.hallName,
      showtimeId: showtime.id,
      date: showtime.date,
      startTime: showtime.startTime,
      seats: uniqueSeats,
      seatCount: uniqueSeats.length,
      pricePerSeat: showtime.price,
      total: total,
      status: 'confirmed',
    );

    await _firestore.runTransaction((transaction) async {
      // ----------------------------------------------------------
      // First verify that every seat is still available.
      // ----------------------------------------------------------

      final seatRefs = uniqueSeats.map((seatId) {
        return _firestore
            .collection('showtimes')
            .doc(showtime.id)
            .collection('seatLocks')
            .doc(seatId);
      }).toList();

      final seatSnapshots = <DocumentSnapshot>[];

      for (final ref in seatRefs) {
        final snapshot = await transaction.get(ref);

        seatSnapshots.add(snapshot);
      }

      // ----------------------------------------------------------
      // DOUBLE BOOKING PROTECTION
      // ----------------------------------------------------------

      for (int i = 0; i < seatSnapshots.length; i++) {
        if (seatSnapshots[i].exists) {
          throw Exception(
            'Seat ${uniqueSeats[i]} was just booked by another customer.',
          );
        }
      }

      // ----------------------------------------------------------
      // CREATE BOOKING
      // ----------------------------------------------------------

      transaction.set(
        bookingRef,
        booking.toMap(),
      );

      // ----------------------------------------------------------
      // LOCK EVERY SEAT
      // ----------------------------------------------------------

      for (int i = 0; i < uniqueSeats.length; i++) {
        transaction.set(
          seatRefs[i],
          {
            'seatId': uniqueSeats[i],
            'userId': user.uid,
            'bookingId': bookingRef.id,
            'createdAt': FieldValue.serverTimestamp(),
          },
        );
      }
    });

    return booking;
  }

  // ============================================================
  // CUSTOMER BOOKINGS
  // ============================================================

  Stream<List<Booking>> getMyBookings() {
    final user = _auth.currentUser;

    if (user == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('bookings')
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Booking.fromFirestore(doc)).toList();
    });
  }

  // ============================================================
  // SINGLE BOOKING
  // ============================================================

  Future<Booking?> getBooking(String bookingId) async {
    final doc = await _firestore.collection('bookings').doc(bookingId).get();

    if (!doc.exists) {
      return null;
    }

    return Booking.fromFirestore(doc);
  }
}
