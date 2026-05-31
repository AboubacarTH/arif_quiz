import 'package:arif_quiz/features/auth/data/auth_repository.dart';
import 'package:arif_quiz/shared/models/models.dart';
import 'package:flutter/foundation.dart';

// ── Events ────────────────────────────────────────────────────
abstract class AuthEvent {}
class AuthLoginRequested extends AuthEvent {
  final String email, password;
  AuthLoginRequested(this.email, this.password);
}
class AuthRegisterRequested extends AuthEvent {
  final String name, email, password;
  AuthRegisterRequested(this.name, this.email, this.password);
}
class AuthLogoutRequested extends AuthEvent {}
class AuthCheckRequested extends AuthEvent {}

// ── States ────────────────────────────────────────────────────
abstract class AuthState {}
class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthAuthenticated extends AuthState {
  final UserModel user;
  AuthAuthenticated(this.user);
}
class AuthUnauthenticated extends AuthState {}
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

// ── Controller ────────────────────────────────────────────────
class AuthController extends ChangeNotifier {
  final AuthRepository _repo;

  AuthState _state = AuthInitial();
  AuthState get state => _state;

  UserModel? get currentUser =>
      _state is AuthAuthenticated ? (_state as AuthAuthenticated).user : null;
  bool get isAuthenticated => _state is AuthAuthenticated;
  bool get isLoading => _state is AuthLoading;
  String? get errorMessage =>
      _state is AuthError ? (_state as AuthError).message : null;

  AuthController(this._repo);

  Future<void> checkAuth() async {
    _emit(AuthLoading());
    try {
      final loggedIn = await _repo.isLoggedIn();
      if (loggedIn) {
        final user = await _repo.getMe();
        _emit(AuthAuthenticated(user));
      } else {
        _emit(AuthUnauthenticated());
      }
    } catch (_) {
      _emit(AuthUnauthenticated());
    }
  }

  Future<bool> login(String email, String password) async {
    _emit(AuthLoading());
    try {
      final result = await _repo.login(email.trim(), password);
      _emit(AuthAuthenticated(result.user));
      return true;
    } catch (_) {
      _emit(AuthError('Invalid email or password. Please try again.'));
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    _emit(AuthLoading());
    try {
      final result = await _repo.register(name.trim(), email.trim(), password);
      _emit(AuthAuthenticated(result.user));
      return true;
    } catch (_) {
      _emit(AuthError('Registration failed. Email may already be in use.'));
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _repo.logout();
    } finally {
      _emit(AuthUnauthenticated());
    }
  }

  void clearError() {
    if (_state is AuthError) _emit(AuthUnauthenticated());
  }

  void _emit(AuthState s) {
    _state = s;
    notifyListeners();
  }
}
