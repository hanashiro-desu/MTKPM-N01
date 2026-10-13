import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:moviego/core/constants/app_constants.dart';
import 'package:moviego/core/theme/app_theme.dart';
import 'package:moviego/models/movie_model.dart';
import 'package:moviego/viewmodels/booking_provider.dart';
import 'package:moviego/viewmodels/movie_provider.dart';
import 'package:moviego/views/booking/cinema_select_screen.dart';
import 'package:moviego/views/widgets/info_chip.dart';
import 'package:moviego/views/widgets/poster_image.dart';
import 'package:moviego/views/widgets/primary_button.dart';

class MovieDetailScreen extends StatelessWidget {
  final MovieModel movie;

  const MovieDetailScreen({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MovieProvider>();
    final isFavorite = provider.favoriteIds.contains(movie.id);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                      movie.backdropUrl.isEmpty
                          ? AppConstants.fallbackImage
                          : movie.backdropUrl,
                      fit: BoxFit.cover),
                  Container(color: Colors.black38),
                ],
              ),
            ),
            actions: [
              IconButton(
                  onPressed: () =>
                      context.read<MovieProvider>().toggleFavorite(movie),
                  icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: Colors.white)),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PosterImage(url: movie.posterUrl, size: 120),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(movie.title,
                                style: const TextStyle(
                                    fontSize: 26, fontWeight: FontWeight.w900)),
                            const SizedBox(height: 8),
                            Text(movie.genresText,
                                style: TextStyle(color: MovieGoColors.muted)),
                            const SizedBox(height: 6),
                            Row(children: [
                              const Icon(Icons.star_rounded,
                                  color: Colors.amber, size: 18),
                              const SizedBox(width: 6),
                              Text(movie.voteAverage.toStringAsFixed(1),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w800))
                            ]),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  const Text('Nội dung',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 8),
                  Text(
                      movie.overview.isEmpty
                          ? 'Không có mô tả.'
                          : movie.overview,
                      style:
                          TextStyle(color: MovieGoColors.muted, height: 1.6)),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      InfoChip(
                          icon: Icons.calendar_month, label: movie.releaseDate),
                      const SizedBox(width: 10),
                      InfoChip(
                          icon: Icons.access_time_filled,
                          label: '${movie.runtime} phút'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                      text: 'Đặt vé',
                      onPressed: () {
                        context.read<BookingProvider>().selectedMovie = movie;
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const CinemaSelectScreen()));
                      }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
