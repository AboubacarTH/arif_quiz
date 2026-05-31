import 'package:arif_quiz/core/api/api_service.dart';
import 'package:flutter/foundation.dart';

// ── Repository ────────────────────────────────────────────────
class LeaderboardRepository {
  final ApiService _api;
  LeaderboardRepository(this._api);

  Future<List<Map<String, dynamic>>> getGlobal() async {
    final data = await _api.getGlobalLeaderboard();
    return data.cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> getForQuiz(int quizId) async {
    final data = await _api.getQuizLeaderboard(quizId);
    return data.cast<Map<String, dynamic>>();
  }
}

// ── State ─────────────────────────────────────────────────────
abstract class LeaderboardState {}
class LeaderboardInitial extends LeaderboardState {}
class LeaderboardLoading extends LeaderboardState {}
class LeaderboardLoaded extends LeaderboardState {
  final List<Map<String, dynamic>> entries;
  LeaderboardLoaded(this.entries);
}
class LeaderboardError extends LeaderboardState {
  final String message;
  LeaderboardError(this.message);
}

// ── Controller ────────────────────────────────────────────────
class LeaderboardController extends ChangeNotifier {
  final LeaderboardRepository _repo;

  LeaderboardState _state = LeaderboardInitial();
  LeaderboardState get state => _state;

  bool get isLoading => _state is LeaderboardLoading;
  List<Map<String, dynamic>> get entries =>
      _state is LeaderboardLoaded ? (_state as LeaderboardLoaded).entries : [];
  String? get error =>
      _state is LeaderboardError ? (_state as LeaderboardError).message : null;

  LeaderboardController(this._repo);

  Future<void> load() async {
    _emit(LeaderboardLoading());
    try {
      final data = await _repo.getGlobal();
      _emit(LeaderboardLoaded(data));
    } catch (_) {
      _emit(LeaderboardError('Failed to load leaderboard.'));
    }
  }

  void _emit(LeaderboardState s) { _state = s; notifyListeners(); }
}
