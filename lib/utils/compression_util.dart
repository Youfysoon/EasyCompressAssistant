import 'dart:io';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:fluent_ui/fluent_ui.dart';

/// Compression and decompression utility class
/// Provides compression and decompression functions for files and folders
class CompressionUtil {
  /// Compress a single file
  /// 
  /// Parameters:
  /// - sourceFilePath: Source file path
  /// - destinationZipPath: Target ZIP file path
  static Future<bool> compressFile({
    required String sourceFilePath,
    required String destinationZipPath,
  }) async {
    try {
      final sourceFile = File(sourceFilePath);
      if (!await sourceFile.exists()) {
        throw Exception('Source file does not exist: $sourceFilePath');
      }

      // Create an archive
      final archive = Archive();

      // Add file to archive
      final bytes = await sourceFile.readAsBytes();
      final file = ArchiveFile(
        sourceFile.uri.pathSegments.last,
        bytes.length,
        bytes,
      );
      archive.addFile(file);

      // Encode as ZIP format
      final encoder = ZipEncoder();
      final zipBytes = encoder.encode(archive);

      // Write to target file
      final destinationFile = File(destinationZipPath);
      await destinationFile.writeAsBytes(zipBytes!);

      return true;
    } catch (e) {
      debugPrint('Error compressing file: $e');
      return false;
    }
  }

  /// Compress multiple files or folders
  /// 
  /// Parameters:
  /// - sourcePaths: List of source file/folder paths
  /// - destinationZipPath: Target ZIP file path
  static Future<bool> compressFiles({
    required List<String> sourcePaths,
    required String destinationZipPath,
  }) async {
    try {
      final archive = Archive();

      for (final path in sourcePaths) {
        debugPrint('Processing path: $path');
        final entity = FileSystemEntity.typeSync(path);
        debugPrint('Entity type: $entity');
        
        if (entity == FileSystemEntityType.file) {
          // Process single file
          final file = File(path);
          if (await file.exists()) {
            final bytes = await file.readAsBytes();
            final archiveFile = ArchiveFile(
              _getFileNameFromPath(path),
              bytes.length,
              bytes,
            );
            archive.addFile(archiveFile);
            debugPrint('Added file: ${file.path}');
          } else {
            debugPrint('File does not exist: $path');
          }
        } else if (entity == FileSystemEntityType.directory) {
          // Process entire directory
          final dir = Directory(path);
          if (await dir.exists()) {
            await _addDirectoryToArchive(dir, archive, '');
          } else {
            debugPrint('Directory does not exist: $path');
          }
        } else {
          debugPrint('Unknown entity type for path: $path');
        }
      }

      // Check if archive has any files
      if (archive.isEmpty) {
        debugPrint('Warning: Archive is empty!');
        return false;
      }

      // Encode as ZIP format
      final encoder = ZipEncoder();
      final zipBytes = encoder.encode(archive);

      // Write to target file
      final destinationFile = File(destinationZipPath);
      await destinationFile.writeAsBytes(zipBytes!);
      
      debugPrint('Archive created successfully: $destinationZipPath');
      debugPrint('Archive contains ${archive.length} files');

      return true;
    } catch (e) {
      debugPrint('Error compressing files: $e');
      return false;
    }
  }

  /// Extract ZIP file to specified directory
  /// 
  /// Parameters:
  /// - sourceZipPath: Source ZIP file path
  /// - destinationDirPath: Target directory path
  static Future<bool> extractArchive({
    required String sourceZipPath,
    required String destinationDirPath,
  }) async {
    try {
      // Ensure target directory exists
      final destDir = Directory(destinationDirPath);
      if (!await destDir.exists()) {
        await destDir.create(recursive: true);
      }

      // Read ZIP file
      final bytes = await File(sourceZipPath).readAsBytes();

      // Decode ZIP file
      final decoder = ZipDecoder();
      final archive = decoder.decodeBytes(bytes);

      // Extract each file
      for (final file in archive) {
        final fileName = file.name;
        final outputFile = File('$destinationDirPath/$fileName');

        // Ensure output directory exists
        final parentDir = outputFile.parent;
        if (!await parentDir.exists()) {
          await parentDir.create(recursive: true);
        }

        if (file.isFile) {
          final content = file.content;
          if (content is List<int>) {
            await outputFile.writeAsBytes(content);
          } else if (content is Uint8List) {
            await outputFile.writeAsBytes(content);
          } else {
            // Convert to bytes list
            await outputFile.writeAsBytes(List<int>.from(content as List));
          }
        } else {
          // If it's a directory, ensure it's created
          if (!await outputFile.exists()) {
            await outputFile.create(recursive: true);
          }
        }
      }

      return true;
    } catch (e) {
      debugPrint('Error extracting archive: $e');
      return false;
    }
  }

  /// Recursively add directory to archive
  /// 
  /// Parameters:
  /// - directory: Directory to add
  /// - archive: Target archive object
  /// - prefix: Path prefix (directory name to use in archive)
  static Future<void> _addDirectoryToArchive(
    Directory directory,
    Archive archive,
    String prefix,
  ) async {
    final basePath = directory.path;
    debugPrint('Adding directory to archive: $basePath');
    
    // Use the directory name as prefix if not provided
    final dirName = prefix.isEmpty ? _getFileNameFromPath(basePath) : prefix;
    debugPrint('Directory name in archive: $dirName');
    
    final entities = directory.listSync(recursive: true);
    debugPrint('Found ${entities.length} entities in directory');

    for (final entity in entities) {
      if (entity is File) {
        // Calculate relative path, preserving directory structure
        String relativePath;
        if (entity.path.startsWith(basePath)) {
          relativePath = entity.path.substring(basePath.length);
          // Remove leading path separator
          if (relativePath.startsWith('/') || relativePath.startsWith('\\')) {
            relativePath = relativePath.substring(1);
          }
        } else {
          relativePath = _getFileNameFromPath(entity.path);
        }
        
        // Add directory name prefix
        relativePath = '$dirName/$relativePath';
        
        // Use forward slash as path separator consistently
        relativePath = relativePath.replaceAll('\\', '/');
        
        debugPrint('Adding file to archive: $relativePath');
            
        final bytes = await entity.readAsBytes();
        final archiveFile = ArchiveFile(relativePath, bytes.length, bytes);
        archive.addFile(archiveFile);
      }
    }
  }

  /// Extract filename from path
  /// 
  /// Parameter:
  /// - path: Full path
  /// 
  /// Returns:
  /// - Filename
  static String _getFileNameFromPath(String path) {
    final lastIndex = path.lastIndexOf('/');
    if (lastIndex >= 0) {
      return path.substring(lastIndex + 1);
    }
    
    final windowsLastIndex = path.lastIndexOf('\\');
    if (windowsLastIndex >= 0) {
      return path.substring(windowsLastIndex + 1);
    }
    
    return path;
  }
}
