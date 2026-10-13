import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:moviego/viewmodels/booking_provider.dart';
import 'package:moviego/views/cinema/cinemas_screen.dart';
import 'package:moviego/views/home/home_screen.dart';
import 'package:moviego/views/home/movies_screen.dart';
import 'package:moviego/views/profile/profile_screen.dart';
import 'package:moviego/views/ticket/tickets_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<BookingProvider>().loadMyBookings();
    });
  }

  final List<Widget> _pages = const [
    HomeScreen(),
    MoviesScreen(),
    CinemasScreen(),
    TicketsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Home'),
          NavigationDestination(
              icon: Icon(Icons.movie_outlined),
              selectedIcon: Icon(Icons.movie_rounded),
              label: 'Movies'),
          NavigationDestination(
              icon: Icon(Icons.location_on_outlined),
              selectedIcon: Icon(Icons.location_on_rounded),
              label: 'Cinemas'),
          NavigationDestination(
              icon: Icon(Icons.confirmation_number_outlined),
              selectedIcon: Icon(Icons.confirmation_number_rounded),
              label: 'Tickets'),
          NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'Profile'),
        ],
      ),
    );
  }
}
