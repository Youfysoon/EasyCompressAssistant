import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'archive_formats.dart';

/// Application configuration manager
/// Manages cache, configuration files, and data storage paths uniformly
class AppConfig {
  /// Application name (used to create subdirectories)
  static const String appName = 'CompressAssistant';

  /// Get cache root directory
  /// 
  /// Returns appropriate cache directory based on platform
  /// - Android: /data/data/<package>/cache/CompressAssistant
  /// - iOS: NSTemporaryDirectory()/CompressAssistant
  /// - Windows: %TEMP%/CompressAssistant (User temporary directory)
  /// - macOS: ~/Library/Caches/CompressAssistant
  /// - Linux: ~/.cache/CompressAssistant or /tmp/CompressAssistant
  static Future<Directory> getCacheDir() async {
    late final String basePath;
    
    if (Platform.isAndroid) {
      basePath = '${(await getTemporaryDirectory()).path}/$appName';
    } else if (Platform.isIOS) {
      basePath = '${(await getTemporaryDirectory()).path}/$appName';
    } else if (Platform.isWindows) {
      // Note: Not using systemTemp as it may point to system directory
      final tempDir = await getTemporaryDirectory();
      basePath = '${tempDir.path}\\$appName';
    } else if (Platform.isMacOS) {
      basePath = '${(await getTemporaryDirectory()).path}/$appName';
    } else if (Platform.isLinux) {
      basePath = '${(await getTemporaryDirectory()).path}/$appName';
    } else {
      basePath = '${Directory.systemTemp.path}${Platform.pathSeparator}$appName';
    }
    
    final dir = Directory(basePath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Get configuration file directory
  /// 
  /// Returns appropriate configuration directory based on platform
  /// - Android: /data/data/<package>/files/config
  /// - iOS: ~/Library/Application Support/CompressAssistant
  /// - Windows: %APPDATA%/CompressAssistant (Roaming configuration)
  /// - macOS: ~/Library/Application Support/CompressAssistant
  /// - Linux: ~/.config/CompressAssistant
  static Future<Directory> getConfigDir() async {
    late final String basePath;
    
    if (Platform.isAndroid) {
      basePath = '${(await getApplicationDocumentsDirectory()).path}/config';
    } else if (Platform.isIOS) {
      basePath = '${(await getApplicationSupportDirectory()).path}/$appName';
    } else if (Platform.isWindows) {
      // Or use getApplicationSupportDirectory() to get LocalAppData
      final appDir = await getApplicationSupportDirectory();
      basePath = '${appDir.path}\\$appName';
    } else if (Platform.isMacOS) {
      final appDir = await getApplicationSupportDirectory();
      basePath = '${appDir.path}/$appName';
    } else if (Platform.isLinux) {
      final home = Platform.environment['HOME'];
      basePath = '$home/.config/$appName';
    } else {
      basePath = '${Directory.current.path}/config';
    }
    
    final dir = Directory(basePath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Get compression output path (automatically ensures correct extension)
  static Future<String> getCompressOutputPath(
    String baseName, {
    ArchiveFormat format = ArchiveFormat.zip,
  }) async {
    final cacheDir = await getCacheDir();
    final fileName = ArchiveFileName.ensureExtension(baseName, format);
    return '${cacheDir.path}${Platform.pathSeparator}$fileName';
  }

  /// Get extraction output directory (using timestamp to ensure uniqueness)
  static Future<String> getExtractOutputPath(String baseName) async {
    final cacheDir = await getCacheDir();
    final cleanName = ArchiveFileName.extractBaseName(baseName);
    return '${cacheDir.path}${Platform.pathSeparator}extracted_$cleanName';
  }

  /// Clear all cache
  /// 
  /// Deletes entire cache directory and its contents
  static Future<void> clearAllCache() async {
    final cacheDir = await getCacheDir();
    if (await cacheDir.exists()) {
      await cacheDir.delete(recursive: true);
    }
  }

  /// Get cache size
  /// 
  /// Returns:
  /// - Total size of cache directory (in bytes)
  static Future<int> getCacheSize() async {
    final cacheDir = await getCacheDir();
    return _calculateDirSize(cacheDir);
  }

  /// Calculate directory size
  /// 
  /// Parameter:
  /// - dir: Directory to calculate
  /// 
  /// Returns:
  /// - Total directory size (in bytes)
  static int _calculateDirSize(Directory dir) {
    int total = 0;
    try {
      // Recursively iterate through all entities in directory
      for (final entity in dir.listSync(recursive: true, followLinks: false)) {
        if (entity is File) {
          total += entity.lengthSync();
        }
      }
    } catch (e) {
      debugPrint('Error calculating cache size: $e');
    }
    return total;
  }
}
