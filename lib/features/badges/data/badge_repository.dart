import 'package:arif_quiz/core/api/api_service.dart';
import 'package:arif_quiz/shared/models/models.dart';

class BadgeRepository {
  final ApiService _api;
  BadgeRepository(this._api);

  Future<({List<BadgeModel> badges, int unlocked, int total})> getBadges() async {
    final res = await _api.get('/badges');
    final data = res.data;
    final badges = (data['badges'] as List)
        .map((b) => BadgeModel.fromJson(Map<String, dynamic>.from(b)))
        .toList();
    return (
      badges: badges,
      unlocked: data['unlocked_count'] as int? ?? 0,
      total: data['total_count'] as int? ?? badges.length,
    );
  }
}
