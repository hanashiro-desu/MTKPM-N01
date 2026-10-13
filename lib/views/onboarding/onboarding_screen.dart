import 'package:flutter/material.dart';

import 'package:moviego/core/theme/app_theme.dart';
import 'package:moviego/views/auth/login_screen.dart';
import 'package:moviego/views/widgets/primary_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'title': 'Khám phá phim mới',
      'subtitle': 'Cập nhật hàng trăm phim hot và tuyệt vời',
      'icon': Icons.movie_creation_rounded
    },
    {
      'title': 'Đặt vé nhanh',
      'subtitle': 'Chọn rạp, suất chiếu, ghế và thanh toán trong vài bước',
      'icon': Icons.event_seat_rounded
    },
    {
      'title': 'Trải nghiệm đỉnh cao',
      'subtitle': 'Vé điện tử, QR, thưởng thức và quản lý vé dễ dàng',
      'icon': Icons.qr_code_2_rounded
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _pages.length,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemBuilder: (_, i) {
                    final page = _pages[i];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            color: MovieGoColors.surface,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Icon(page['icon'],
                              size: 72, color: MovieGoColors.primary),
                        ),
                        const SizedBox(height: 32),
                        Text(page['title'],
                            style: const TextStyle(
                                fontSize: 28, fontWeight: FontWeight.w900),
                            textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        Text(page['subtitle'],
                            style: TextStyle(
                                color: MovieGoColors.muted, fontSize: 16),
                            textAlign: TextAlign.center),
                      ],
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: _index == i ? 24 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: _index == i
                          ? MovieGoColors.primary
                          : MovieGoColors.border,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              PrimaryButton(
                text: _index == _pages.length - 1 ? 'Bắt đầu' : 'Tiếp tục',
                onPressed: () {
                  if (_index == _pages.length - 1) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                    return;
                  }
                  _controller.nextPage(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
