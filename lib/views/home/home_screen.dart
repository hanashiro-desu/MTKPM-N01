import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:moviego/core/constants/app_constants.dart';
import 'package:moviego/models/movie_model.dart';
import 'package:moviego/viewmodels/movie_provider.dart';
import 'package:moviego/views/home/movies_screen.dart';
import 'package:moviego/views/home/search_screen.dart';
import 'package:moviego/views/movie/movie_detail_screen.dart';
import 'package:moviego/views/widgets/app_logo.dart';
import 'package:moviego/views/widgets/error_card.dart';
import 'package:moviego/views/widgets/movie_card.dart';
import 'package:moviego/views/widgets/section_header.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MovieProvider>().loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final movieProvider = context.watch<MovieProvider>();
    final bannerMovies = movieProvider.nowPlaying.isNotEmpty
        ? movieProvider.nowPlaying.take(3).toList()
        : <MovieModel>[];

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: movieProvider.loadAll,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                const Expanded(child: AppLogo()),
                IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.notifications_none_rounded)),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              readOnly: true,
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SearchScreen())),
              decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Tìm kiếm phim, rạp...'),
            ),
            const SizedBox(height: 20),
            if (movieProvider.isLoading)
              const LinearProgressIndicator(minHeight: 4)
            else if (movieProvider.errorMessage != null)
              ErrorCard(
                  message: movieProvider.errorMessage!,
                  onRetry: movieProvider.loadAll)
            else if (bannerMovies.isNotEmpty)
              SizedBox(
                height: 220,
                child: PageView.builder(
                  itemCount: bannerMovies.length,
                  itemBuilder: (context, index) {
                    final movie = bannerMovies[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    MovieDetailScreen(movie: movie))),
                        child: Hero(
                          tag: 'banner-${movie.id}',
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Stack(
                              children: [
                                Positioned.fill(
                                    child: Image.network(
                                        movie.backdropUrl.isEmpty
                                            ? AppConstants.fallbackImage
                                            : movie.backdropUrl,
                                        fit: BoxFit.cover)),
                                Container(color: Colors.black38),
                                Positioned(
                                  left: 18,
                                  right: 18,
                                  bottom: 18,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(movie.title,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.w900)),
                                      Text(
                                          '${movie.genresText} • ${movie.voteAverage.toStringAsFixed(1)}',
                                          style: const TextStyle(
                                              color: Colors.white70)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 24),
            SectionHeader(
                title: 'Đang chiếu',
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const MoviesScreen()))),
            const SizedBox(height: 12),
            SizedBox(
              height: 260,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: movieProvider.nowPlaying.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, index) {
                  final movie = movieProvider.nowPlaying[index];
                  return MovieCard(
                      movie: movie,
                      width: 160,
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  MovieDetailScreen(movie: movie))));
                },
              ),
            ),
            const SizedBox(height: 24),
            SectionHeader(
                title: 'Phổ biến',
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const MoviesScreen()))),
            const SizedBox(height: 12),
            SizedBox(
              height: 260,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: movieProvider.popular.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, index) {
                  final movie = movieProvider.popular[index];
                  return MovieCard(
                      movie: movie,
                      width: 160,
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  MovieDetailScreen(movie: movie))));
                },
              ),
            ),
            const SizedBox(height: 24),
            SectionHeader(
                title: 'Sắp chiếu',
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const MoviesScreen()))),
            const SizedBox(height: 12),
            SizedBox(
              height: 260,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: movieProvider.upcoming.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, index) {
                  final movie = movieProvider.upcoming[index];
                  return MovieCard(
                      movie: movie,
                      width: 160,
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  MovieDetailScreen(movie: movie))));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
