import 'package:flutter/material.dart';

import 'package:moviego/core/constants/app_constants.dart';
import 'package:moviego/core/theme/app_theme.dart';

class PosterImage extends StatelessWidget {
  final String url;
  final double size;
  final double? height;

  const PosterImage(
      {super.key, required this.url, required this.size, this.height});

  @override
  Widget build(BuildContext context) {
    final imageHeight = height ?? (size == 68 ? 96.0 : 220.0);

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Image.network(
        url.isEmpty ? AppConstants.fallbackImage : url,
        width: size,
        height: imageHeight,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Image.network(
          AppConstants.fallbackImage,
          width: size,
          height: imageHeight,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            width: size,
            height: imageHeight,
            color: MovieGoColors.surface,
            child: const Icon(Icons.movie_outlined,
                color: MovieGoColors.primary, size: 40),
          ),
        ),
      ),
    );
  }
}
