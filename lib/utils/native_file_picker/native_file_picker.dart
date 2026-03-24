import 'dart:io';
import 'package:flutter/services.dart';
import 'package:file_selector/file_selector.dart';

/// File picker - Execute corresponding logic based on platform
/// 
/// This class provides cross-platform file and directory selection functionality
class NativeFilePicker {
  static const _channel = MethodChannel('com.youfy.easy_compress_assistant/file_picker');

  /// Select files
  /// 
  /// Parameters:
  /// - multiple: Whether to allow multiple selection, defaults to false
  /// 
  /// Returns:
  /// - List of Maps containing file information
  static Future<List<Map<String, dynamic>>> pickFiles({bool multiple = false}) async {
    if (Platform.isAndroid || Platform.isIOS) {
      final result = await _channel.invokeMethod<List<dynamic>>(
        multiple ? 'pickMultipleFiles' : 'pickFile',
      );
      if (result == null) return [];
      return result.map((e) => (e as Map).cast<String, dynamic>()).toList();
    } else {
      final files = multiple ? await openFiles() : [await openFile()].whereType<XFile>();
      return Future.wait(files.map((f) async => {
        'name': f.name,
        'path': f.path,
        'size': await f.length(),
      }));
    }
  }

  /// Select directory
  /// 
  /// Returns:
  /// - Directory path, returns null if selection is cancelled
  static Future<String?> pickDirectory() async {
    if (Platform.isAndroid || Platform.isIOS) {
      final result = await _channel.invokeMethod<Map>('pickDirectory');
      return result?['path'] as String?;
    } else {
      return getDirectoryPath();
    }
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
}
