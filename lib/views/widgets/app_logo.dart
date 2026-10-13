import 'package:flutter/material.dart';

import 'package:moviego/core/constants/app_constants.dart';
import 'package:moviego/core/theme/app_theme.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: const [
        Icon(Icons.movie_creation_rounded,
            color: MovieGoColors.primary, size: 30),
        SizedBox(width: 8),
        Text(AppConstants.appName,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
      ],
    );
  }
}
