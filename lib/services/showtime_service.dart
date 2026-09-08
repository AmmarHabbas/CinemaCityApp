import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/showtime.dart';

class ShowtimeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============================================================
  // GET ALL SHOWTIMES FOR A MOVIE
  // ============================================================

  Stream<List<Showtime>> getShowtimesForMovie(String movieId) {
    return _firestore
        .collection('showtimes')
        .where('movieId', isEqualTo: movieId)
        .orderBy('date')
        .snapshots()
        .map((snapshot) {
      final showtimes =
          snapshot.docs.map((doc) => Showtime.fromFirestore(doc)).toList();

      // Sort by date first, then start time.
      showtimes.sort((a, b) {
        final dateCompare = a.date.compareTo(b.date);

        if (dateCompare != 0) {
          return dateCompare;
        }

        return _compareTime(a.startTime, b.startTime);
      });

      return showtimes;
    });
  }

  // ============================================================
  // GET SHOWTIMES FOR A MOVIE ON A SPECIFIC DATE
  // ============================================================

  Stream<List<Showtime>> getShowtimesForMovieOnDate(
    String movieId,
    DateTime date,
  ) {
    final start = DateTime(
      date.year,
      date.month,
      date.day,
    );

    final end = start.add(const Duration(days: 1));

    return _firestore
        .collection('showtimes')
        .where('movieId', isEqualTo: movieId)
        .where(
          'date',
          isGreaterThanOrEqualTo: Timestamp.fromDate(start),
        )
        .where(
          'date',
          isLessThan: Timestamp.fromDate(end),
        )
        .orderBy('date')
        .snapshots()
        .map((snapshot) {
      final showtimes =
          snapshot.docs.map((doc) => Showtime.fromFirestore(doc)).toList();

      // Firestore filters by movie + date.
      // We sort the actual showtimes by startTime here.
      showtimes.sort((a, b) {
        return _compareTime(a.startTime, b.startTime);
      });

      return showtimes;
    });
  }

  // ============================================================
  // GET ONE SHOWTIME
  // ============================================================

  Future<Showtime?> getShowtime(String showtimeId) async {
    final doc = await _firestore.collection('showtimes').doc(showtimeId).get();

    if (!doc.exists) {
      return null;
    }

    return Showtime.fromFirestore(doc);
  }

  // ============================================================
  // COMPARE HH:mm TIMES
  // ============================================================

  int _compareTime(String first, String second) {
    final firstParts = first.split(':');
    final secondParts = second.split(':');

    if (firstParts.length != 2 || secondParts.length != 2) {
      return first.compareTo(second);
    }

    final firstHour = int.tryParse(firstParts[0]) ?? 0;
    final firstMinute = int.tryParse(firstParts[1]) ?? 0;

    final secondHour = int.tryParse(secondParts[0]) ?? 0;
    final secondMinute = int.tryParse(secondParts[1]) ?? 0;

    final firstTotalMinutes = firstHour * 60 + firstMinute;
    final secondTotalMinutes = secondHour * 60 + secondMinute;

    return firstTotalMinutes.compareTo(secondTotalMinutes);
  }
}
