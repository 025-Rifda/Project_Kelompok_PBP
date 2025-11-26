import 'package:auth_module/auth_module.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(
    this._loginUseCase,
    this._getCurrentUserUseCase,
  ) : super(AuthInitial());

  final LoginUseCase _loginUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;

  Future<void> login({
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());
    try {
      final user = await _loginUseCase(
        email: email,
        password: password,
      );

      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthError('Login gagal. Coba lagi.'));
      }
    } on FirebaseAuthException catch (e) {
      emit(AuthError(_mapFirebaseError(e)));
    } catch (e) {
      emit(AuthError('Terjadi kesalahan: $e'));
    }
  }

  Future<void> checkExistingSession() async {
    final user = _getCurrentUserUseCase();
    if (user != null) emit(AuthAuthenticated(user));
  }

  String _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Pengguna tidak ditemukan. Silakan daftar dulu.';
      case 'wrong-password':
        return 'Password salah. Silakan coba lagi.';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan. Coba beberapa saat lagi.';
      default:
        return 'Gagal login: ${e.message ?? e.code}';
    }
  }
}
