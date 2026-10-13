import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:moviego/viewmodels/booking_provider.dart';
import 'package:moviego/views/booking/showtime_screen.dart';

class CinemaSelectScreen extends StatelessWidget {
  const CinemaSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cinemas = context.watch<BookingProvider>().cinemas;
    return Scaffold(
      appBar: AppBar(title: const Text('Chọn rạp')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: cinemas.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, index) {
          final cinema = cinemas[index];
          return Card(
            child: ListTile(
              onTap: () {
                context.read<BookingProvider>().selectCinema(cinema);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ShowtimeScreen()));
              },
              title: Text(cinema.name,
                  style: const TextStyle(fontWeight: FontWeight.w800)),
              subtitle: Text(cinema.address),
              trailing: const Icon(Icons.chevron_right),
            ),
          );
        },
      ),
    );
  }
}
