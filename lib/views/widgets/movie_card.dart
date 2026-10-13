import 'package:flutter/material.dart';

import 'package:moviego/core/theme/app_theme.dart';
import 'package:moviego/models/movie_model.dart';
import 'package:moviego/views/widgets/poster_image.dart';

class MovieCard extends StatelessWidget {
  final MovieModel movie;
  final double width;
  final VoidCallback onTap;

  const MovieCard(
      {super.key,
      required this.movie,
      required this.width,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final posterHeight = (constraints.maxHeight - 78).clamp(120.0, 220.0);
          return GestureDetector(
            onTap: onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PosterImage(
                    url: movie.posterUrl,
                    size: constraints.maxWidth,
                    height: posterHeight),
                const SizedBox(height: 8),
                Text(movie.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text('${movie.voteAverage.toStringAsFixed(1)} ★',
                    style: TextStyle(
                        color: MovieGoColors.primary,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          );
        },
      ),
    );
  }
}
