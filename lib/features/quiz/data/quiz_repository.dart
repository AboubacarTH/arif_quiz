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

  Future<({List<QuestionModel> questions, int timeLimit, int? sessionId})>
      getQuizQuestions(int id, {int? count}) async {
    final res = await _api.getQuizQuestions(id, count: count);
    return (
      questions: (res['questions'] as List).map((q) => QuestionModel.fromJson(q)).toList(),
      timeLimit: res['time_limit'] as int? ?? 30,
      sessionId: res['session_id'] as int?,
    );
  }

  Future<QuizAttemptResult> submitQuiz({
    required int quizId,
    required Map<String, String> answers,
    required int timeTaken,
    required List<int> questionIds,
    String mode = 'classic',
    int? sessionId,
    int jokersUsed = 0,
  }) async {
    final res = await _api.submitQuizWithMode(
      quizId: quizId,
      answers: answers,
      timeTaken: timeTaken,
      questionIds: questionIds,
      mode: mode,
      sessionId: sessionId,
      jokersUsed: jokersUsed,
    );
    return QuizAttemptResult.fromJson(res);
  }

  Future<List<dynamic>> getLeaderboard(int quizId) =>
      _api.getQuizLeaderboard(quizId);

  /// Signale une question (réponse incorrecte, ambiguë, etc.) aux admins.
  Future<String?> reportQuestion({
    required int questionId,
    required String reason,
    String? comment,
  }) async {
    final res = await _api.post('/question-reports', data: {
      'question_id': questionId,
      'reason': reason,
      if (comment != null && comment.trim().isNotEmpty) 'comment': comment.trim(),
    });
    // Le serveur renvoie un message deja traduit (il lit l'en-tete
    // Accept-Language). Un repli reste possible s'il n'en renvoie pas : il
    // appartient a l'ecran, pas a la couche de donnees, qui n'a pas a porter
    // du texte d'interface — et surtout pas dans une seule langue.
    return res.data is Map ? res.data['message'] as String? : null;
  }
}
