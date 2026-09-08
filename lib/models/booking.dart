import 'package:cloud_firestore/cloud_firestore.dart';

class Booking {
  final String id;

  final String bookingCode;

  final String userId;

  final String customerName;
  final String customerPhone;

  final String movieId;
  final String movieTitle;

  final String hallId;
  final String hallName;

  final String showtimeId;

  final DateTime date;
  final String startTime;

  final List<String> seats;

  final int seatCount;

  final double pricePerSeat;
  final double total;

  final String status;

  final DateTime? createdAt;

  Booking({
    required this.id,
    required this.bookingCode,
    required this.userId,
    required this.customerName,
    required this.customerPhone,
    required this.movieId,
    required this.movieTitle,
    required this.hallId,
    required this.hallName,
    required this.showtimeId,
    required this.date,
    required this.startTime,
    required this.seats,
    required this.seatCount,
    required this.pricePerSeat,
    required this.total,
    required this.status,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'bookingCode': bookingCode,
      'userId': userId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'movieId': movieId,
      'movieTitle': movieTitle,
      'hallId': hallId,
      'hallName': hallName,
      'showtimeId': showtimeId,
      'date': Timestamp.fromDate(date),
      'startTime': startTime,
      'seats': seats,
      'seatCount': seatCount,
      'pricePerSeat': pricePerSeat,
      'total': total,
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory Booking.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    final dateValue = data['date'];

    DateTime date = DateTime.now();

    if (dateValue is Timestamp) {
      date = dateValue.toDate();
    }

    return Booking(
      id: doc.id,
      bookingCode: data['bookingCode'] ?? '',
      userId: data['userId'] ?? '',
      customerName: data['customerName'] ?? '',
      customerPhone: data['customerPhone'] ?? '',
      movieId: data['movieId'] ?? '',
      movieTitle: data['movieTitle'] ?? '',
      hallId: data['hallId'] ?? '',
      hallName: data['hallName'] ?? '',
      showtimeId: data['showtimeId'] ?? '',
      date: date,
      startTime: data['startTime'] ?? '',
      seats: List<String>.from(data['seats'] ?? []),
      seatCount: (data['seatCount'] as num?)?.toInt() ?? 0,
      pricePerSeat: (data['pricePerSeat'] as num?)?.toDouble() ?? 0,
      total: (data['total'] as num?)?.toDouble() ?? 0,
      status: data['status'] ?? 'confirmed',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
