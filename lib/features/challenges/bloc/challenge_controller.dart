import 'package:arif_quiz/features/challenges/data/challenge_repository.dart';
import 'package:arif_quiz/shared/models/models.dart';
import 'package:flutter/foundation.dart';

class ChallengeController extends ChangeNotifier {
  final ChallengeRepository _repo;

  ChallengeController(this._repo);

  List<ChallengeModel> created = [];
  List<ChallengeModel> joined = [];

  /// Fils de découverte : des défis qu'on peut rejoindre sans code.
  List<ChallengeModel> friendsFeed = [];
  List<ChallengeModel> globalFeed = [];

  /// Vrai tant que rien n'a jamais été chargé. C'est la seule situation où
  /// l'écran n'a rien à montrer et doit donc afficher un squelette : un
  /// rafraîchissement garde les listes en place.
  bool get isFirstLoad =>
      created.isEmpty && joined.isEmpty && friendsFeed.isEmpty && globalFeed.isEmpty;
  ChallengeModel? currentChallenge;
  bool isLoading = false;
  bool isCreating = false;
  bool isJoining = false;
  String? error;

  /// [showSkeleton] : seul le tout premier chargement vide l'écran. Tirer pour
  /// rafraîchir laisse les listes en place pendant le rechargement.
  Future<void> loadMyChallenges({bool showSkeleton = true}) async {
    if (showSkeleton) isLoading = true;
    error = null;
    notifyListeners();
    try {
      final data = await _repo.getMyChallenges();
      created = data['created'] ?? [];
      joined = data['joined'] ?? [];
      friendsFeed = data['friends'] ?? [];
      globalFeed = data['global'] ?? [];
    } catch (e) {
      // Un échec de rafraîchissement n'efface pas ce qui est affiché.
      if (isFirstLoad) error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => loadMyChallenges(showSkeleton: false);

  Future<ChallengeModel?> createChallenge({
    required String sourceType,
    int? quizId,
    int? categoryId,
    required String mode,
    required String title,
    required int questionsCount,
    required String audience,
  }) async {
    isCreating = true;
    notifyListeners();
    try {
      final challenge = await _repo.createChallenge(
        sourceType: sourceType,
        quizId: quizId,
        categoryId: categoryId,
        mode: mode,
        title: title,
        questionsCount: questionsCount,
        audience: audience,
      );
      created.insert(0, challenge);
      notifyListeners();
      return challenge;
    } catch (e) {
      error = e.toString();
      return null;
    } finally {
      isCreating = false;
      notifyListeners();
    }
  }

  /// Sentinelle posée dans [error] quand une jonction échoue : l'écran la
  /// reconnaît et affiche le message traduit.
  static const joinFailed = '__join_failed__';

  Future<ChallengeModel?> joinChallenge(String code) async {
    isJoining = true;
    error = null;
    notifyListeners();
    try {
      final challenge = await _repo.joinChallenge(code);
      if (!joined.any((c) => c.id == challenge.id)) {
        joined.insert(0, challenge);
      }
      notifyListeners();
      return challenge;
    } catch (e) {
      // Le contrôleur ne parle aucune langue : il signale l'échec, l'écran le
      // traduit.
      error = joinFailed;
      return null;
    } finally {
      isJoining = false;
      notifyListeners();
    }
  }

  Future<ChallengeModel?> getChallengeByCode(String code) async {
    try {
      return await _repo.getChallengeByCode(code);
    } catch (_) {
      return null;
    }
  }

  Future<bool> deleteChallenge(int challengeId) async {
    try {
      await _repo.closeChallenge(challengeId);
      created.removeWhere((c) => c.id == challengeId);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }
}
