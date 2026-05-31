import 'package:arif_quiz/core/api/api_service.dart';
import 'package:arif_quiz/shared/models/models.dart';

class DailyChallengeRepository {
  final ApiService _api;

  DailyChallengeRepository(this._api);

  Future<DailyChallengeModel?> getToday() async {
    final res = await _api.get('/daily-challenge');
    if (res.data['data'] == null) return null;
    return DailyChallengeModel.fromJson(res.data['data']);
  }

  Future<QuizAttemptResult> submit({
    required Map<String, String> answers,
    required int timeTaken,
  }) async {
    final res = await _api.post('/daily-challenge/submit', data: {
      'answers': answers,
      'time_taken': timeTaken,
    });
    return QuizAttemptResult.fromJson(res.data['data']);
  }
}
