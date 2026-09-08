import 'package:cloud_firestore/cloud_firestore.dart';

class Showtime {
  final String id;

  final String movieId;
  final String movieTitle;

  final String hallId;
  final String hallName;

  final DateTime date;
  final String startTime;

  final double price;

  final DateTime? createdAt;

  Showtime({
    required this.id,
    required this.movieId,
    required this.movieTitle,
    required this.hallId,
    required this.hallName,
    required this.date,
    required this.startTime,
    required this.price,
    this.createdAt,
  });

  factory Showtime.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    final dateValue = data['date'];

    DateTime date = DateTime.now();

    if (dateValue is Timestamp) {
      date = dateValue.toDate();
    }

    return Showtime(
      id: doc.id,
      movieId: data['movieId'] ?? '',
      movieTitle: data['movieTitle'] ?? '',
      hallId: data['hallId'] ?? '',
      hallName: data['hallName'] ?? '',
      date: date,
      startTime: data['startTime'] ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
