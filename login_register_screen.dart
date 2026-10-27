import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Các class này cần có trong dự án MOVIEGO:
// SessionProvider, AuthResult, AppShell, AppLogo, PrimaryButton.
// Nếu chúng nằm ở file khác, hãy thêm import tương ứng.

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final result = await context.read<SessionProvider>().signIn(
            email: _emailController.text,
            password: _passwordController.text,
          );

      if (!mounted) return;

      if (result == AuthResult.success) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const AppShell()),
          (_) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email hoặc mật khẩu không chính xác.'),
          ),
        );
      }
    } on Exception catch (error, stackTrace) {
      debugPrint('Local demo sign-in failed: $error\n$stackTrace');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Không thể đọc tài khoản trên thiết bị. Vui lòng thử lại.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AppLogo(),
                  const SizedBox(height: 26),
                  const Text(
                    'Chào mừng đến MOVIEGO',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    key: const ValueKey('login-email'),
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.username],
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (value) {
                      final email = value?.trim() ?? '';
                      if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                          .hasMatch(email)) {
                        return 'Nhập địa chỉ email hợp lệ';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    key: const ValueKey('login-password'),
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    autofillHints: const [AutofillHints.password],
                    decoration: InputDecoration(
                      labelText: 'Mật khẩu',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        tooltip: _obscurePassword
                            ? 'Hiện mật khẩu'
                            : 'Ẩn mật khẩu',
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                    validator: (value) =>
                        (value == null || value.isEmpty)
                            ? 'Nhập mật khẩu'
                            : null,
                    onFieldSubmitted: (_) => _signIn(),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Chức năng quên mật khẩu chưa khả dụng trong demo.',
                            ),
                          ),
                        );
                      },
                      child: const Text('Quên mật khẩu?'),
                    ),
                  ),
                  PrimaryButton(
                    text: _isLoading ? 'Đang đăng nhập...' : 'Đăng nhập',
                    onPressed: _isLoading ? null : _signIn,
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _isLoading
                        ? null
                        : () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RegisterScreen(),
                              ),
                            ),
                    child: const Text('Chưa có tài khoản? Đăng ký'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final result = await context.read<SessionProvider>().register(
            name: _nameController.text,
            email: _emailController.text,
            password: _passwordController.text,
          );

      if (!mounted) return;

      if (result == AuthResult.emailAlreadyRegistered) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email này đã được đăng ký trên thiết bị.'),
          ),
        );
        return;
      }

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AppShell()),
        (_) => false,
      );
    } on Exception catch (error, stackTrace) {
      debugPrint('Local demo registration failed: $error\n$stackTrace');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Không thể lưu tài khoản trên thiết bị. Vui lòng thử lại.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng ký')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  key: const ValueKey('register-name'),
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  autofillHints: const [AutofillHints.name],
                  decoration: const InputDecoration(
                    labelText: 'Họ và tên',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) =>
                      (value?.trim().isEmpty ?? true)
                          ? 'Nhập họ và tên'
                          : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  key: const ValueKey('register-email'),
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    final email = value?.trim() ?? '';
                    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                        .hasMatch(email)) {
                      return 'Nhập địa chỉ email hợp lệ';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  key: const ValueKey('register-password'),
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  autofillHints: const [AutofillHints.newPassword],
                  decoration: InputDecoration(
                    labelText: 'Mật khẩu (ít nhất 8 ký tự)',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      tooltip: _obscurePassword
                          ? 'Hiện mật khẩu'
                          : 'Ẩn mật khẩu',
                      onPressed: () => setState(
                        () => _obscurePassword = !_obscurePassword,
                      ),
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                  validator: (value) => (value?.length ?? 0) < 8
                      ? 'Mật khẩu cần ít nhất 8 ký tự'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  key: const ValueKey('register-confirm-password'),
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Nhập lại mật khẩu',
                    prefixIcon: Icon(Icons.lock_reset_outlined),
                  ),
                  validator: (value) =>
                      value != _passwordController.text
                          ? 'Mật khẩu nhập lại không khớp'
                          : null,
                  onFieldSubmitted: (_) => _register(),
                ),
                const SizedBox(height: 20),
                PrimaryButton(
                  text: _isLoading ? 'Đang tạo tài khoản...' : 'Đăng ký',
                  onPressed: _isLoading ? null : _register,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
