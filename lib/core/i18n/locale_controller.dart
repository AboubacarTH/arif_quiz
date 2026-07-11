import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Langue de l'application (UI + contenu servi par l'API).
/// Défaut : langue de l'appareil si supportée, sinon anglais.
/// Persistée localement ; synchronisée avec le profil via [onChanged]
/// (câblé dans main.dart pour éviter les dépendances circulaires).
class LocaleController extends ChangeNotifier {
  static const _key = 'app_locale';
  static const supportedCodes = ['en', 'fr', 'ar', 'es'];
  static const supportedLocales = [
    Locale('en'),
    Locale('fr'),
    Locale('ar'),
    Locale('es'),
  ];

  /// Libellés natifs pour le sélecteur de langue.
  static const labels = {
    'en': 'English',
    'fr': 'Français',
    'ar': 'العربية',
    'es': 'Español',
  };

  String _code = _deviceDefault();
  String get code => _code;
  Locale get locale => Locale(_code);

  /// Callback appelé à chaque changement (ex : header API + sync profil).
  void Function(String code)? onChanged;

  LocaleController() {
    _load();
  }

  static String _deviceDefault() {
    final device = ui.PlatformDispatcher.instance.locale.languageCode;
    return supportedCodes.contains(device) ? device : 'en';
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_key);
    if (saved != null && supportedCodes.contains(saved) && saved != _code) {
      _code = saved;
      notifyListeners();
    }
    onChanged?.call(_code);
  }

  Future<void> setLocale(String code) async {
    if (!supportedCodes.contains(code) || code == _code) return;
    _code = code;
    notifyListeners();
    onChanged?.call(code);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, code);
  }
}
