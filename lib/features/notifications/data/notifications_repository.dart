import 'package:arif_quiz/core/api/api_service.dart';
import 'package:arif_quiz/shared/models/models.dart';

class NotificationsRepository {
  final ApiService _api;

  NotificationsRepository(this._api);

  Future<({List<AppNotification> items, int unreadCount, int lastPage})> getNotifications({int page = 1}) async {
    final res = await _api.get('/notifications', queryParameters: {'page': page});
    final data = res.data;
    return (
      items: (data['data'] as List).map((e) => AppNotification.fromJson(e)).toList(),
      unreadCount: (data['unread_count'] as num?)?.toInt() ?? 0,
      lastPage: (data['meta']?['last_page'] as num?)?.toInt() ?? 1,
    );
  }

  Future<void> markAsRead(String id) async {
    await _api.post('/notifications/$id/read');
  }

  Future<void> markAllAsRead() async {
    await _api.post('/notifications/read-all');
  }

  Future<void> updateFcmToken(String token) async {
    await _api.put('/profile/fcm-token', data: {'fcm_token': token});
  }
}
