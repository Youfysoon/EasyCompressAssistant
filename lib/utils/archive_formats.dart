import 'dart:io';

/// Archive format enumeration
/// Supports extensible archive format definitions
enum ArchiveFormat {
  zip(
    extension: 'zip',
    mimeType: 'application/zip',
    displayName: 'ZIP Archive',
    description: 'Standard ZIP compression format',
  ),
  sevenZ(
    extension: '7z',
    mimeType: 'application/x-7z-compressed',
    displayName: '7Z Archive',
    description: '7-Zip high compression ratio format',
  ),
  tar(
    extension: 'tar',
    mimeType: 'application/x-tar',
    displayName: 'TAR Archive',
    description: 'Unix standard archive format (no compression)',
  ),
  tarGz(
    extension: 'tar.gz',
    mimeType: 'application/gzip',
    displayName: 'TAR.GZ Archive',
    description: 'Gzip compressed TAR archive',
  ),
  tarBz2(
    extension: 'tar.bz2',
    mimeType: 'application/x-bzip2',
    displayName: 'TAR.BZ2 Archive',
    description: 'Bzip2 compressed TAR archive',
  ),
  rar(
    extension: 'rar',
    mimeType: 'application/x-rar-compressed',
    displayName: 'RAR Archive',
    description: 'WinRAR compression format (extract only)',
  );

  final String extension;
  final String mimeType;
  final String displayName;
  final String description;

  const ArchiveFormat({
    required this.extension,
    required this.mimeType,
    required this.displayName,
    required this.description,
  });

  /// Get dotted extension (e.g. .zip)
  String get dottedExtension => '.$extension';

  /// Get format by extension (case-insensitive)
  static ArchiveFormat fromExtension(String ext) {
    final cleanExt = ext.toLowerCase().replaceAll('.', '');
    for (final format in ArchiveFormat.values) {
      if (format.extension == cleanExt) {
        return format;
      }
    }
    return ArchiveFormat.zip; // Default to zip if not found
  }

  /// Auto-detect format from file name
  /// Returns null if no matching extension found
  static ArchiveFormat? detectFromFileName(String fileName) {
    final lowerName = fileName.toLowerCase();
    
    final sortedFormats = ArchiveFormat.values.toList()
      ..sort((a, b) => b.extension.length.compareTo(a.extension.length));
    
    for (final format in sortedFormats) {
      if (lowerName.endsWith('.${format.extension}')) {
        return format;
      }
    }
    
    return null;
  }

  /// Get all supported formats (for dropdown selection)
  static List<ArchiveFormat> get supportedFormats => [
    ArchiveFormat.zip,
    ArchiveFormat.sevenZ,
    ArchiveFormat.tar,
    ArchiveFormat.tarGz,
  ];

  /// Get all extractable formats (including read-only formats)
  static List<ArchiveFormat> get allFormats => ArchiveFormat.values;
}

/// Archive file name utilities
class ArchiveFileName {
  /// Generate file name with correct suffix
  /// 
  /// Examples:
  /// - generate('document', ArchiveFormat.zip) → 'document.zip'
  /// - generate('backup.tar', ArchiveFormat.gz) → 'backup.tar.gz'
  static String generate(String baseName, ArchiveFormat format) {
    String cleanName = baseName;
    for (final fmt in ArchiveFormat.values) {
      if (cleanName.toLowerCase().endsWith('.${fmt.extension}')) {
        cleanName = cleanName.substring(0, cleanName.length - fmt.extension.length - 1);
        break;
      }
    }
    
    cleanName = cleanName.replaceAll(RegExp(r'[<>"/\\|?*]'), '_');
    
    return '$cleanName.${format.extension}';
  }

  /// Ensure file name has correct extension
  /// 
  /// If user enters file name without suffix, automatically adds it
  /// If user enters wrong suffix, replaces with correct one
  static String ensureExtension(String fileName, ArchiveFormat format) {
    if (fileName.isEmpty) {
      return 'archive.${format.extension}';
    }
    
    final currentFormat = ArchiveFormat.detectFromFileName(fileName);
    
    // If already has correct extension, return as-is
    if (currentFormat == format) {
      return fileName;
    }
    
    // Otherwise generate with correct extension
    return generate(fileName, format);
  }

  /// Extract base name from full path (without extension)
  static String extractBaseName(String path) {
    final fileName = path.split(Platform.pathSeparator).last;
    final format = ArchiveFormat.detectFromFileName(fileName);
    
    if (format == null) {
      return fileName;
    }
    
    return fileName.substring(0, fileName.length - format.extension.length - 1);
  }
}
