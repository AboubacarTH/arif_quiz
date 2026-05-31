import 'package:arif_quiz/core/api/api_service.dart';
import 'package:arif_quiz/shared/models/models.dart';

class FriendsRepository {
  final ApiService _api;

  FriendsRepository(this._api);

  Future<List<FriendModel>> getFriends() async {
    final res = await _api.get('/friends');
    return (res.data['data'] as List)
        .map((e) => FriendModel.fromJson(e))
        .toList();
  }

  Future<List<FriendRequest>> getRequests() async {
    final res = await _api.get('/friends/requests');
    return (res.data['data'] as List)
        .map((e) => FriendRequest.fromJson(e))
        .toList();
  }

  Future<List<UserSearchResult>> searchUsers(String query) async {
    final res = await _api.get('/friends/search', queryParameters: {'q': query});
    return (res.data['data'] as List)
        .map((e) => UserSearchResult.fromJson(e))
        .toList();
  }

  Future<void> sendRequest(int userId) async {
    await _api.post('/friends/request', data: {'user_id': userId});
  }

  Future<void> acceptRequest(int friendshipId) async {
    await _api.post('/friends/$friendshipId/accept');
  }

  Future<void> declineRequest(int friendshipId) async {
    await _api.post('/friends/$friendshipId/decline');
  }

  Future<void> removeFriend(int friendshipId) async {
    await _api.delete('/friends/$friendshipId');
  }

  Future<List<Map<String, dynamic>>> getFriendsLeaderboard() async {
    final res = await _api.get('/friends/leaderboard');
    return List<Map<String, dynamic>>.from(res.data['data']);
  }

  Future<List<FriendActivity>> getFriendsActivity() async {
    final res = await _api.get('/friends/activity');
    return (res.data['data'] as List)
        .map((e) => FriendActivity.fromJson(e))
        .toList();
  }
}
