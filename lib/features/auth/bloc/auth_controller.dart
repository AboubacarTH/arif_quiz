import 'package:arif_quiz/core/auth/google_auth_service.dart';
import 'package:arif_quiz/core/i18n/auth_error_l10n.dart';
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
class AuthGoogleRequested extends AuthEvent {}
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
  /// Code d'erreur stable (jamais affiché tel quel) : l'écran le traduit dans
  /// la langue courante via [AuthErrorL10n].
  String? get errorCode =>
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
    } on GoogleAccountException {
      // Aucun mot de passe ne marchera : on oriente vers le bon bouton plutôt
      // que de laisser croire à une faute de frappe.
      _emit(AuthError(AuthErrorCodes.useGoogleToSignIn));
      return false;
    } catch (_) {
      _emit(AuthError(AuthErrorCodes.invalidCredentials));
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
      _emit(AuthError(AuthErrorCodes.registrationFailed));
      return false;
    }
  }

  /// Connexion via Google.
  ///
  /// Renvoie `false` aussi bien sur échec que sur annulation : dans le second
  /// cas aucun message n'est affiché, refermer le sélecteur de compte est un
  /// choix, pas une erreur.
  Future<bool> signInWithGoogle() async {
    _emit(AuthLoading());
    try {
      final result = await _repo.signInWithGoogle();
      _emit(AuthAuthenticated(result.user));
      return true;
    } on GoogleAuthException catch (e) {
      if (e.reason == GoogleAuthFailure.cancelled) {
        _emit(AuthUnauthenticated());
      } else {
        _emit(AuthError(_codeFor(e.reason)));
      }
      return false;
    } catch (_) {
      // Le jeton Google était bon, c'est l'échange avec notre serveur qui a
      // échoué.
      _emit(AuthError(AuthErrorCodes.googleSignInFailed));
      return false;
    }
  }

  String _codeFor(GoogleAuthFailure reason) => switch (reason) {
        GoogleAuthFailure.unavailable => AuthErrorCodes.googleUnavailable,
        GoogleAuthFailure.misconfigured => AuthErrorCodes.googleMisconfigured,
        _ => AuthErrorCodes.googleSignInFailed,
      };

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
