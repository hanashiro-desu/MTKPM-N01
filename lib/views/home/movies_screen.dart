import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:moviego/viewmodels/movie_provider.dart';
import 'package:moviego/views/movie/movie_detail_screen.dart';
import 'package:moviego/views/widgets/error_card.dart';
import 'package:moviego/views/widgets/movie_card.dart';

class MoviesScreen extends StatefulWidget {
  const MoviesScreen({super.key});

  @override
  State<MoviesScreen> createState() => _MoviesScreenState();
}

class _MoviesScreenState extends State<MoviesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MovieProvider>().loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MovieProvider>();
    final movies = [
      ...provider.nowPlaying,
      ...provider.popular,
      ...provider.upcoming
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Phim')),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.errorMessage != null
              ? Center(
                  child: ErrorCard(
                      message: provider.errorMessage!,
                      onRetry: provider.loadAll))
              : movies.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Chưa có dữ liệu phim'),
                          const SizedBox(height: 12),
                          FilledButton.tonal(
                              onPressed: provider.loadAll,
                              child: const Text('Tải lại')),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: provider.loadAll,
                      child: GridView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.66,
                        ),
                        itemCount: movies.length,
                        itemBuilder: (_, index) {
                          final movie = movies[index];
                          return MovieCard(
                              movie: movie,
                              width: double.infinity,
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          MovieDetailScreen(movie: movie))));
                        },
                      ),
                    ),
    );
  }
}
