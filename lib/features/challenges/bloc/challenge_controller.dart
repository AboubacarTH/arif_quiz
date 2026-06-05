import 'package:arif_quiz/features/challenges/data/challenge_repository.dart';
import 'package:arif_quiz/shared/models/models.dart';
import 'package:flutter/foundation.dart';

class ChallengeController extends ChangeNotifier {
  final ChallengeRepository _repo;

  ChallengeController(this._repo);

  List<ChallengeModel> created = [];
  List<ChallengeModel> joined = [];
  ChallengeModel? currentChallenge;
  bool isLoading = false;
  bool isCreating = false;
  bool isJoining = false;
  String? error;

  Future<void> loadMyChallenges() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final data = await _repo.getMyChallenges();
      created = data['created'] ?? [];
      joined = data['joined'] ?? [];
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<ChallengeModel?> createChallenge({
    required String sourceType,
    int? quizId,
    int? categoryId,
    required String mode,
    required String title,
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
      error = 'Code invalide ou défi introuvable';
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
