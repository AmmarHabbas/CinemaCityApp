import 'package:cinema_ui_reference/screens/showtimes_screen.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/movie.dart';
import '../models/showtime.dart';

import '../services/showtime_service.dart';
import '../services/hall_service.dart';

import '../widgets/glass_pill.dart';

class MovieDetailsScreen extends StatelessWidget {
  final Movie movie;

  const MovieDetailsScreen({
    super.key,
    required this.movie,
  });

  // ============================================================
  // SHOWTIME PICKER
  // ============================================================

  Future<void> _showtimePicker(
    BuildContext context,
  ) async {
    final showtimeService = ShowtimeService();
    final hallService = HallService();

    await showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111313),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (sheetContext) {
        return StreamBuilder<List<Showtime>>(
          stream: showtimeService.getShowtimesForMovie(
            movie.id,
          ),
          builder: (context, snapshot) {
            // ==================================================
            // LOADING
            // ==================================================

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 280,
                child: Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFF3F0D6),
                    strokeWidth: 2,
                  ),
                ),
              );
            }

            // ==================================================
            // ERROR
            // ==================================================

            if (snapshot.hasError) {
              return SafeArea(
                child: SizedBox(
                  height: 280,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.error_outline_rounded,
                            size: 42,
                            color: Colors.white38,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Failed to load showtimes.',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${snapshot.error}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }

            final showtimes = snapshot.data ?? [];

            // ==================================================
            // NO SHOWTIMES
            // ==================================================

            if (showtimes.isEmpty) {
              return SafeArea(
                child: SizedBox(
                  height: 280,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.event_busy_outlined,
                            size: 42,
                            color: Colors.white38,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'No showtimes available',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            'There are currently no showtimes '
                            'available for ${movie.title}.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.white,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }

            // ==================================================
            // SHOWTIMES
            // ==================================================

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  14,
                  20,
                  20,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bottom sheet handle
                    Center(
                      child: Container(
                        width: 38,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      'Choose Showtime',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -.5,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      movie.title,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white54,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: showtimes.length,
                        itemBuilder: (
                          context,
                          index,
                        ) {
                          final showtime = showtimes[index];

                          return _showtimeTile(
                            context: context,
                            sheetContext: sheetContext,
                            showtime: showtime,
                            hallService: hallService,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ============================================================
  // SHOWTIME TILE
  // ============================================================

  Widget _showtimeTile({
    required BuildContext context,
    required BuildContext sheetContext,
    required Showtime showtime,
    required HallService hallService,
  }) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 10,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1E1C),
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: Colors.white12,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 6,
        ),

        // ======================================================
        // TIME ICON
        // ======================================================

        leading: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xFFF3F0D6),
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Icon(
            Icons.access_time_rounded,
            color: Colors.black,
          ),
        ),

        // ======================================================
        // SHOWTIME
        // ======================================================

        title: Text(
          showtime.startTime,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),

        // ======================================================
        // DATE / HALL / PRICE
        // ======================================================

        subtitle: Padding(
          padding: const EdgeInsets.only(
            top: 5,
          ),
          child: Text(
            '${_formatDate(showtime.date)} • '
            '${showtime.hallName} • '
            '\$${showtime.price.toStringAsFixed(2)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 10,
            ),
          ),
        ),

        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: Colors.white54,
        ),

        // ======================================================
        // SELECT SHOWTIME
        // ======================================================

        onTap: () async {
          showDialog<void>(
            context: context,
            barrierDismissible: false,
            builder: (_) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFF3F0D6),
                  strokeWidth: 2,
                ),
              );
            },
          );

          try {
            final hall = await hallService.getHall(
              showtime.hallId,
            );

            if (!context.mounted) return;

            // Close loading dialog.
            Navigator.pop(context);

            // ==================================================
            // HALL NOT FOUND
            // ==================================================

            if (hall == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'The hall "${showtime.hallName}" '
                    'could not be found.',
                  ),
                ),
              );

              return;
            }

            // ==================================================
            // CLOSE SHOWTIME SHEET
            // ==================================================

            Navigator.pop(sheetContext);

            // ==================================================
            // OPEN SHOWTIMES
            // ==================================================

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ShowtimesScreen(
                  movie: movie,
                ),
              ),
            );
          } catch (e) {
            if (!context.mounted) return;

            Navigator.pop(context);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Failed to load hall: $e',
                ),
              ),
            );
          }
        },
      ),
    );
  }

  // ============================================================
  // DATE FORMAT
  // ============================================================

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  // ============================================================
  // OPEN TRAILER
  // ============================================================

  Future<void> _openTrailer(
    BuildContext context,
  ) async {
    final trailerUrl = movie.trailerUrl.trim();

    if (trailerUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Trailer is not available.',
          ),
        ),
      );

      return;
    }

    final uri = Uri.tryParse(trailerUrl);

    if (uri == null || !(uri.scheme == 'http' || uri.scheme == 'https')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Invalid trailer URL.',
          ),
        ),
      );

      return;
    }

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not open the trailer.',
            ),
          ),
        );
      }
    } catch (_) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not open the trailer.',
          ),
        ),
      );
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // ==================================================
            // BACKGROUND
            // ==================================================

            Positioned.fill(
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF89968D),
                      Color(0xFF1B1E1C),
                      Color(0xFF050606),
                    ],
                    stops: [
                      0,
                      .35,
                      .72,
                    ],
                  ),
                ),
              ),
            ),

            // ==================================================
            // CONTENT
            // ==================================================

            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                16,
                10,
                16,
                105,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ==================================================
                  // TOP BAR
                  // ==================================================

                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: GlassPill(
                          child: Row(
                            children: const [
                              Icon(
                                Icons.chevron_left_rounded,
                                size: 18,
                              ),
                              SizedBox(width: 3),
                              Text(
                                'Back',
                                style: TextStyle(
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      GlassPill(
                        child: Text(
                          movie.genre,
                          style: const TextStyle(
                            fontSize: 11,
                          ),
                        ),
                      ),
                      const SizedBox(width: 7),
                      GlassPill(
                        child: Text(
                          movie.duration,
                          style: const TextStyle(
                            fontSize: 11,
                          ),
                        ),
                      ),
                      const SizedBox(width: 7),
                      GlassPill(
                        child: Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 13,
                              color: Color(0xFFF2EBC6),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              movie.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // ==================================================
                  // POSTER
                  // ==================================================

                  ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: Stack(
                      children: [
                        AspectRatio(
                          aspectRatio: 0.75,
                          child: Image.network(
                            movie.posterUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (
                              context,
                              error,
                              stackTrace,
                            ) {
                              return Container(
                                color: const Color(0xFF171918),
                                child: const Icon(
                                  Icons.movie_outlined,
                                  size: 55,
                                  color: Colors.white30,
                                ),
                              );
                            },
                            loadingBuilder: (
                              context,
                              child,
                              loadingProgress,
                            ) {
                              if (loadingProgress == null) {
                                return child;
                              }

                              return const Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFFF3F0D6),
                                  strokeWidth: 2,
                                ),
                              );
                            },
                          ),
                        ),

                        // ==================================================
                        // TRAILER BUTTON
                        // ==================================================

                        Positioned(
                          right: 12,
                          bottom: 12,
                          child: GestureDetector(
                            onTap: () => _openTrailer(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 9,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F0D6),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: const Row(
                                children: [
                                  CircleAvatar(
                                    radius: 9,
                                    backgroundColor: Colors.black,
                                    child: Icon(
                                      Icons.play_arrow_rounded,
                                      size: 12,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'Watch Trailer',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ==================================================
                  // TITLE
                  // ==================================================

                  Text(
                    movie.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ==================================================
                  // DESCRIPTION
                  // ==================================================

                  Text(
                    movie.description,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.55,
                      color: Colors.white70,
                    ),
                  ),

                  const SizedBox(height: 5),

                  // ==================================================
                  // READ MORE
                  // ==================================================

                  GestureDetector(
                    onTap: () => showDialog<void>(
                      context: context,
                      builder: (_) {
                        return AlertDialog(
                          backgroundColor: const Color(0xFF171918),
                          title: Text(
                            movie.title,
                          ),
                          content: Text(
                            movie.description,
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                'Close',
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    child: const Text(
                      'Read More',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // ==================================================
                  // CAST
                  // ==================================================

                  const Text(
                    'Cast',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ==================================================
                  // DYNAMIC CAST
                  // ==================================================

                  if (movie.cast.isEmpty)
                    const SizedBox(
                      height: 100,
                      child: Center(
                        child: Text(
                          'No cast information available.',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    )
                  else
                    SizedBox(
                      height: 145,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: movie.cast.length,
                        itemBuilder: (
                          context,
                          index,
                        ) {
                          final castMember = movie.cast[index];

                          return _CastCard(
                            name: castMember.name,
                            role: castMember.role,
                            photoUrl: castMember.photoUrl,
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),

            // ==================================================
            // BOTTOM CHOOSE SHOWTIME BUTTON
            // ==================================================

            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(
                  18,
                  10,
                  18,
                  15,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Color(0xFF050606),
                    ],
                  ),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    _showtimePicker(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF3F0D6),
                    foregroundColor: Colors.black,
                    minimumSize: const Size.fromHeight(54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Choose Showtime',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// DYNAMIC CAST CARD
// ================================================================

class _CastCard extends StatelessWidget {
  final String name;
  final String role;
  final String photoUrl;

  const _CastCard({
    required this.name,
    required this.role,
    required this.photoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 92,
      margin: const EdgeInsets.only(
        right: 10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: SizedBox(
              width: 92,
              height: 98,
              child: _buildCastImage(),
            ),
          ),
          const SizedBox(height: 7),
          Text(
            name.isEmpty ? 'Unknown' : name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            role.isEmpty ? 'Unknown role' : role,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 9,
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CAST IMAGE
  // ============================================================

  Widget _buildCastImage() {
    final url = photoUrl.trim();

    // No photo URL
    if (url.isEmpty) {
      return Container(
        color: const Color(0xFF171918),
        child: const Center(
          child: Icon(
            Icons.person_outline_rounded,
            size: 32,
            color: Colors.white30,
          ),
        ),
      );
    }

    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (
        context,
        error,
        stackTrace,
      ) {
        return Container(
          color: const Color(0xFF171918),
          child: const Center(
            child: Icon(
              Icons.person_outline_rounded,
              size: 32,
              color: Colors.white30,
            ),
          ),
        );
      },
      loadingBuilder: (
        context,
        child,
        loadingProgress,
      ) {
        if (loadingProgress == null) {
          return child;
        }

        return Container(
          color: const Color(0xFF171918),
          child: const Center(
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFFF3F0D6),
              ),
            ),
          ),
        );
      },
    );
  }
}
