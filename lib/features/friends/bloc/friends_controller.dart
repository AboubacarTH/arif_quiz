import 'package:arif_quiz/features/friends/data/friends_repository.dart';
import 'package:arif_quiz/shared/models/models.dart';
import 'package:flutter/foundation.dart';

class FriendsController extends ChangeNotifier {
  final FriendsRepository _repo;

  FriendsController(this._repo);

  List<FriendModel> friends = [];
  List<FriendRequest> requests = [];
  List<FriendActivity> activity = [];
  List<UserSearchResult> searchResults = [];
  bool isLoading = false;
  bool isSearching = false;
  String? error;
  int pendingRequestsCount = 0;

  Future<void> loadFriends() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      friends = await _repo.getFriends();
      await loadRequests();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadRequests() async {
    try {
      requests = await _repo.getRequests();
      pendingRequestsCount = requests.length;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> loadActivity() async {
    try {
      activity = await _repo.getFriendsActivity();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> searchUsers(String query) async {
    if (query.length < 2) {
      searchResults = [];
      notifyListeners();
      return;
    }
    isSearching = true;
    notifyListeners();
    try {
      searchResults = await _repo.searchUsers(query);
    } catch (_) {
      searchResults = [];
    } finally {
      isSearching = false;
      notifyListeners();
    }
  }

  Future<bool> sendRequest(int userId) async {
    try {
      await _repo.sendRequest(userId);
      final idx = searchResults.indexWhere((u) => u.id == userId);
      if (idx != -1) {
        final u = searchResults[idx];
        searchResults[idx] = UserSearchResult(
          id: u.id, name: u.name, username: u.username, avatar: u.avatar,
          level: u.level, xp: u.xp, streak: u.streak, totalPoints: u.totalPoints,
          friendshipStatus: 'pending', friendshipId: null, isSender: true,
        );
        notifyListeners();
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> acceptRequest(int friendshipId) async {
    try {
      await _repo.acceptRequest(friendshipId);
      requests.removeWhere((r) => r.id == friendshipId);
      pendingRequestsCount = requests.length;
      await loadFriends();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> declineRequest(int friendshipId) async {
    try {
      await _repo.declineRequest(friendshipId);
      requests.removeWhere((r) => r.id == friendshipId);
      pendingRequestsCount = requests.length;
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> removeFriend(int friendshipId) async {
    try {
      await _repo.removeFriend(friendshipId);
      friends.removeWhere((f) => f.friendshipId == friendshipId);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }
}
