import 'package:shared_preferences/shared_preferences.dart';
import 'app_config.dart';

/// Storage settings manager
/// Manages cache clearing, auto-clear settings, etc.
class StorageSettings {
  static const String _keyAutoClean = 'auto_clean_cache';
  
  /// Get whether auto-cache cleaning is enabled
  /// 
  /// Returns:
  /// - Whether auto-cleaning is enabled
  static Future<bool> getAutoCleanEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyAutoClean) ?? false;
  }
  
  /// Set auto-cache cleaning toggle
  /// 
  /// Parameter:
  /// - value: Whether to enable auto-cleaning
  static Future<void> setAutoCleanEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAutoClean, value);
  }
  
  /// Get temporary directory path (app-specific cache directory)
  /// 
  /// Returns:
  /// - Temporary directory path
  static Future<String> getTempDirectory() async {
    final dir = await AppConfig.getCacheDir();
    return dir.path;
  }
  
  /// Get cache directory size (in bytes)
  /// 
  /// Returns:
  /// - Cache size (in bytes)
  static Future<int> getCacheSize() async {
    return AppConfig.getCacheSize();
  }
  
  /// Clear cache
  /// 
  /// Delete all cache files
  static Future<void> clearCache() async {
    await AppConfig.clearAllCache();
  }
  
  /// Format file size
  /// 
  /// Parameter:
  /// - bytes: Number of bytes
  /// 
  /// Returns:
  /// - Formatted size string (e.g. "1.2 MB")
  static String formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / 1048576).toStringAsFixed(1)} MB';
    return '${(bytes / 1073741824).toStringAsFixed(1)} GB';
  }
  
  /// Perform cleanup when app closes (if enabled)
  /// 
  /// If auto-cleaning is enabled, clear cache
  static Future<void> autoCleanIfEnabled() async {
    final enabled = await getAutoCleanEnabled();
    if (enabled) {
      await clearCache();
    }
  }
}
