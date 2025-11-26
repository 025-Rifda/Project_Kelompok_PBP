import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/entities/auth_user.dart';
import '../domain/repositories/auth_repository.dart';

/// Firebase-backed implementation of the domain auth repository.
class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({
    FirebaseAuth? firebaseAuth,
    required SharedPreferences preferences,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _preferences = preferences;

  final FirebaseAuth _firebaseAuth;
  final SharedPreferences _preferences;

  @override
  AuthUser? get currentUser => _toDomainUser(_firebaseAuth.currentUser);

  @override
  Future<AuthUser?> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user;
    if (user != null) {
      await _persistUser(user, fallbackEmail: email);
    }
    return _toDomainUser(user);
  }

  AuthUser? _toDomainUser(User? user) {
    if (user == null) return null;
    final displayName = user.displayName?.trim();
    final name = displayName != null && displayName.isNotEmpty
        ? displayName
        : 'Pengguna';
    return AuthUser(
      id: user.uid,
      email: user.email ?? '',
      displayName: name,
    );
  }

  Future<void> _persistUser(User user, {required String fallbackEmail}) async {
    final username = user.displayName ?? 'Pengguna';
    final email = user.email ?? fallbackEmail;
    final joinDate =
        user.metadata.creationTime?.toIso8601String() ??
        DateTime.now().toIso8601String();

    await _preferences.setString('username', username);
    await _preferences.setString('user_email_$username', email);
    await _preferences.setString('user_join_date_$username', joinDate);
    if (_preferences.getString('user_phone_$username') == null) {
      await _preferences.setString('user_phone_$username', '+62');
    }
    if (_preferences.getString('user_address_$username') == null) {
      await _preferences.setString('user_address_$username', 'Belum diisi');
    }
  }
}
