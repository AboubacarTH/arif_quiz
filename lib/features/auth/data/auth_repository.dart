import 'package:arif_quiz/core/api/api_service.dart';
import 'package:arif_quiz/core/auth/google_auth_service.dart';
import 'package:arif_quiz/shared/models/models.dart';
import 'package:dio/dio.dart';

/// Le compte existe, mais il a été créé via Google : aucun mot de passe ne
/// pourra jamais l'ouvrir.
class GoogleAccountException implements Exception {
  const GoogleAccountException();
}

class AuthRepository {
  final ApiService _api;
  final GoogleAuthService _google;

  AuthRepository(this._api, {GoogleAuthService? google})
      : _google = google ?? GoogleAuthService();

  Future<({UserModel user, String token})> login(
      String email, String password) async {
    final Map<String, dynamic> res;
    try {
      res = await _api.login(email, password);
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map && data['reason'] == 'google_account') {
        throw const GoogleAccountException();
      }
      rethrow;
    }

    final token = res['token'] as String;

    await _api.saveToken(token);

    return (
      user: UserModel.fromJson(res['user']),
      token: token,
    );
  }

  Future<({UserModel user, String token})> register(
      String name, String email, String password) async {
    final res = await _api.register(name, email, password);
    final token = res['token'] as String;

    await _api.saveToken(token);
    
    return (
      user: UserModel.fromJson(res['user']),
      token: token,
    );
  }

  /// Connexion Google : l'ID token obtenu sur l'appareil est échangé contre
  /// une session applicative. Le compte est créé côté serveur au premier
  /// passage.
  Future<({UserModel user, String token})> signInWithGoogle() async {
    final idToken = await _google.obtainIdToken();
    final res = await _api.googleSignIn(idToken);
    final token = res['token'] as String;

    await _api.saveToken(token);

    return (
      user: UserModel.fromJson(res['user']),
      token: token,
    );
  }

  Future<void> logout() async {
    await _api.logout();
    await _api.deleteToken();
    // Sans cela, Google reconnecterait le même compte au clic suivant : on ne
    // pourrait plus jamais en changer depuis l'app.
    await _google.signOut();
  }

  Future<UserModel> getMe() async {
    final res = await _api.getMe();
    return UserModel.fromJson(res['user']);
  }

  Future<bool> isLoggedIn() async {
    final token = await _api.getToken();
    return token != null;
  }
}
