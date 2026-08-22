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

  /// Une liste vide ne veut pas dire la même chose avant et après la réponse
  /// du serveur. Sans ces deux témoins, les onglets Demandes et Activité
  /// affirmaient « aucune demande » et « pas d'activité » avant même d'avoir
  /// demandé — et le disaient encore si l'appel échouait.
  bool requestsLoaded = false;
  bool activityLoaded = false;

  /// Rien n'est encore arrivé : c'est le seul moment où un squelette a du sens.
  bool get isFirstLoad =>
      friends.isEmpty && requests.isEmpty && activity.isEmpty && !requestsLoaded;

  /// Le premier chargement de l'écran.
  Future<void> load() => _loadAll(showSkeleton: true);

  /// Un tirer-pour-rafraîchir : les listes restent à l'écran pendant l'appel.
  /// Il recharge les trois onglets, pas seulement celui qu'on regarde — c'est
  /// un même écran, et accepter une demande change aussi la liste d'amis.
  Future<void> refresh() => _loadAll(showSkeleton: false);

  Future<void> _loadAll({required bool showSkeleton}) async {
    if (showSkeleton) {
      isLoading = true;
      notifyListeners();
    }
    error = null;

    try {
      await Future.wait([
        _loadFriends(),
        loadRequests(),
        loadActivity(),
      ]);
    } catch (e) {
      if (isFirstLoad) error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadFriends() async {
    friends = await _repo.getFriends();
  }

  Future<void> loadRequests() async {
    try {
      requests = await _repo.getRequests();
      pendingRequestsCount = requests.length;
      requestsLoaded = true;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> loadActivity() async {
    try {
      activity = await _repo.getFriendsActivity();
      activityLoaded = true;
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
      notifyListeners();
      // La demande acceptée devient un ami : l'autre onglet a changé aussi.
      await refresh();
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
