import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const SectionHeader({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: Text(title,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w900))),
        TextButton(onPressed: onTap, child: const Text('Xem tất cả')),
      ],
    );
  }
}
