import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:moviego/viewmodels/booking_provider.dart';
import 'package:moviego/views/booking/showtime_screen.dart';

class CinemasScreen extends StatelessWidget {
  const CinemasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bookingProvider = context.watch<BookingProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Rạp chiếu')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: bookingProvider.cinemas.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, index) {
          final cinema = bookingProvider.cinemas[index];
          return Card(
            child: ListTile(
              onTap: () {
                bookingProvider.selectCinema(cinema);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ShowtimeScreen()));
              },
              contentPadding: const EdgeInsets.all(14),
              leading: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(cinema.image,
                      width: 62, height: 62, fit: BoxFit.cover)),
              title: Text(cinema.name,
                  style: const TextStyle(fontWeight: FontWeight.w800)),
              subtitle:
                  Text('${cinema.address}\n${cinema.rooms.length} phòng chiếu'),
              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }
}
