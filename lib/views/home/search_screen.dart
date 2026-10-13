import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:moviego/viewmodels/movie_provider.dart';
import 'package:moviego/views/movie/movie_detail_screen.dart';
import 'package:moviego/views/widgets/poster_image.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MovieProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Tìm kiếm phim')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              autofocus: true,
              decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search), hintText: 'Nhập tên phim...'),
              onChanged: (value) => context.read<MovieProvider>().search(value),
            ),
            const SizedBox(height: 16),
            if (provider.isSearching)
              const Center(child: CircularProgressIndicator())
            else if (provider.searchResults.isEmpty)
              const Expanded(
                  child: Center(child: Text('Không có phim nào phù hợp')))
            else
              Expanded(
                child: ListView.separated(
                  itemCount: provider.searchResults.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, index) {
                    final movie = provider.searchResults[index];
                    return ListTile(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => MovieDetailScreen(movie: movie))),
                      leading: PosterImage(url: movie.posterUrl, size: 68),
                      title: Text(movie.title,
                          style: const TextStyle(fontWeight: FontWeight.w800)),
                      subtitle: Text(
                          '${movie.releaseDate} • ${movie.voteAverage.toStringAsFixed(1)}'),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
