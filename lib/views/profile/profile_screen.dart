import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:moviego/core/theme/app_theme.dart';
import 'package:moviego/viewmodels/auth_provider.dart';
import 'package:moviego/viewmodels/movie_provider.dart';
import 'package:moviego/views/auth/login_screen.dart';
import 'package:moviego/views/widgets/primary_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MovieProvider>();
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(title: const Text('Tài khoản')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              const CircleAvatar(
                  radius: 34, child: Icon(Icons.person_rounded, size: 34)),
              const SizedBox(width: 16),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(user?.name ?? 'Khách',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w900)),
                Text(user?.email ?? '',
                    style: TextStyle(color: MovieGoColors.muted))
              ]),
            ],
          ),
          const SizedBox(height: 20),
          const ListTile(
              leading: Icon(Icons.favorite_border),
              title: Text('Phim yêu thích'),
              trailing: Icon(Icons.chevron_right)),
          const ListTile(
              leading: Icon(Icons.history_rounded),
              title: Text('Lịch sử vé'),
              trailing: Icon(Icons.chevron_right)),
          const ListTile(
              leading: Icon(Icons.notifications_none_rounded),
              title: Text('Thông báo'),
              trailing: Icon(Icons.chevron_right)),
          const ListTile(
              leading: Icon(Icons.lock_outline_rounded),
              title: Text('Đổi mật khẩu'),
              trailing: Icon(Icons.chevron_right)),
          const SizedBox(height: 20),
          PrimaryButton(
            text: 'Đăng xuất',
            onPressed: () async {
              await context.read<AuthProvider>().signOut();
              if (!context.mounted) return;
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
          ),
          const SizedBox(height: 14),
          if (provider.favoriteMovies.isNotEmpty)
            Text('Yêu thích: ${provider.favoriteMovies.length} phim',
                style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
