import 'package:flutter/foundation.dart';

import 'package:moviego/db/repositories/auth_repository.dart';
import 'package:moviego/models/user_model.dart';

/// ViewModel đăng nhập/đăng ký. [isDemo] = true khi chưa cấu hình Supabase.
class AuthProvider extends ChangeNotifier {
  AuthProvider({required AuthRepository repository, this.isDemo = false})
      : _repo = repository;

  final AuthRepository _repo;
  final bool isDemo;

  bool isLoading = false;
  String? error;
  String? notice;

  UserModel? get user => _repo.currentUser;
  bool get isLoggedIn => user != null;

  Future<bool> signIn(String email, String password) => _run(() async {
        if (email.trim().isEmpty || password.isEmpty) {
          throw const AuthFailure('Vui lòng nhập email và mật khẩu');
        }
        await _repo.signIn(email: email, password: password);
      });

  Future<bool> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) =>
      _run(() async {
        if (name.trim().isEmpty || email.trim().isEmpty || password.length < 6) {
          throw const AuthFailure('Vui lòng nhập đủ họ tên, email và mật khẩu (từ 6 ký tự)');
        }
        final created = await _repo.signUp(
          name: name,
          email: email,
          phone: phone,
          password: password,
        );
        if (created == null) {
          notice = 'Đã gửi email xác nhận, hãy xác nhận rồi đăng nhập.';
          throw const AuthFailure('');
        }
      });

  Future<void> signOut() async {
    await _repo.signOut();
    notifyListeners();
  }

  Future<bool> resetPassword(String email) => _run(() async {
        if (email.trim().isEmpty) throw const AuthFailure('Vui lòng nhập email');
        await _repo.sendPasswordReset(email);
        notice = 'Đã gửi hướng dẫn đặt lại mật khẩu tới email của bạn.';
      });

  Future<bool> _run(Future<void> Function() action) async {
    isLoading = true;
    error = null;
    notice = null;
    notifyListeners();
    try {
      await action();
      return true;
    } on AuthFailure catch (e) {
      error = e.message.isEmpty ? null : e.message;
      return false;
    } catch (_) {
      error = 'Không thể xử lý yêu cầu, vui lòng thử lại';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
