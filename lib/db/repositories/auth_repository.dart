import 'package:moviego/models/user_model.dart';

class AuthFailure implements Exception {
  const AuthFailure(this.message);
  final String message;

  @override
  String toString() => message;
}

abstract interface class AuthRepository {
  UserModel? get currentUser;
  Future<UserModel> signIn({required String email, required String password});

  /// Trả về null khi dự án Supabase bật xác nhận email (chưa có phiên đăng nhập).
  Future<UserModel?> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
  });
  Future<void> signOut();
  Future<void> sendPasswordReset(String email);
}

/// Chế độ offline/demo: không kiểm tra mật khẩu thật.
class LocalAuthRepository implements AuthRepository {
  UserModel? _user;

  @override
  UserModel? get currentUser => _user;

  @override
  Future<UserModel> signIn({required String email, required String password}) async =>
      _user = _demoUser(name: 'Khách hàng', email: email);

  @override
  Future<UserModel?> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async =>
      _user = _demoUser(name: name, email: email, phone: phone);

  @override
  Future<void> signOut() async => _user = null;

  @override
  Future<void> sendPasswordReset(String email) async {}

  UserModel _demoUser({required String name, required String email, String phone = ''}) =>
      UserModel(id: 'demo-user', name: name, email: email, phone: phone, role: 'customer', avatarUrl: '');
}
