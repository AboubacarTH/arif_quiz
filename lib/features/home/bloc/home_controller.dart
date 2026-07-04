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
  HomeLoaded({
    this.user,
    required this.categories,
    required this.featured,
    this.friendsLeaderboard = const [],
  });
}
class HomeError extends HomeState {
  final String message;
  HomeError(this.message);
}

class HomeController extends ChangeNotifier {
  final HomeRepository _repo;

  HomeState _state = HomeInitial();
  HomeState get state => _state;

  bool get isLoading => _state is HomeLoading;
  HomeLoaded? get data => _state is HomeLoaded ? _state as HomeLoaded : null;
  String? get error   => _state is HomeError ? (_state as HomeError).message : null;

  HomeController(this._repo);

  Future<void> load() async {
    _emit(HomeLoading());
    try {
      final results = await Future.wait([
        _repo.getCategories(),
        _repo.getFeaturedQuizzes(),
        _repo.getMe(),
      ]);
      // Classement amis : optionnel — ne doit pas casser le chargement du Home.
      List<Map<String, dynamic>> friendsLb = const [];
      try {
        friendsLb = await _repo.getFriendsLeaderboard();
      } catch (_) {}
      _emit(HomeLoaded(
        user:       results[2] as UserModel,
        categories: results[0] as List<CategoryModel>,
        featured:   results[1] as List<QuizModel>,
        friendsLeaderboard: friendsLb,
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
