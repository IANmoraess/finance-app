abstract class AuthService {
  Future<void> login(String email, String password);
  Future<void> logout();
  Future<void> register(String name, String email, String password);
  bool get isAuthenticated;
  String? get currentUserId;
}
