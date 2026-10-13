import 'package:flutter/material.dart';

import 'package:moviego/core/theme/app_theme.dart';

class ErrorCard extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const ErrorCard({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: MovieGoColors.surface,
          borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          FilledButton.tonal(
              onPressed: () => onRetry(), child: const Text('Thử lại')),
        ],
      ),
    );
  }
}
