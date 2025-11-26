import 'package:firebase_auth/firebase_auth.dart';

/// State tree for authentication flows (login, etc).
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  AuthAuthenticated(this.user);

  final User user;
}

class AuthError extends AuthState {
  AuthError(this.message);

  final String message;
}
