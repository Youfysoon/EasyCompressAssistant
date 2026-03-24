import 'dart:io';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:fluent_ui/fluent_ui.dart';
import 'package:permission_handler/permission_handler.dart';

/// Application data directory utilities
class AppDataUtil {
  static Future<String> getAppDocumentsDirectory() async {
    final directory = await path_provider.getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<String> getAppTemporaryDirectory() async {
    final directory = await path_provider.getTemporaryDirectory();
    return directory.path;
  }

  static Future<String?> getExternalStorageDirectory() async {
    if (Platform.isAndroid) {
      try {
        await requestStoragePermission();
        
        final directory = await path_provider.getExternalStorageDirectory();
        if (directory != null) {
          return directory.path;
        }
      } catch (e) {
        debugPrint('Error getting external storage directory: $e');
        return null;
      }
    }
    return null;
  }

  static Future<String?> getAppSupportDirectory() async {
    if (Platform.isIOS) {
      try {
        final directory = await path_provider.getApplicationSupportDirectory();
        return directory.path;
      } catch (e) {
        debugPrint('Error getting app support directory: $e');
        return null;
      }
    }
    return null;
  }

  static Future<void> ensureDirectoryExists(String path) async {
    final directory = Directory(path);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
  }
  
  static Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      // For Android, request storage permission
      // Note: On Android 10+, scoped storage is used and permissions behave differently
      var status = await Permission.storage.status;
      
      if (status != PermissionStatus.granted) {
        status = await Permission.storage.request();
      }
      
      return status == PermissionStatus.granted;
    }
    return true;
  }
  
  static Future<bool> requestManageExternalStoragePermission() async {
    if (Platform.isAndroid) {
      var status = await Permission.manageExternalStorage.status;
      
      if (status != PermissionStatus.granted) {
        status = await Permission.manageExternalStorage.request();
      }
      
      return status == PermissionStatus.granted;
    }
    return true;
  }
}
