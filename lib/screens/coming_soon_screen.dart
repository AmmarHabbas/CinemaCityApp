import 'package:cinema_ui_reference/screens/home_screen.dart';
import 'package:cinema_ui_reference/screens/notifications_screen.dart';
import 'package:cinema_ui_reference/screens/profile_screen.dart';
import 'package:flutter/material.dart';

import '../models/movie.dart';
import '../services/movie_service.dart';
import '../widgets/bottom_nav.dart';

import 'movie_details_screen.dart';

class ComingSoonScreen extends StatelessWidget {
  final ValueChanged<int> onNavChanged;

  const ComingSoonScreen({
    super.key,
    required this.onNavChanged,
  });

  String _getMonthName(int month) {
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
                children: [
                  const Text(
                    'Coming Soon',
                    style: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 13,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111313),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white10,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.movie_outlined,
                          size: 15,
                          color: Color(0xFFF3F0D6),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Upcoming',
                          style: TextStyle(
                            color: Colors.white.withOpacity(.75),
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
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
                stream: MovieService().getComingSoon(),
                builder: (context, snapshot) {
                  // ------------------------------------------------
                  // LOADING
                  // ------------------------------------------------

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFF3F0D6),
                        strokeWidth: 2,
                      ),
                    );
                  }

                  // ------------------------------------------------
                  // ERROR
                  // ------------------------------------------------

                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: const Color(0xFF111313),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white10,
                                ),
                              ),
                              child: const Icon(
                                Icons.error_outline_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Unable to load movies',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${snapshot.error}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // ------------------------------------------------
                  // MOVIES
                  // ------------------------------------------------

                  final movies = snapshot.data ?? [];

                  // ------------------------------------------------
                  // EMPTY
                  // ------------------------------------------------

                  if (movies.isEmpty) {
                    return _emptyState();
                  }

                  // ------------------------------------------------
                  // LIST
                  // ------------------------------------------------

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
            // BOTTOM NAVIGATION
            // ====================================================

            CinemaBottomNav(
              currentIndex: 1,
              onChanged: (index) {
                _navigate(context, index);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _navigate(BuildContext context, int index) {
    if (index == 1) {
      return;
    }

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomeScreen(
                // Use your existing HomeScreen constructor here.
                ),
          ),
        );
        break;

      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const NotificationsScreen(),
          ),
        );
        break;

      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const ProfileScreen(),
          ),
        );
        break;
    }
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
        height: 235,
        margin: const EdgeInsets.only(
          bottom: 16,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF111313),
          borderRadius: BorderRadius.circular(26),
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
            // ====================================================
            // FULL POSTER
            // ====================================================

            Image.network(
              movie.posterUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return Container(
                  color: const Color(0xFF181B1A),
                  child: const Center(
                    child: Icon(
                      Icons.movie_outlined,
                      color: Colors.white30,
                      size: 50,
                    ),
                  ),
                );
              },
            ),

            // ====================================================
            // DARK GRADIENT
            // ====================================================

            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(.05),
                    Colors.transparent,
                    Colors.black.withOpacity(.92),
                  ],
                  stops: const [
                    0.0,
                    0.40,
                    1.0,
                  ],
                ),
              ),
            ),

            // ====================================================
            // LEFT GRADIENT
            // ====================================================

            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.black.withOpacity(.60),
                    Colors.transparent,
                  ],
                ),
              ),
            ),

            // ====================================================
            // COMING SOON BADGE
            // ====================================================

            Positioned(
              left: 15,
              top: 15,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F0D6),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Text(
                  'COMING SOON',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .8,
                  ),
                ),
              ),
            ),

            // ====================================================
            // TITLE
            // ====================================================

            Positioned(
              left: 18,
              right: 18,
              bottom: 61,
              child: Text(
                movie.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                  height: 1.05,
                ),
              ),
            ),

            // ====================================================
            // RELEASE DATE
            // ====================================================

            if (movie.releaseDate != null)
              Positioned(
                left: 18,
                bottom: 19,
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 13,
                      color: Color(0xFFF3F0D6),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Releases ${movie.releaseDate!.day} '
                      '${_getMonthName(movie.releaseDate!.month)} '
                      '${movie.releaseDate!.year}',
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

            // ====================================================
            // VIEW BUTTON
            // ====================================================

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
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: const Color(0xFF111313),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white10,
                ),
              ),
              child: const Icon(
                Icons.movie_filter_outlined,
                color: Colors.white30,
                size: 30,
              ),
            ),
            const SizedBox(height: 17),
            const Text(
              'No upcoming movies',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              'New movies will appear here when they are announced.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
