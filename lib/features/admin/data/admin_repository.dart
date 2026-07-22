import 'dart:io';

import 'package:arif_quiz/core/api/api_service.dart';
import 'package:arif_quiz/shared/models/models.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class AdminRepository {
  final ApiService _api;
  AdminRepository(this._api);

  // ── Stats ─────────────────────────────────────────────────────────────────

  Future<AdminStatsModel> getStats() async {
    final res = await _api.get('/admin/stats');
    return AdminStatsModel.fromJson(res.data['data']);
  }

  // ── Categories ────────────────────────────────────────────────────────────

  Future<List<AdminCategoryModel>> getCategories({String? search}) async {
    final res = await _api.get('/admin/categories', queryParameters: {
      if (search != null && search.isNotEmpty) 'search': search,
    });
    final list = res.data['data'] as List;
    return list.map((e) => AdminCategoryModel.fromJson(e)).toList();
  }

  Future<AdminCategoryModel> createCategory(Map<String, dynamic> data) async {
    final res = await _api.post('/admin/categories', data: data);
    return AdminCategoryModel.fromJson(res.data['data']);
  }

  Future<AdminCategoryModel> updateCategory(int id, Map<String, dynamic> data) async {
    final res = await _api.put('/admin/categories/$id', data: data);
    return AdminCategoryModel.fromJson(res.data['data']);
  }

  Future<void> deleteCategory(int id) async {
    await _api.delete('/admin/categories/$id');
  }

  // ── Quizzes ───────────────────────────────────────────────────────────────

  Future<({List<AdminQuizModel> quizzes, int lastPage, int total})> getQuizzes({
    String? search,
    int? categoryId,
    String? difficulty,
    String? status,
    int page = 1,
  }) async {
    final res = await _api.get('/admin/quizzes', queryParameters: {
      if (search != null && search.isNotEmpty) 'search': search,
      if (categoryId != null) 'category_id': categoryId,
      if (difficulty != null) 'difficulty': difficulty,
      if (status != null) 'status': status,
      'page': page,
    });
    final list = res.data['data'] as List;
    final meta = res.data['meta'] as Map<String, dynamic>? ?? {};
    return (
      quizzes: list.map((e) => AdminQuizModel.fromJson(e)).toList(),
      lastPage: meta['last_page'] as int? ?? 1,
      total: meta['total'] as int? ?? 0,
    );
  }

  Future<AdminQuizModel> createQuiz(Map<String, dynamic> data) async {
    final res = await _api.post('/admin/quizzes', data: data);
    return AdminQuizModel.fromJson(res.data['data']);
  }

  Future<AdminQuizModel> updateQuiz(int id, Map<String, dynamic> data) async {
    final res = await _api.put('/admin/quizzes/$id', data: data);
    return AdminQuizModel.fromJson(res.data['data']);
  }

  Future<bool> toggleQuiz(int id) async {
    final res = await _api.patch('/admin/quizzes/$id/toggle');
    return res.data['data']['is_published'] as bool;
  }

  Future<void> deleteQuiz(int id) async {
    await _api.delete('/admin/quizzes/$id');
  }

  /// Téléverse un média de question (type: 'image' | 'audio') et renvoie son URL.
  Future<String> uploadMedia({
    required String type,
    required String filePath,
    required String fileName,
  }) async {
    final formData = FormData.fromMap({
      'type': type,
      'file': await MultipartFile.fromFile(filePath, filename: fileName),
    });
    final res = await _api.post('/admin/media', data: formData);
    return res.data['url'] as String;
  }

  /// Recherche d'utilisateurs pour l'assignation des quiz restreints.
  Future<List<({int id, String name, String? username})>> searchUsers(
      String search) async {
    final res = await _api.get('/admin/users', queryParameters: {
      if (search.isNotEmpty) 'search': search,
    });
    final list = res.data['data'] as List;
    return list
        .map((e) => (
              id: e['id'] as int,
              name: (e['name'] ?? '') as String,
              username: e['username'] as String?,
            ))
        .toList();
  }

  // ── Mode Parcours : niveaux ───────────────────────────────────────────────

  Future<List<AdminJourneyLevelModel>> getJourneyLevels() async {
    final res = await _api.get('/admin/journey-levels');
    return (res.data['data'] as List)
        .map((e) => AdminJourneyLevelModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<AdminJourneyLevelModel> createJourneyLevel(
      Map<String, dynamic> data) async {
    final res = await _api.post('/admin/journey-levels', data: data);
    return AdminJourneyLevelModel.fromJson(res.data['data']);
  }

  Future<AdminJourneyLevelModel> updateJourneyLevel(
      int id, Map<String, dynamic> data) async {
    final res = await _api.put('/admin/journey-levels/$id', data: data);
    return AdminJourneyLevelModel.fromJson(res.data['data']);
  }

  Future<void> deleteJourneyLevel(int id) async {
    await _api.delete('/admin/journey-levels/$id');
  }

  /// Réordonne toute la map : la liste d'ids devient les positions 1..N.
  Future<List<AdminJourneyLevelModel>> reorderJourneyLevels(
      List<int> ids) async {
    final res =
        await _api.post('/admin/journey-levels/reorder', data: {'ids': ids});
    return (res.data['data'] as List)
        .map((e) => AdminJourneyLevelModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  // ── Questions ─────────────────────────────────────────────────────────────

  Future<({List<AdminQuestionModel> questions, int lastPage, int total})> getQuestions({
    String? search,
    int? quizId,
    int? journeyLevelId,
    String? type,
    int page = 1,
  }) async {
    final res = await _api.get('/admin/questions', queryParameters: {
      if (search != null && search.isNotEmpty) 'search': search,
      if (quizId != null) 'quiz_id': quizId,
      if (journeyLevelId != null) 'journey_level_id': journeyLevelId,
      if (type != null) 'type': type,
      'page': page,
    });
    final list = res.data['data'] as List;
    final meta = res.data['meta'] as Map<String, dynamic>? ?? {};
    return (
      questions: list.map((e) => AdminQuestionModel.fromJson(e)).toList(),
      lastPage: meta['last_page'] as int? ?? 1,
      total: meta['total'] as int? ?? 0,
    );
  }

  Future<AdminQuestionModel> createQuestion(Map<String, dynamic> data) async {
    final res = await _api.post('/admin/questions', data: data);
    return AdminQuestionModel.fromJson(res.data['data']);
  }

  Future<AdminQuestionModel> updateQuestion(int id, Map<String, dynamic> data) async {
    final res = await _api.put('/admin/questions/$id', data: data);
    return AdminQuestionModel.fromJson(res.data['data']);
  }

  Future<void> deleteQuestion(int id) async {
    await _api.delete('/admin/questions/$id');
  }

  // ── Signalements ──────────────────────────────────────────────────────────

  Future<({List<AdminReportModel> reports, int lastPage, int total})> getReports({
    String? status,
    int page = 1,
  }) async {
    final res = await _api.get('/admin/reports', queryParameters: {
      if (status != null && status.isNotEmpty) 'status': status,
      'page': page,
    });
    final list = res.data['data'] as List;
    final meta = res.data['meta'] as Map<String, dynamic>? ?? {};
    return (
      reports: list.map((e) => AdminReportModel.fromJson(e)).toList(),
      lastPage: meta['last_page'] as int? ?? 1,
      total: meta['total'] as int? ?? 0,
    );
  }

  Future<AdminReportModel> updateReportStatus(int id, String status) async {
    final res = await _api.put('/admin/reports/$id', data: {'status': status});
    return AdminReportModel.fromJson(res.data['data']);
  }

  Future<void> deleteReport(int id) async {
    await _api.delete('/admin/reports/$id');
  }

  // ── Export ────────────────────────────────────────────────────────────────

  /// Exporte les questions d'un quiz au format du modèle d'import : le fichier
  /// obtenu est directement réimportable.
  ///
  /// Renvoie le fichier écrit dans le dossier temporaire, prêt à être partagé.
  Future<File> exportQuizQuestions({
    required int quizId,
    required String quizTitle,
    String locale = 'en',
  }) =>
      _downloadExport(
        '/admin/quizzes/$quizId/export-questions',
        quizTitle,
        locale,
      );

  /// Idem pour les questions d'un niveau du Mode Parcours.
  Future<File> exportJourneyLevelQuestions({
    required int levelId,
    required String levelTitle,
    String locale = 'en',
  }) =>
      _downloadExport(
        '/admin/journey-levels/$levelId/export-questions',
        levelTitle,
        locale,
      );

  Future<File> _downloadExport(String path, String title, String locale) async {
    final bytes = await _api.download(path, queryParameters: {'locale': locale});
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/${_exportFileName(title, locale)}');

    return file.writeAsBytes(bytes, flush: true);
  }

  /// Nom de fichier sûr, aligné sur celui produit par le serveur.
  String _exportFileName(String title, String locale) {
    final slug = title
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');

    return '${slug.isEmpty ? 'quiz' : slug}-questions-$locale.xlsx';
  }

  // ── Import ────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> importExcel({
    required int categoryId,
    required String title,
    String? description,
    required String difficulty,
    required int timeLimit,
    required int pointsPerQuestion,
    required bool isPublished,
    required String filePath,
    required String fileName,
  }) async {
    final formData = FormData.fromMap({
      'category_id': categoryId,
      'title': title,
      if (description != null && description.isNotEmpty) 'description': description,
      'difficulty': difficulty,
      'time_limit': timeLimit,
      'points_per_question': pointsPerQuestion,
      'is_published': isPublished ? '1' : '0',
      'file': await MultipartFile.fromFile(filePath, filename: fileName),
    });
    final res = await _api.post('/admin/import', data: formData);
    return Map<String, dynamic>.from(res.data);
  }

  /// Import en masse de questions dans un quiz existant.
  /// [locale] = 'en' (défaut) : nouvelles questions ajoutées à la suite ;
  /// autre langue : lignes = traductions des questions existantes (match par order).
  Future<Map<String, dynamic>> importQuestionsToQuiz({
    required int quizId,
    required String filePath,
    required String fileName,
    String locale = 'en',
  }) async {
    final formData = FormData.fromMap({
      'locale': locale,
      'file': await MultipartFile.fromFile(filePath, filename: fileName),
    });
    final res =
        await _api.post('/admin/quizzes/$quizId/import-questions', data: formData);
    return Map<String, dynamic>.from(res.data);
  }
}
