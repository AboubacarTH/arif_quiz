import 'package:arif_quiz/core/api/api_service.dart';
import 'package:arif_quiz/shared/models/models.dart';

class QuizRepository {
  final ApiService _api;
  QuizRepository(this._api);

  Future<({List<QuizModel> quizzes, int lastPage, int total})> getQuizzes({
    int? categoryId,
    String? difficulty,
    String? search,
    int page = 1,
  }) async {
    final res = await _api.getQuizzes(
      categoryId: categoryId,
      difficulty: difficulty,
      search: search,
      page: page,
    );
    return (
      quizzes: (res['quizzes'] as List).map((q) => QuizModel.fromJson(q)).toList(),
      lastPage: res['meta']?['last_page'] as int? ?? 1,
      total: res['meta']?['total'] as int? ?? 0,
    );
    
  }

  Future<QuizModel> getQuiz(int id) async {
    final res = await _api.getQuiz(id);
    return QuizModel.fromJson(res['quiz']);
  }

  Future<({List<QuestionModel> questions, int timeLimit})> getQuizQuestions(int id) async {
    final res = await _api.getQuizQuestions(id);
    return (
      questions: (res['questions'] as List).map((q) => QuestionModel.fromJson(q)).toList(),
      timeLimit: res['time_limit'] as int? ?? 30,
    );
  }

  Future<QuizAttemptResult> submitQuiz({
    required int quizId,
    required Map<String, String> answers,
    required int timeTaken,
    String mode = 'classic',
  }) async {
    final res = await _api.submitQuizWithMode(
      quizId: quizId,
      answers: answers,
      timeTaken: timeTaken,
      mode: mode,
    );
    return QuizAttemptResult.fromJson(res);
  }

  Future<List<dynamic>> getLeaderboard(int quizId) =>
      _api.getQuizLeaderboard(quizId);
}
