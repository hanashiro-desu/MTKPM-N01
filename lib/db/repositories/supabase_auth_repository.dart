import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:moviego/db/repositories/auth_repository.dart';
import 'package:moviego/db/supabase_client.dart';
import 'package:moviego/models/user_model.dart';

class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository({SupabaseClient? client}) : _db = client ?? DatabaseConfig.client;

  final SupabaseClient _db;

  @override
  UserModel? get currentUser {
    final user = _db.auth.currentUser;
    return user == null ? null : _toModel(user);
  }

  @override
  Future<UserModel> signIn({required String email, required String password}) async {
    try {
      final res = await _db.auth.signInWithPassword(email: email.trim(), password: password);
      final user = res.user;
      if (user == null) throw const AuthFailure('Đăng nhập thất bại');
      return _withRole(user);
    } on AuthException catch (e) {
      throw AuthFailure(_friendly(e.message));
    }
  }

  @override
  Future<UserModel?> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final res = await _db.auth.signUp(
        email: email.trim(),
        password: password,
        data: {'full_name': name.trim(), 'phone': phone.trim()},
      );
      if (res.session == null || res.user == null) return null;
      return _withRole(res.user!);
    } on AuthException catch (e) {
      throw AuthFailure(_friendly(e.message));
    }
  }

  @override
  Future<void> signOut() => _db.auth.signOut();

  @override
  Future<void> sendPasswordReset(String email) async {
    try {
      await _db.auth.resetPasswordForEmail(email.trim());
    } on AuthException catch (e) {
      throw AuthFailure(_friendly(e.message));
    }
  }

  /// Vai trò (customer/staff/manager) nằm ở bảng `profiles`, không tin vào dữ liệu phía client.
  Future<UserModel> _withRole(User user) async {
    try {
      final row = await _db.from('profiles').select('role').eq('id', user.id).maybeSingle();
      return _toModel(user, role: (row?['role'] ?? 'customer').toString());
    } catch (_) {
      return _toModel(user);
    }
  }

  UserModel _toModel(User user, {String role = 'customer'}) {
    final meta = user.userMetadata ?? const <String, dynamic>{};
    return UserModel(
      id: user.id,
      name: (meta['full_name'] ?? user.email ?? '').toString(),
      email: user.email ?? '',
      phone: (meta['phone'] ?? '').toString(),
      role: role,
      avatarUrl: '',
    );
  }

  String _friendly(String message) {
    final text = message.toLowerCase();
    if (text.contains('invalid login')) return 'Email hoặc mật khẩu không đúng';
    if (text.contains('already registered')) return 'Email này đã được đăng ký';
    if (text.contains('password should be')) return 'Mật khẩu cần ít nhất 6 ký tự';
    if (text.contains('email not confirmed')) return 'Vui lòng xác nhận email trước khi đăng nhập';
    return 'Không thể xử lý yêu cầu, vui lòng thử lại';
  }
}
