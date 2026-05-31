import 'package:arif_quiz/core/api/api_service.dart';
import 'package:arif_quiz/shared/models/models.dart';

class HomeRepository {
  final ApiService _api;
  HomeRepository(this._api);

  Future<List<CategoryModel>> getCategories() async {
    final data = await _api.getCategories();
    return data.map((c) => CategoryModel.fromJson(c)).toList();
  }

  Future<List<QuizModel>> getFeaturedQuizzes() async {
    final res = await _api.getFeaturedQuizzes();
    return (res['quizzes'] as List).map((q) => QuizModel.fromJson(q)).toList();
  }

  Future<UserModel> getMe() async {
    final res = await _api.getMe();

    // On cast la valeur de la clé 'user' avant de la passer au constructeur du modèle
    final userData = res['user'] as Map<String, dynamic>;
    return UserModel.fromJson(userData);
  }

}
