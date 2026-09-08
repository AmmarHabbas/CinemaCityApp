import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/movie.dart';

class MovieService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============================================================
  // NOW PLAYING
  // ============================================================

  Stream<List<Movie>> getNowPlaying() {
    return _firestore
        .collection('movies')
        .where('status', isEqualTo: 'nowPlaying')
        .orderBy('releaseDate')
        .orderBy(FieldPath.documentId) // tiebreaker — stable across reads
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Movie.fromFirestore(doc)).toList());
  }

  // ============================================================
  // COMING SOON
  // ============================================================

  Stream<List<Movie>> getComingSoon() {
    return _firestore
        .collection('movies')
        .where('status', isEqualTo: 'comingSoon')
        .orderBy('releaseDate')
        .orderBy(FieldPath.documentId) // tiebreaker — stable across reads
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Movie.fromFirestore(doc)).toList();
    });
  }

  // ============================================================
  // TOMORROW
  // ============================================================

  Stream<List<Movie>> getTomorrow() {
    return _firestore
        .collection('movies')
        .where('status', isEqualTo: 'tomorrow')
        .orderBy('releaseDate')
        .orderBy(FieldPath.documentId) // tiebreaker — stable across reads
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Movie.fromFirestore(doc)).toList();
    });
  }
}
