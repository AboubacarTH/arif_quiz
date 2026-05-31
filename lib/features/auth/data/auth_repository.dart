import 'package:arif_quiz/core/api/api_service.dart';
import 'package:arif_quiz/shared/models/models.dart';

class AuthRepository {
  final ApiService _api;
  AuthRepository(this._api);

  Future<({UserModel user, String token})> login(
      String email, String password) async {
    final res = await _api.login(email, password);
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

  Future<void> logout() async {
    await _api.logout();
    await _api.deleteToken();
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
