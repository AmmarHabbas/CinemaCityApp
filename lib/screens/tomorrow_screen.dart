import 'package:flutter/material.dart';

import '../models/movie.dart';
import '../services/movie_service.dart';
import '../widgets/bottom_nav.dart';

import 'movie_details_screen.dart';

class TomorrowScreen extends StatelessWidget {
  final ValueChanged<int> onNavChanged;

  const TomorrowScreen({
    super.key,
    required this.onNavChanged,
  });

  String getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final tomorrow = DateTime.now().add(
      const Duration(days: 1),
    );

    return Scaffold(
      backgroundColor: const Color(0xFF050606),
      body: SafeArea(
        child: Column(
          children: [
            // ====================================================
            // HEADER
            // ====================================================

            Padding(
              padding: const EdgeInsets.fromLTRB(
                20,
                17,
                20,
                12,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Tomorrow',
                    style: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111313),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white10,
                      ),
                    ),
                    child: Text(
                      '${tomorrow.day} ${getMonthName(tomorrow.month)}',
                      style: const TextStyle(
                        color: Color(0xFFF3F0D6),
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ====================================================
            // MOVIES
            // ====================================================

            Expanded(
              child: StreamBuilder<List<Movie>>(
                stream: MovieService().getTomorrow(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFF3F0D6),
                        strokeWidth: 2,
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'Failed to load movies.\n\n${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 12,
                            height: 1.5,
                          ),
                        ),
                      ),
                    );
                  }

                  final movies = snapshot.data ?? [];

                  if (movies.isEmpty) {
                    return _emptyState();
                  }

                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      14,
                      4,
                      14,
                      24,
                    ),
                    itemCount: movies.length,
                    itemBuilder: (context, index) {
                      return _movieCard(
                        context,
                        movies[index],
                      );
                    },
                  );
                },
              ),
            ),

            // ====================================================
            // BOTTOM NAV
            // ====================================================

            CinemaBottomNav(
              currentIndex: 0,
              onChanged: onNavChanged,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // MOVIE CARD
  // ============================================================

  Widget _movieCard(
    BuildContext context,
    Movie movie,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MovieDetailsScreen(
              movie: movie,
            ),
          ),
        );
      },
      child: Container(
        height: 215,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF111313),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: Colors.white10,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.35),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ----------------------------------------------------
            // POSTER
            // ----------------------------------------------------

            Image.network(
              movie.posterUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return Container(
                  color: const Color(0xFF181B1A),
                  child: const Center(
                    child: Icon(
                      Icons.movie_outlined,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                );
              },
            ),

            // ----------------------------------------------------
            // DARK GRADIENT
            // ----------------------------------------------------

            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(.12),
                    Colors.transparent,
                    Colors.black.withOpacity(.88),
                  ],
                  stops: const [
                    0.0,
                    0.45,
                    1.0,
                  ],
                ),
              ),
            ),

            // Left-side subtle dark overlay
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.black.withOpacity(.55),
                    Colors.transparent,
                  ],
                ),
              ),
            ),

            // ----------------------------------------------------
            // TITLE
            // ----------------------------------------------------

            Positioned(
              left: 18,
              top: 17,
              right: 18,
              child: Text(
                movie.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  height: 1.05,
                ),
              ),
            ),

            // ----------------------------------------------------
            // MOVIE INFORMATION
            // ----------------------------------------------------

            Positioned(
              left: 18,
              right: 105,
              bottom: 18,
              child: Row(
                children: [
                  const Icon(
                    Icons.access_time_rounded,
                    size: 14,
                    color: Color(0xFFF3F0D6),
                  ),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      movie.duration,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 13),
                  const Icon(
                    Icons.star_rounded,
                    size: 14,
                    color: Color(0xFFF3F0D6),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    movie.rating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            // ----------------------------------------------------
            // VIEW BUTTON
            // ----------------------------------------------------

            Positioned(
              right: 14,
              bottom: 13,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F0D6),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.25),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.black,
                      size: 13,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFF111313),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white10,
                ),
              ),
              child: const Icon(
                Icons.movie_outlined,
                color: Colors.white30,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No movies tomorrow',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'There are no movies scheduled for tomorrow yet.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
