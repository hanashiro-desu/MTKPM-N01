import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:moviego/core/theme/app_theme.dart';
import 'package:moviego/viewmodels/auth_provider.dart';
import 'package:moviego/views/auth/forgot_password_screen.dart';
import 'package:moviego/views/auth/register_screen.dart';
import 'package:moviego/views/shell/app_shell.dart';
import 'package:moviego/views/widgets/app_logo.dart';
import 'package:moviego/views/widgets/primary_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    super.initState();
    final demo = context.read<AuthProvider>().isDemo;
    _email = TextEditingController(text: demo ? 'user@moviego.vn' : '');
    _password = TextEditingController(text: demo ? '123456' : '');
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final auth = context.read<AuthProvider>();
    final ok = await auth.signIn(_email.text, _password.text);
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AppShell()),
      );
    } else if (auth.error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(auth.error!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const AppLogo(),
              const SizedBox(height: 30),
              const Text('Chào mừng trở lại',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              Text('Đăng nhập để đặt vé và quản lý lịch xem.',
                  style: TextStyle(color: MovieGoColors.muted)),
              const SizedBox(height: 28),
              TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined))),
              const SizedBox(height: 16),
              TextField(
                  controller: _password,
                  obscureText: true,
                  decoration: const InputDecoration(
                      labelText: 'Mật khẩu',
                      prefixIcon: Icon(Icons.lock_outline))),
              const SizedBox(height: 8),
              Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ForgotPasswordScreen())),
                      child: const Text('Quên mật khẩu?'))),
              const SizedBox(height: 16),
              PrimaryButton(
                text: loading ? 'Đang đăng nhập...' : 'Đăng nhập',
                onPressed: loading ? null : _submit,
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Chưa có tài khoản? '),
                  TextButton(
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const RegisterScreen())),
                      child: const Text('Đăng ký ngay')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
