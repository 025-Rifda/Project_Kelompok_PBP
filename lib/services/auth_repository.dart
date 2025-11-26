import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Abstraction layer for auth and local persistence to decouple UI from SDK singletons.
class AuthRepository {
  AuthRepository({
    FirebaseAuth? firebaseAuth,
    required SharedPreferences preferences,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _preferences = preferences;

  final FirebaseAuth _firebaseAuth;
  final SharedPreferences _preferences;

  User? get currentUser => _firebaseAuth.currentUser;

  Future<User?> signIn({
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
    return user;
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
