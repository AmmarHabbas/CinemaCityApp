import 'package:cloud_firestore/cloud_firestore.dart';

class HallSeat {
  final String id;
  final String row;
  final int number;

  HallSeat({
    required this.id,
    required this.row,
    required this.number,
  });

  factory HallSeat.fromMap(Map<String, dynamic> map) {
    return HallSeat(
      id: map['id'] ?? '',
      row: map['row'] ?? '',
      number: (map['number'] as num?)?.toInt() ?? 0,
    );
  }
}

class Hall {
  final String id;
  final String name;
  final int rows;
  final int seatsPerRow;
  final List<HallSeat> seats;

  Hall({
    required this.id,
    required this.name,
    required this.rows,
    required this.seatsPerRow,
    required this.seats,
  });

  factory Hall.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    final seatsData = data['seats'] as List<dynamic>? ?? [];

    return Hall(
      id: doc.id,
      name: data['name'] ?? '',
      rows: (data['rows'] as num?)?.toInt() ?? 0,
      seatsPerRow: (data['seatsPerRow'] as num?)?.toInt() ?? 0,
      seats: seatsData.map((seat) {
        return HallSeat.fromMap(
          Map<String, dynamic>.from(seat as Map),
        );
      }).toList(),
    );
  }
}
