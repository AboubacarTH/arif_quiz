import 'package:arif_quiz/features/daily_challenge/data/daily_challenge_repository.dart';
import 'package:arif_quiz/features/home/data/home_repository.dart';
import 'package:arif_quiz/shared/models/models.dart';
import 'package:flutter/foundation.dart';

/// Ce que l'accueil sait du défi du jour.
///
/// Distinguer « il n'y a pas de défi » de « je n'ai pas pu le savoir » n'est
/// pas un détail : la requête est optionnelle et peut échouer, et une carte qui
/// annonce « Pas de défi aujourd'hui » sur un simple timeout ment au joueur.
class DailyStatus {
  /// Null = la journée n'a pas de défi programmé.
  final DailyChallengeModel? challenge;

  const DailyStatus(this.challenge);
}

abstract class HomeState {}
class HomeInitial    extends HomeState {}
class HomeLoading    extends HomeState {}
class HomeLoaded     extends HomeState {
  final UserModel? user;
  final List<CategoryModel> categories;
  final List<QuizModel> featured;
  final List<Map<String, dynamic>> friendsLeaderboard;

  /// Null = la requête n'a pas abouti, on ne sait rien. L'accueil se tait
  /// alors, plutôt que d'affirmer quoi que ce soit.
  final DailyStatus? daily;

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
    // Un RAFRAICHISSEMENT ne vide pas l'écran : le contenu déjà affiché reste
    // en place pendant que les données se rechargent, et l'indicateur de
    // rafraîchissement suffit à dire qu'il se passe quelque chose. Le squelette
    // n'a de sens qu'au tout premier chargement, quand il n'y a rien à montrer.
    if (data == null) _emit(HomeLoading());
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

      DailyStatus? daily;
      try {
        daily = DailyStatus(await _daily.getToday());
      } catch (_) {
        // On laisse `null` : l'accueil masquera la carte au lieu d'affirmer
        // qu'il n'y a pas de défi.
      }

      _emit(HomeLoaded(
        user:       results[2] as UserModel,
        categories: results[0] as List<CategoryModel>,
        featured:   results[1] as List<QuizModel>,
        friendsLeaderboard: friendsLb,
        daily: daily,
      ));
    } catch (_) {
      // Un échec de rafraîchissement ne doit pas effacer une page qui marche.
      if (data == null) _emit(HomeError('Failed to load. Pull to refresh.'));
    }
  }

  Future<void> loadGuest() async {
    if (data == null) _emit(HomeLoading());
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
