import 'package:flutter/material.dart';

class MoviePoster extends StatelessWidget {
  final String asset;
  final String duration;
  final String genre;

  const MoviePoster({
    super.key,
    required this.asset,
    required this.duration,
    required this.genre,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            asset,
            fit: BoxFit.fill,
            errorBuilder: (_, __, ___) {
              return Container(
                color: const Color(0xFF171918),
                child: const Icon(
                  Icons.movie_outlined,
                  color: Colors.white30,
                  size: 50,
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
          Positioned(
            left: 14,
            bottom: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(.65),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                '$genre • $duration',
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
