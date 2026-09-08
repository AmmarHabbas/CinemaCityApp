import 'package:cinema_ui_reference/screens/seat_selection_screen.dart';
import 'package:flutter/material.dart';

import '../../models/movie.dart';
import '../../models/showtime.dart';

import '../../services/showtime_service.dart';

class ShowtimesScreen extends StatelessWidget {
  final Movie movie;

  const ShowtimesScreen({
    super.key,
    required this.movie,
  });

  @override
  Widget build(BuildContext context) {
    final service = ShowtimeService();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Select Showtime'),
      ),
      body: StreamBuilder<List<Showtime>>(
        stream: service.getShowtimesForMovie(
          movie.id,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Failed to load showtimes.\n\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final showtimes = snapshot.data ?? [];

          if (showtimes.isEmpty) {
            return const Center(
              child: Text(
                'No showtimes available for this movie.',
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: showtimes.length,
            itemBuilder: (context, index) {
              final showtime = showtimes[index];

              return _showtimeCard(
                context,
                showtime,
              );
            },
          );
        },
      ),
    );
  }

  Widget _showtimeCard(
    BuildContext context,
    Showtime showtime,
  ) {
    return Card(
      color: const Color(0xFF111313),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SeatSelectionScreen(
                movie: movie,
                showtime: showtime,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F0D6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.access_time_rounded,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      showtime.hallName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatDate(
                        showtime.date,
                      ),
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatTime(
                        showtime.startTime,
                      ),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '\$${showtime.price.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Color(0xFFF3F0D6),
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                color: Colors.white54,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(String time) {
    final parts = time.split(':');

    if (parts.length != 2) {
      return time;
    }

    final hour = int.tryParse(parts[0]) ?? 0;

    final minute = int.tryParse(parts[1]) ?? 0;

    final period = hour >= 12 ? 'PM' : 'AM';

    final displayHour = hour % 12 == 0 ? 12 : hour % 12;

    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }
}
