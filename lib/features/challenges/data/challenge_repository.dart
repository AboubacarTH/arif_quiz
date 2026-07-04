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
    required String sourceType,
    int? quizId,
    int? categoryId,
    required String mode,
    required String title,
  }) async {
    final res = await _api.post('/challenges', data: {
      'source_type': sourceType,
      if (quizId != null) 'quiz_id': quizId,
      if (categoryId != null) 'category_id': categoryId,
      'mode': mode,
      'title': title,
    });
    return ChallengeModel.fromJson(res.data['data']);
  }

  Future<({List<QuestionModel> questions, int timeLimit, int? sessionId})>
      getChallengeQuestions(int challengeId) async {
    final res = await _api.get('/challenges/$challengeId/questions');
    return (
      questions: (res.data['questions'] as List).map((q) => QuestionModel.fromJson(q)).toList(),
      timeLimit: res.data['time_limit'] as int? ?? 30,
      sessionId: res.data['session_id'] as int?,
    );
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
    required List<int> questionIds,
    int? sessionId,
  }) async {
    final res = await _api.post('/challenges/$challengeId/submit', data: {
      'answers': answers,
      'time_taken': timeTaken,
      'question_ids': questionIds,
      if (sessionId != null) 'session_id': sessionId,
    });
    final data = res.data['data'] as Map<String, dynamic>;
    return QuizAttemptResult.fromJson(data);
  }

  Future<Map<String, dynamic>> getChallengeLeaderboard(int challengeId) async {
    final res = await _api.get('/challenges/$challengeId/leaderboard');
    return Map<String, dynamic>.from(res.data['data']);
  }

  Future<void> closeChallenge(int challengeId) async {
    await _api.delete('/challenges/$challengeId');
  }

  /// Revanche 1-tap : recrée un défi identique et ré-invite les adversaires.
  Future<ChallengeModel> rematch(int challengeId) async {
    final res = await _api.post('/challenges/$challengeId/rematch');
    return ChallengeModel.fromJson(res.data['data']);
  }

  Future<void> inviteFriends(int challengeId, List<int> userIds) async {
    await _api.post('/challenges/$challengeId/invite', data: {'user_ids': userIds});
  }
}
