import 'package:fluent_ui/fluent_ui.dart';
import 'package:file_selector/file_selector.dart';
import 'dart:io';

/// File Selector Utility
/// Supports selecting multiple files or single folder
class FileSelectorUtil {
  /// Select multiple files
  static Future<List<String>?> selectMultipleFiles({
    String? dialogTitle,
    List<FileExtension>? acceptedFileExtensions,
  }) async {
    try {
      final typeGroup = XTypeGroup(
        label: 'files',
        extensions: acceptedFileExtensions?.expand((ext) => ext.extensions).toList() ?? [],
      );

      final files = await openFiles(
        acceptedTypeGroups: [typeGroup],
      );

      if (files.isNotEmpty) {
        return files.map((file) => file.path).toList();
      }
    } catch (e) {
      debugPrint('Error selecting multiple files: $e');
    }

    return null;
  }

  /// Select single folder
  static Future<String?> selectFolder({
    String? dialogTitle,
  }) async {
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        debugPrint('Folder selection is not supported on mobile platforms');
        return null;
      } else {
        final result = await getDirectoryPath();
        return result;
      }
    } catch (e) {
      debugPrint('Error selecting folder: $e');
      return null;
    }
  }
  
  /// Select single file
  static Future<String?> selectSingleFile({
    String? dialogTitle,
    List<FileExtension>? acceptedFileExtensions,
  }) async {
    try {
      final typeGroup = XTypeGroup(
        label: 'files',
        extensions: acceptedFileExtensions?.expand((ext) => ext.extensions).toList() ?? [],
      );

      final file = await openFile(
        acceptedTypeGroups: [typeGroup],
      );

      if (file != null) {
        return file.path;
      }
    } catch (e) {
      debugPrint('Error selecting single file: $e');
    }

    return null;
  }
  
  /// Get save path
  static Future<String?> getSavePath({
    String? dialogTitle,
    String? suggestedName,
  }) async {
    try {
      final result = await getSaveLocation(
        suggestedName: suggestedName,
      );

      return result?.path;
    } catch (e) {
      debugPrint('Error getting save location: $e');
    }

    return null;
  }
}

/// File Extension Class
class FileExtension {
  final String name;
  final List<String> extensions;

  FileExtension({
    required this.name,
    required this.extensions,
  });
}
