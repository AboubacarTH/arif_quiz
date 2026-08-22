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

  /// Le premier chargement : l'écran n'a rien à montrer, le squelette a du sens.
  Future<void> load() => _fetch(showSkeleton: true);

  /// Un tirer-pour-rafraîchir : le profil reste à l'écran pendant l'appel.
  /// L'écran n'en avait aucun — il fallait sortir de l'onglet et y revenir pour
  /// voir ses points bouger après une partie.
  Future<void> refresh() => _fetch(showSkeleton: false);

  Future<void> _fetch({required bool showSkeleton}) async {
    if (showSkeleton) _emit(ProfileLoading());
    try {
      final res = await _repo.getProfile();
      _emit(ProfileLoaded(
        user: UserModel.fromJson(res['user']),
        rank: res['rank'] ?? 0,
        recentAttempts: res['recent_attempts'] ?? [],
      ));
    } catch (e) {
      // Un rafraîchissement qui échoue ne doit pas effacer ce qui est déjà là :
      // le réseau tombe, le profil affiché reste le dernier connu.
      if (data == null) {
        _emit(ProfileError('Failed to load profile. ${e.toString()}'));
      }
    }
  }

  Future<void> logout() => _repo.logout();

  void _emit(ProfileState s) { _state = s; notifyListeners(); }
}
