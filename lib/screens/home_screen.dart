import 'dart:async';

import 'package:flutter/material.dart';

import '../models/movie.dart';
import '../services/movie_service.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/movie_poster.dart';

import 'movie_details_screen.dart';
import 'coming_soon_screen.dart';
import 'tomorrow_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ============================================================
  // PAGE CONTROLLER
  // ============================================================

  late final PageController _pageController;

  // ============================================================
  // FIREBASE SERVICE
  // ============================================================

  final MovieService _movieService = MovieService();

  // ============================================================
  // MOVIES
  // ============================================================

  List<Movie> _movies = [];

  // ============================================================
  // AUTO PLAY
  // ============================================================

  Timer? _timer;

  bool _isAnimating = false;

  // ============================================================
  // NAVIGATION
  // ============================================================

  int _navIndex = 0;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    // ----------------------------------------------------------
    // IMPORTANT
    //
    // The PageController is initialized here.
    //
    // There is NO separate current movie index.
    // The PageController itself is the source of truth.
    // ----------------------------------------------------------

    _pageController = PageController(
      viewportFraction: 0.76,
      initialPage: 0,
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();

    super.dispose();
  }

  // ============================================================
  // MONTH NAME
  // ============================================================

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

  // ============================================================
  // GET CURRENT MOVIE INDEX
  //
  // THIS IS THE IMPORTANT PART.
  //
  // The movie title, glow and centered poster all use the
  // exact same page position.
  // ============================================================

  int _getCurrentMovieIndex(int movieCount) {
    if (movieCount <= 0) {
      return 0;
    }

    // PageController might not be attached during the first build.
    if (!_pageController.hasClients) {
      return 0;
    }

    final page = _pageController.page;

    if (page == null) {
      return 0;
    }

    // round() gives us the movie whose poster is closest
    // to the center of the screen.
    final roundedPage = page.round();

    return roundedPage % movieCount;
  }

  // ============================================================
  // START AUTO PLAY
  // ============================================================

  void _startAutoPlay() {
    _timer?.cancel();

    if (_movies.length <= 1) {
      return;
    }

    _timer = Timer.periodic(
      const Duration(seconds: 3),
      (_) {
        _moveToNextMovie();
      },
    );
  }

  // ============================================================
  // STOP AUTO PLAY
  // ============================================================

  void _stopAutoPlay() {
    _timer?.cancel();
    _timer = null;
  }

  // ============================================================
  // MOVE TO NEXT MOVIE
  //
  // IMPORTANT:
  //
  // We DO NOT calculate the next index ourselves.
  //
  // PageController knows exactly which page is currently
  // visible, so nextPage() is used directly.
  // ============================================================

  Future<void> _moveToNextMovie() async {
    if (!mounted) {
      return;
    }

    if (_movies.length <= 1) {
      return;
    }

    if (!_pageController.hasClients) {
      return;
    }

    if (_isAnimating) {
      return;
    }

    // Don't interrupt a manual swipe.
    if (_pageController.position.isScrollingNotifier.value) {
      return;
    }

    _isAnimating = true;

    try {
      await _pageController.nextPage(
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOut,
      );
    } catch (_) {
      // Ignore animation interruptions.
    } finally {
      _isAnimating = false;
    }
  }

  // ============================================================
  // UPDATE MOVIES
  // ============================================================

  void _updateMovies(List<Movie> movies) {
    if (!mounted) {
      return;
    }

    // ----------------------------------------------------------
    // NO MOVIES
    // ----------------------------------------------------------

    if (movies.isEmpty) {
      _stopAutoPlay();

      _movies = [];

      return;
    }

    // ----------------------------------------------------------
    // CHECK WHETHER MOVIES CHANGED
    // ----------------------------------------------------------

    bool changed = false;

    if (_movies.length != movies.length) {
      changed = true;
    } else {
      for (int i = 0; i < movies.length; i++) {
        if (_movies[i].id != movies[i].id) {
          changed = true;
          break;
        }
      }
    }

    // ----------------------------------------------------------
    // NOTHING CHANGED
    // ----------------------------------------------------------

    if (!changed) {
      return;
    }

    // ----------------------------------------------------------
    // UPDATE LOCAL LIST
    // ----------------------------------------------------------

    _movies = List<Movie>.from(movies);

    // ----------------------------------------------------------
    // START AUTOPLAY AFTER PAGEVIEW EXISTS
    // ----------------------------------------------------------

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      if (_pageController.hasClients) {
        _startAutoPlay();
      }
    });
  }

  // ============================================================
  // NAVIGATION
  // ============================================================

  void _nav(int i) {
    _stopAutoPlay();

    switch (i) {
      case 0:
        if (_navIndex != 0) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const HomeScreen(),
            ),
          );
        }
        break;

      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ComingSoonScreen(
              onNavChanged: _nav,
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
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050606),

      // ==========================================================
      // BOTTOM NAVIGATION
      // ==========================================================

      bottomNavigationBar: SafeArea(
        top: false,
        child: CinemaBottomNav(
          currentIndex: 0,
          onChanged: _nav,
        ),
      ),

      // ==========================================================
      // BODY
      // ==========================================================

      body: SafeArea(
        child: StreamBuilder<List<Movie>>(
          stream: _movieService.getNowPlaying(),
          builder: (context, snapshot) {
            // ====================================================
            // LOADING
            // ====================================================

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFF3F0D6),
                ),
              );
            }

            // ====================================================
            // ERROR
            // ====================================================

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Failed to load movies.\n\n${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ),
              );
            }

            // ====================================================
            // MOVIES
            // ====================================================

            final movies = snapshot.data ?? [];

            _updateMovies(movies);

            // ====================================================
            // NO MOVIES
            // ====================================================

            if (movies.isEmpty) {
              return Column(
                children: [
                  _topBar(),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'No movies are currently playing.',
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            // ====================================================
            // MAIN CONTENT
            //
            // AnimatedBuilder listens directly to the
            // PageController.
            //
            // This means:
            //
            // POSTER
            // TITLE
            // GLOW
            //
            // all use the same page position.
            // ============================================================

            return AnimatedBuilder(
              animation: _pageController,
              builder: (context, _) {
                final currentIndex = _getCurrentMovieIndex(movies.length);

                final currentMovie = movies[currentIndex];

                return Stack(
                  children: [
                    // ==================================================
                    // BACKGROUND GLOW
                    // ==================================================

                    Positioned.fill(
                      child: AnimatedContainer(
                        duration: const Duration(
                          milliseconds: 800,
                        ),
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: const Alignment(
                              0,
                              -.7,
                            ),
                            radius: 1.0,
                            colors: [
                              _glowColor(
                                currentIndex,
                              ).withOpacity(.34),
                              const Color(0xFF050606),
                              const Color(0xFF050606),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // ==================================================
                    // CONTENT
                    // ==================================================

                    Column(
                      children: [
                        // =================================================
                        // TOP BAR
                        // =================================================

                        _topBar(),

                        const SizedBox(height: 22),

                        // =================================================
                        // DATE
                        // =================================================

                        Text(
                          '${DateTime.now().day} '
                          '${getMonthName(
                            DateTime.now().month,
                          )}',
                          style: const TextStyle(
                            fontSize: 42,
                            letterSpacing: -2,
                            fontWeight: FontWeight.w900,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // =================================================
                        // MOVIE CAROUSEL
                        // =================================================

                        Expanded(
                          child: PageView.builder(
                            controller: _pageController,

                            // =================================================
                            // IMPORTANT
                            //
                            // This creates the same infinite-style
                            // carousel you wanted.
                            //
                            // It works with 2, 5, 10, 20+ movies.
                            // =================================================

                            itemCount: 100000,

                            physics: const BouncingScrollPhysics(),

                            // =================================================
                            // NO onPageChanged
                            //
                            // We intentionally don't use it.
                            //
                            // PageController is the single source of truth.
                            // =================================================

                            itemBuilder: (
                              context,
                              page,
                            ) {
                              final movieIndex = page % movies.length;

                              final movie = movies[movieIndex];

                              // =================================================
                              // POSTER SCALE ANIMATION
                              // =================================================

                              return AnimatedBuilder(
                                animation: _pageController,
                                builder: (
                                  context,
                                  child,
                                ) {
                                  double scale = 1.0;

                                  if (_pageController.hasClients &&
                                      _pageController
                                          .position.hasContentDimensions) {
                                    final currentPage =
                                        _pageController.page ?? page.toDouble();

                                    final distance = (currentPage - page).abs();

                                    scale = (1.0 - distance * 0.10).clamp(
                                      0.88,
                                      1.0,
                                    );
                                  }

                                  return Transform.scale(
                                    scale: scale,
                                    child: child,
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    8,
                                    0,
                                    8,
                                    22,
                                  ),
                                  child: GestureDetector(
                                    onTap: () {
                                      _stopAutoPlay();

                                      Navigator.push(
                                        context,
                                        PageRouteBuilder(
                                          transitionDuration: const Duration(
                                            milliseconds: 450,
                                          ),
                                          pageBuilder: (
                                            context,
                                            animation,
                                            secondaryAnimation,
                                          ) {
                                            return MovieDetailsScreen(
                                              movie: movie,
                                            );
                                          },
                                          transitionsBuilder: (
                                            context,
                                            animation,
                                            secondaryAnimation,
                                            child,
                                          ) {
                                            return FadeTransition(
                                              opacity: animation,
                                              child: child,
                                            );
                                          },
                                        ),
                                      ).then((_) {
                                        if (!mounted) {
                                          return;
                                        }

                                        _startAutoPlay();
                                      });
                                    },
                                    child: MoviePoster(
                                      asset: movie.posterUrl,
                                      duration: movie.duration,
                                      genre: movie.genre,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        // =================================================
                        // MOVIE TITLE
                        //
                        // THIS IS NOW DIRECTLY CONTROLLED BY THE
                        // PAGE CONTROLLER.
                        //
                        // It cannot become independent from the poster.
                        // =================================================

                        AnimatedSwitcher(
                          duration: const Duration(
                            milliseconds: 250,
                          ),
                          switchInCurve: Curves.easeOut,
                          switchOutCurve: Curves.easeIn,
                          transitionBuilder: (
                            child,
                            animation,
                          ) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                          child: Text(
                            currentMovie.title,
                            key: ValueKey(
                              currentMovie.id,
                            ),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  // ==============================================================
  // TOP BAR
  // ==============================================================

  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 17,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _nav(1),
            child: const Text(
              'Coming Soon',
              style: TextStyle(
                color: Colors.white60,
                fontSize: 11,
              ),
            ),
          ),
          const Spacer(),
          const Text(
            'Now Playing',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              _stopAutoPlay();

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TomorrowScreen(
                    onNavChanged: _nav,
                  ),
                ),
              ).then((_) {
                if (!mounted) {
                  return;
                }

                _startAutoPlay();
              });
            },
            child: const Row(
              children: [
                Text(
                  'Tomorrow',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white60,
                  ),
                ),
                SizedBox(width: 4),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 15,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // BACKGROUND GLOW
  // ==============================================================

  Color _glowColor(int i) {
    const colors = [
      Color(0xFF2B9BD3),
      Color(0xFF8B9787),
      Color(0xFF1B1B1B),
      Color(0xFF5E82D6),
      Color(0xFFE19A36),
    ];

    return colors[i % colors.length];
  }
}
