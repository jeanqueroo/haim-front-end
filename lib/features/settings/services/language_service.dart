import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService extends ChangeNotifier {
  static const String _languageKey = 'selected_language';
  
  Locale _currentLocale = const Locale('en', 'US'); // Inglés por defecto
  
  Locale get currentLocale => _currentLocale;
  
  // Idiomas disponibles
  final List<Map<String, String>> availableLanguages = [
    {'code': 'en', 'name': 'English', 'flag': '🇺🇸'},
    {'code': 'es', 'name': 'Español', 'flag': '🇪🇸'},
  ];

  LanguageService() {
    _loadLanguage();
  }

  /// Carga el idioma guardado desde SharedPreferences
  Future<void> _loadLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_languageKey);
      
      if (languageCode != null) {
        _currentLocale = Locale(languageCode);
        notifyListeners();
      }
    } catch (e) {
      // Si hay error, mantener el idioma por defecto
      debugPrint('Error loading language: $e');
    }
  }

  /// Cambia el idioma de la aplicación
  Future<void> changeLanguage(Locale locale) async {
    if (_currentLocale == locale) return;
    
    _currentLocale = locale;
    notifyListeners();
    
    // Guardar la preferencia
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, locale.languageCode);
    } catch (e) {
      debugPrint('Error saving language: $e');
    }
  }

  /// Cambia el idioma por código de idioma
  Future<void> changeLanguageByCode(String languageCode) async {
    final locale = Locale(languageCode);
    await changeLanguage(locale);
  }

  /// Obtiene el idioma actual como string
  String get currentLanguageCode => _currentLocale.languageCode;

  /// Obtiene el nombre del idioma actual
  String get currentLanguageName {
    final language = availableLanguages.firstWhere(
      (lang) => lang['code'] == currentLanguageCode,
      orElse: () => availableLanguages.first,
    );
    return language['name']!;
  }

  /// Obtiene la bandera del idioma actual
  String get currentLanguageFlag {
    final language = availableLanguages.firstWhere(
      (lang) => lang['code'] == currentLanguageCode,
      orElse: () => availableLanguages.first,
    );
    return language['flag']!;
  }
}
