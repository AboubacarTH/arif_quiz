import 'package:arif_quiz/features/daily_challenge/data/daily_challenge_repository.dart';
import 'package:arif_quiz/features/home/data/home_repository.dart';
import 'package:arif_quiz/shared/models/models.dart';
import 'package:flutter/foundation.dart';

abstract class HomeState {}
class HomeInitial    extends HomeState {}
class HomeLoading    extends HomeState {}
class HomeLoaded     extends HomeState {
  final UserModel? user;
  final List<CategoryModel> categories;
  final List<QuizModel> featured;
  final List<Map<String, dynamic>> friendsLeaderboard;

  /// Null = aucun défi programmé aujourd'hui. L'accueil doit alors le dire,
  /// pas afficher une carte qui mène à un écran vide.
  final DailyChallengeModel? daily;

  HomeLoaded({
    this.user,
    required this.categories,
    required this.featured,
    this.friendsLeaderboard = const [],
    this.daily,
  });
}
class HomeError extends HomeState {
  final String message;
  HomeError(this.message);
}

class HomeController extends ChangeNotifier {
  final HomeRepository _repo;
  final DailyChallengeRepository _daily;

  HomeState _state = HomeInitial();
  HomeState get state => _state;

  bool get isLoading => _state is HomeLoading;
  HomeLoaded? get data => _state is HomeLoaded ? _state as HomeLoaded : null;
  String? get error   => _state is HomeError ? (_state as HomeError).message : null;

  HomeController(this._repo, this._daily);

  Future<void> load() async {
    _emit(HomeLoading());
    try {
      final results = await Future.wait([
        _repo.getCategories(),
        _repo.getFeaturedQuizzes(),
        _repo.getMe(),
      ]);
      // Classement amis et défi du jour : optionnels — aucun des deux ne doit
      // casser le chargement de l'accueil s'il échoue.
      List<Map<String, dynamic>> friendsLb = const [];
      try {
        friendsLb = await _repo.getFriendsLeaderboard();
      } catch (_) {}

      DailyChallengeModel? daily;
      try {
        daily = await _daily.getToday();
      } catch (_) {}

      _emit(HomeLoaded(
        user:       results[2] as UserModel,
        categories: results[0] as List<CategoryModel>,
        featured:   results[1] as List<QuizModel>,
        friendsLeaderboard: friendsLb,
        daily: daily,
      ));
    } catch (_) {
      _emit(HomeError('Failed to load. Pull to refresh.'));
    }
  }

  Future<void> loadGuest() async {
    _emit(HomeLoading());
    try {
      final results = await Future.wait([
        _repo.getCategories(),
        _repo.getFeaturedQuizzes(),
      ]);
      _emit(HomeLoaded(
        user:       null,
        categories: results[0] as List<CategoryModel>,
        featured:   results[1] as List<QuizModel>,
      ));
    } catch (_) {
      _emit(HomeError('Failed to load. Pull to refresh.'));
    }
  }

  void _emit(HomeState s) { _state = s; notifyListeners(); }
}
