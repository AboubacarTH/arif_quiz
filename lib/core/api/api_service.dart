import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const String productionUrl = 'https://arif-quiz.admindigitalyser.com/api/v1';
  static const String localUrl = 'http://10.44.13.211:8000/api/v1';
  static const String baseUrl = productionUrl;
  static const _storage = FlutterSecureStorage();

  late final Dio _dio;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        handler.next(error);
      },
    ));
  }

  Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: 'auth_token');
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }


  // ==================== AUTH ====================
  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    return res.data;
  }

  Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    final res = await _dio.post('/auth/register', data: {
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': password,
    });
    return res.data;
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    final res = await _dio.post('/auth/forgot-password', data: {
      'email': email,
    });
    return _asMap(res.data);
  }

  Future<Map<String, dynamic>> verifyEmail({
    required String email,
    required String code,
  }) async {
    final res = await _dio.post('/auth/email/verify', data: {
      'email': email,
      'code': code,
    });
    return _asMap(res.data);
  }

  Future<Map<String, dynamic>> resendEmailVerification({
    required String email,
  }) async {
    final res = await _dio.post('/auth/email/resend', data: {
      'email': email,
    });
    return _asMap(res.data);
  }

  Future<void> logout() async {
    await _dio.post('/auth/logout');
    await _storage.delete(key: 'auth_token');
  }

  Future<Map<String, dynamic>> getMe() async {
    try {
      final res = await _dio.get('/auth/me');
      return Map<String, dynamic>.from(res.data);
    } on DioException catch (_) {
      rethrow;
    }
  }

  // ==================== CATEGORIES ====================
  Future<List<dynamic>> getCategories() async {
    final res = await _dio.get('/categories');
    return res.data['categories'];
  }

  // ==================== QUIZZES ====================
  Future<Map<String, dynamic>> getQuizzes({
    int? categoryId,
    String? difficulty,
    String? search,
    int page = 1,
  }) async {
    final res = await _dio.get('/quizzes', queryParameters: {
      if (categoryId != null) 'category_id': categoryId,
      if (difficulty != null) 'difficulty': difficulty,
      if (search != null) 'search': search,
      'page': page,
    });
    return res.data;
  }

  Future<Map<String, dynamic>> getFeaturedQuizzes() async {
    final res = await _dio.get('/quizzes/featured');
    return res.data;
  }

  Future<Map<String, dynamic>> getQuiz(int id) async {
    final res = await _dio.get('/quizzes/$id');
    return res.data;
  }

  Future<Map<String, dynamic>> getQuizQuestions(int quizId) async {
    final res = await _dio.get('/quizzes/$quizId/questions');
    return res.data;
  }

  // ==================== ATTEMPTS ====================
  Future<Map<String, dynamic>> submitQuiz({
    required int quizId,
    required Map<String, String> answers,
    required int timeTaken,
  }) async {
    final res = await _dio.post('/quizzes/$quizId/submit', data: {
      'answers': answers,
      'time_taken': timeTaken,
    });
    return res.data;
  }

  Future<Map<String, dynamic>> getAttemptHistory({int page = 1}) async {
    final res = await _dio.get('/attempts', queryParameters: {'page': page});
    return res.data;
  }

  Future<List<dynamic>> getQuizLeaderboard(int quizId) async {
    final res = await _dio.get('/quizzes/$quizId/leaderboard');
    return res.data['leaderboard'];
  }

  // ==================== PROFILE ====================
  Future<Map<String, dynamic>> getProfile() async {
    final res = await _dio.get('/profile');
    return res.data;
  }

  Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String email,
  }) async {
    final res = await _dio.put('/profile', data: {
      'name': name,
      'email': email,
    });
    return _asMap(res.data);
  }

  Future<List<dynamic>> getGlobalLeaderboard() async {
    final res = await _dio.get('/leaderboard');
    return res.data['leaderboard'];
  }

  // ==================== GENERIC HTTP ====================
  Future<Response<dynamic>> get(String path, {Map<String, dynamic>? queryParameters}) async {
    return _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response<dynamic>> post(String path, {dynamic data}) async {
    return _dio.post(path, data: data);
  }

  Future<Response<dynamic>> put(String path, {dynamic data}) async {
    return _dio.put(path, data: data);
  }

  Future<Response<dynamic>> delete(String path) async {
    return _dio.delete(path);
  }

  // ==================== FRIENDS ====================
  Future<Map<String, dynamic>> submitQuizWithMode({
    required int quizId,
    required Map<String, String> answers,
    required int timeTaken,
    String mode = 'classic',
  }) async {
    final res = await _dio.post('/quizzes/$quizId/submit', data: {
      'answers': answers,
      'time_taken': timeTaken,
      'mode': mode,
    });
    return res.data;
  }

  Future<Map<String, dynamic>> getProfileStats() async {
    final res = await _dio.get('/profile/stats');
    return res.data;
  }

  Future<void> updateUsername(String username) async {
    await _dio.put('/profile/username', data: {'username': username});
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return {'data': data};
  }
}
