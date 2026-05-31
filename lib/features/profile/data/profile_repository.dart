import 'package:arif_quiz/core/api/api_service.dart';
import 'package:arif_quiz/shared/models/models.dart';
import 'package:flutter/foundation.dart';

// ── Repository ────────────────────────────────────────────────
class ProfileRepository {
  final ApiService _api;
  ProfileRepository(this._api);

  Future<Map<String, dynamic>> getProfile() => _api.getProfile();

  Future<Map<String, dynamic>> getAttemptHistory({int page = 1}) =>
      _api.getAttemptHistory(page: page);

  Future<void> logout() => _api.logout();
}

// ── State ─────────────────────────────────────────────────────
abstract class ProfileState {}
class ProfileInitial extends ProfileState {}
class ProfileLoading extends ProfileState {}
class ProfileLoaded extends ProfileState {
  final UserModel user;
  final int rank;
  final List<dynamic> recentAttempts;
  ProfileLoaded({required this.user, required this.rank, required this.recentAttempts});
}
class ProfileError extends ProfileState {
  final String message;
  ProfileError(this.message);
}

// ── Controller ────────────────────────────────────────────────
class ProfileController extends ChangeNotifier {
  final ProfileRepository _repo;

  ProfileState _state = ProfileInitial();
  ProfileState get state => _state;

  bool get isLoading => _state is ProfileLoading;
  ProfileLoaded? get data => _state is ProfileLoaded ? _state as ProfileLoaded : null;
  String? get error => _state is ProfileError ? (_state as ProfileError).message : null;

  ProfileController(this._repo);

  Future<void> load() async {
    _emit(ProfileLoading());
    try {
      final res = await _repo.getProfile();
      _emit(ProfileLoaded(
        user: UserModel.fromJson(res['user']),
        rank: res['rank'] ?? 0,
        recentAttempts: res['recent_attempts'] ?? [],
      ));
    } catch (e) {
      _emit(ProfileError('Failed to load profile. ${e.toString()}'));
    }
  }

  Future<void> logout() => _repo.logout();

  void _emit(ProfileState s) { _state = s; notifyListeners(); }
}
