import 'package:auth_module/auth_module.dart';

/// State tree for authentication flows (login, etc).
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  AuthAuthenticated(this.user);

  final AuthUser user;
}

class AuthError extends AuthState {
  AuthError(this.message);

  final String message;
}
