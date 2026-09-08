import 'package:cloud_firestore/cloud_firestore.dart';

class Movie {
  final String id;
  final String title;
  final String posterUrl;
  final String trailerUrl;
  final String genre;
  final String duration;
  final double rating;
  final String description;
  final String status;
  final DateTime? releaseDate;

  // Movie cast
  final List<MovieCast> cast;

  Movie({
    required this.id,
    required this.title,
    required this.posterUrl,
    required this.trailerUrl,
    required this.genre,
    required this.duration,
    required this.rating,
    required this.description,
    required this.status,
    this.releaseDate,
    required this.cast,
  });

  // ============================================================
  // FIRESTORE
  // ============================================================

  factory Movie.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    // ============================================================
    // CAST
    // ============================================================

    final List<MovieCast> castList = [];

    final rawCast = data['cast'];

    if (rawCast is List) {
      for (final item in rawCast) {
        if (item is Map) {
          castList.add(
            MovieCast(
              name: item['name']?.toString() ?? '',
              role: item['role']?.toString() ?? '',
              photoUrl: item['photoUrl']?.toString() ?? '',
            ),
          );
        }
      }
    }

    // ============================================================
    // RELEASE DATE
    // ============================================================

    DateTime? releaseDate;

    final rawReleaseDate = data['releaseDate'];

    if (rawReleaseDate is Timestamp) {
      releaseDate = rawReleaseDate.toDate();
    }

    // ============================================================
    // RATING
    // ============================================================

    double rating = 0;

    final rawRating = data['rating'];

    if (rawRating is num) {
      rating = rawRating.toDouble();
    }

    // ============================================================
    // MOVIE
    // ============================================================

    return Movie(
      id: doc.id,
      title: data['title']?.toString() ?? '',
      posterUrl: data['posterUrl']?.toString() ?? '',
      trailerUrl: data['trailerUrl']?.toString() ?? '',
      genre: data['genre']?.toString() ?? '',
      duration: data['duration']?.toString() ?? '',
      rating: rating,
      description: data['description']?.toString() ?? '',
      status: data['status']?.toString() ?? '',
      releaseDate: releaseDate,
      cast: castList,
    );
  }
}

// ================================================================
// MOVIE CAST MODEL
// ================================================================

class MovieCast {
  final String name;
  final String role;
  final String photoUrl;

  MovieCast({
    required this.name,
    required this.role,
    required this.photoUrl,
  });
}
