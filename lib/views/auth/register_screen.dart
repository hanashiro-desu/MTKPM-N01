import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:moviego/viewmodels/auth_provider.dart';
import 'package:moviego/views/shell/app_shell.dart';
import 'package:moviego/views/widgets/primary_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final auth = context.read<AuthProvider>();
    final ok = await auth.signUp(
      name: _name.text,
      email: _email.text,
      phone: _phone.text,
      password: _password.text,
    );
    if (!mounted) return;
    if (ok) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const AppShell()));
      return;
    }
    final message = auth.error ?? auth.notice;
    if (message != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Đăng ký')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const Text('Tạo tài khoản',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
            const SizedBox(height: 24),
            TextField(
                controller: _name,
                decoration: const InputDecoration(
                    labelText: 'Họ và tên',
                    prefixIcon: Icon(Icons.person_outline))),
            const SizedBox(height: 12),
            TextField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined))),
            const SizedBox(height: 12),
            TextField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                    labelText: 'Số điện thoại',
                    prefixIcon: Icon(Icons.phone_outlined))),
            const SizedBox(height: 12),
            TextField(
                controller: _password,
                obscureText: true,
                decoration: const InputDecoration(
                    labelText: 'Mật khẩu (từ 6 ký tự)',
                    prefixIcon: Icon(Icons.lock_outline))),
            const SizedBox(height: 24),
            PrimaryButton(
                text: loading ? 'Đang tạo tài khoản...' : 'Đăng ký',
                onPressed: loading ? null : _submit),
          ],
        ),
      ),
    );
  }
}
