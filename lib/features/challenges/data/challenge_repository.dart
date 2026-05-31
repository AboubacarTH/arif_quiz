import 'package:arif_quiz/core/api/api_service.dart';
import 'package:arif_quiz/shared/models/models.dart';

class ChallengeRepository {
  final ApiService _api;

  ChallengeRepository(this._api);

  Future<Map<String, List<ChallengeModel>>> getMyChallenges() async {
    final res = await _api.get('/challenges');
    final data = res.data['data'];
    return {
      'created': (data['created'] as List).map((e) => ChallengeModel.fromJson(e)).toList(),
      'joined': (data['joined'] as List).map((e) => ChallengeModel.fromJson(e)).toList(),
    };
  }

  Future<ChallengeModel> createChallenge({
    required int quizId,
    required String mode,
    required String title,
  }) async {
    final res = await _api.post('/challenges', data: {
      'quiz_id': quizId,
      'mode': mode,
      'title': title,
    });
    return ChallengeModel.fromJson(res.data['data']);
  }

  Future<ChallengeModel> getChallengeByCode(String code) async {
    final res = await _api.get('/challenges/$code');
    return ChallengeModel.fromJson(res.data['data']);
  }

  Future<ChallengeModel> joinChallenge(String code) async {
    final res = await _api.post('/challenges/join', data: {'code': code.toUpperCase()});
    return ChallengeModel.fromJson(res.data['data']);
  }

  Future<QuizAttemptResult> submitChallenge({
    required int challengeId,
    required Map<String, String> answers,
    required int timeTaken,
  }) async {
    final res = await _api.post('/challenges/$challengeId/submit', data: {
      'answers': answers,
      'time_taken': timeTaken,
    });
    return QuizAttemptResult.fromJson(res.data['data']);
  }

  Future<Map<String, dynamic>> getChallengeLeaderboard(int challengeId) async {
    final res = await _api.get('/challenges/$challengeId/leaderboard');
    return Map<String, dynamic>.from(res.data['data']);
  }

  Future<void> closeChallenge(int challengeId) async {
    await _api.delete('/challenges/$challengeId');
  }

  Future<void> inviteFriends(int challengeId, List<int> userIds) async {
    await _api.post('/challenges/$challengeId/invite', data: {'user_ids': userIds});
  }
}
