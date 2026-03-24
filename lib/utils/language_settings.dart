import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Language settings manager
class LanguageSettings {
  static const String _keyLanguage = 'app_language';
  
  /// Supported languages
  /// 
  /// Key is language code, value is display name
  static const Map<String, String> supportedLanguages = {
    'zh': '中文',
    'en': 'English',
  };
  
  /// Get current language code
  /// 
  /// Returns:
  /// - Current language code, defaults to 'zh'
  static Future<String> getCurrentLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLanguage) ?? 'zh';
  }
  
  /// Set language
  /// 
  /// Parameter:
  /// - languageCode: Language code
  static Future<void> setLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLanguage, languageCode);
  }
  
  /// Get language display name
  /// 
  /// Parameter:
  /// - code: Language code
  /// 
  /// Returns:
  /// - Display name of the language
  static String getLanguageName(String code) {
    return supportedLanguages[code] ?? 'Unknown';
  }
  
  /// Get Locale object
  /// 
  /// Locale object used for Flutter internationalization
  /// 
  /// Parameter:
  /// - languageCode: Language code
  /// 
  /// Returns:
  /// - Corresponding Locale object
  static Locale getLocale(String languageCode) {
    switch (languageCode) {
      case 'zh':
        return const Locale('zh', 'CN');
      case 'en':
        return const Locale('en', 'US');
      default:
        return const Locale('zh', 'CN');
    }
  }
}
