import 'package:arif_quiz/core/api/api_service.dart';
import 'package:arif_quiz/shared/models/models.dart';

class JourneyRepository {
  final ApiService _api;
  JourneyRepository(this._api);

  /// Récupère la map complète (niveaux + progression + déblocage).
  Future<JourneyMapModel> getMap() async {
    final res = await _api.getJourney();
    return JourneyMapModel.fromJson(res);
  }

  /// Démarre un niveau : renvoie les questions figées + la session serveur.
  Future<({List<QuestionModel> questions, int timeLimit, int? sessionId, bool isBoss})>
      startLevel(int level) async {
    final res = await _api.startJourneyLevel(level);
    return (
      questions: (res['questions'] as List)
          .map((q) => QuestionModel.fromJson(Map<String, dynamic>.from(q)))
          .toList(),
      timeLimit: res['time_limit'] as int? ?? 30,
      sessionId: res['session_id'] as int?,
      isBoss: res['is_boss'] as bool? ?? false,
    );
  }

  /// Soumet les réponses d'un niveau et renvoie le résultat (étoiles, déblocage).
  Future<JourneyLevelResult> submitLevel({
    required int level,
    required Map<String, String> answers,
    required int timeTaken,
    required int sessionId,
  }) async {
    final res = await _api.submitJourneyLevel(
      level: level,
      answers: answers,
      timeTaken: timeTaken,
      sessionId: sessionId,
    );
    return JourneyLevelResult.fromJson(res);
  }
}
