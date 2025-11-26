import '../entities/auth_user.dart';

/// Abstraction boundary for authentication operations.
abstract class AuthRepository {
  Future<AuthUser?> signIn({
    required String email,
    required String password,
  });

  AuthUser? get currentUser;
}
