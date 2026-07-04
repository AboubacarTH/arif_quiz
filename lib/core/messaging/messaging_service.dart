import 'package:arif_quiz/core/api/api_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Handler des messages reçus en arrière-plan (doit être une fonction top-level).
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Le système Android affiche la notification `notification` automatiquement ;
  // rien de particulier à faire ici pour l'instant.
}

/// Intègre Firebase Cloud Messaging : initialisation, permission, réception,
/// et enregistrement du token FCM auprès du backend (PUT /profile/fcm-token).
class MessagingService {
  MessagingService(this._api);

  final ApiService _api;
  // ⚠️ Ne PAS initialiser ici : FirebaseMessaging.instance exige que
  // Firebase.initializeApp() ait déjà tourné. On le récupère dans initialize().
  FirebaseMessaging? _fcm;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    try {
      // Sur Android, les options sont lues depuis google-services.json via le
      // plugin Gradle. (iOS nécessiterait GoogleService-Info.plist en plus.)
      await Firebase.initializeApp();
      final fcm = FirebaseMessaging.instance;
      _fcm = fcm;
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      await fcm.requestPermission();
      fcm.onTokenRefresh.listen(_uploadToken);
      _initialized = true;
    } catch (e) {
      debugPrint('Messaging init error: $e');
    }
  }

  /// À appeler quand l'utilisateur est authentifié (après login / au démarrage
  /// si une session existe). N'envoie rien si l'utilisateur n'est pas connecté,
  /// pour ne pas déclencher un 401.
  Future<void> syncToken() async {
    try {
      await initialize();
      final fcm = _fcm;
      if (fcm == null) return; // Firebase indisponible : on n'enregistre rien.
      if (await _api.getToken() == null) return;
      final token = await fcm.getToken();
      if (token != null) await _uploadToken(token);
    } catch (e) {
      debugPrint('Messaging syncToken error: $e');
    }
  }

  Future<void> _uploadToken(String token) async {
    try {
      await _api.put('/profile/fcm-token', data: {'fcm_token': token});
    } catch (e) {
      debugPrint('FCM token upload failed: $e');
    }
  }
}
