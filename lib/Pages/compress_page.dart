import 'package:fluent_ui/fluent_ui.dart';
import 'dart:io';
import '../utils/native_file_picker/native_file_picker.dart';
import '../utils/compression_util.dart';
import '../utils/app_config.dart';
import '../utils/archive_formats.dart';
import '../l10n/app_localizations.dart';
import 'result_page.dart';

class CompressPage extends StatefulWidget {
  const CompressPage({super.key});

  @override
  State<CompressPage> createState() => _CompressPageState();
}

class _CompressPageState extends State<CompressPage> {
  final List<Map<String, dynamic>> _selectedFiles = [];
  bool _isProcessing = false;
  double _progress = 0.0;
  String _status = '';
  bool _reduceQuality = false;
  bool _mergeArchive = false;
  ArchiveFormat _selectedFormat = ArchiveFormat.zip;

  /// Select files
  /// Open file picker to allow user to select multiple files
  Future<void> _selectFiles() async {
    final files = await NativeFilePicker.pickFiles(multiple: true);
    if (files.isNotEmpty) {
      setState(() {
        for (final file in files) {
          // Avoid adding duplicate files
          if (!_selectedFiles.any((f) => f['path'] == file['path'])) {
            _selectedFiles.add(file);
          }
        }
      });
    }
  }

  /// Select directory
  /// Open directory picker to allow user to select a directory
  /// Recursively add all files in the directory
  Future<void> _selectFolder() async {
    final dirPath = await NativeFilePicker.pickDirectory();
    debugPrint('Directory picked: $dirPath');
    
    if (dirPath != null) {
      // Clear previous selection first
      setState(() {
        _selectedFiles.clear();
      });
      
      // Add directory marker first (so UI shows the folder)
      final dirName = dirPath.split(Platform.pathSeparator).last;
      
      setState(() {
        _selectedFiles.add({
          'name': dirName,
          'path': dirPath,
          'size': 0, // 0 marks this as a directory
        });
      });
      
      debugPrint('Added directory marker: $dirName');
      
      // Then add files recursively
      await _addFilesRecursively(dirPath);
    }
  }

  /// Recursively add files from directory
  /// Parameter:
  /// - dirPath: Directory path to scan
  Future<void> _addFilesRecursively(String dirPath) async {
    try {
      final directory = Directory(dirPath);
      if (!directory.existsSync()) {
        debugPrint('Directory does not exist: $dirPath');
        return;
      }

      // Use recursive option to simplify the logic
      final entities = directory.listSync(
        recursive: true, 
        followLinks: false,
      );
      
      int fileCount = 0;
      final List<Map<String, dynamic>> newFiles = [];
      
      for (final entity in entities) {
        // Only add files, not directories
        if (entity is File) {
          final file = entity;
          try {
            newFiles.add({
              'name': file.path.split(Platform.pathSeparator).last,
              'path': file.path,
              'size': file.lengthSync(),
            });
            fileCount++;
          } catch (fileError) {
            debugPrint('Cannot access file ${file.path}: $fileError');
          }
        }
      }
      
      debugPrint('Found $fileCount files in $dirPath');
      
      // Update state with all new files at once
      if (newFiles.isNotEmpty && mounted) {
        setState(() {
          _selectedFiles.addAll(newFiles);
        });
      }
      
      // Show info if no files were found
      if (fileCount == 0 && mounted) {
        _showError(context.l10n.tr('tip_no_files_in_directory'));
      }
    } catch (e) {
      debugPrint('Error reading directory $dirPath: $e');
      if (mounted) {
        _showError('${context.l10n.tr('error_cannot_access_directory')}: $e');
      }
    }
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
  }

  /// Start compression by calling 'CompressionUtil' and Update UI
  Future<void> _startCompress() async {
    final l10n = context.l10n;
    
    if (_selectedFiles.isEmpty) {
      _showError(l10n.tr('tip_please_select_files'));
      return;
    }

    setState(() {
      _isProcessing = true;
      _progress = 0.0;
      _status = '${l10n.tr('loading')}...';
    });

    try {
      // Get source paths: use directory paths for directories (size==0),
      // or file paths for individual files
      final filePaths = _selectedFiles
          .where((f) {
            final path = f['path'] as String?;
            return path != null && path.isNotEmpty;
          })
          .map((f) => f['path'] as String)
          .toList();

      if (filePaths.isEmpty) {
        _showError(l10n.tr('error'));
        setState(() => _isProcessing = false);
        return;
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final outputPath = await AppConfig.getCompressOutputPath(
        'compressed_$timestamp',
        format: _selectedFormat,
      );

      setState(() {
        _progress = 0.3;
        _status = l10n.tr('compress_processing');
      });

      final success = await CompressionUtil.compressFiles(
        sourcePaths: filePaths,
        destinationZipPath: outputPath,
      );

      if (!mounted) return;
      
      setState(() {
        _progress = 1.0;
        _status = success ? l10n.tr('compress_complete') : l10n.tr('error');
      });

      if (success) {
        Navigator.of(context).push(
          FluentPageRoute(
            builder: (context) => ResultPage(
              path: outputPath,
              isArchive: true,
              operationTitle: l10n.tr('result_compress_complete'),
            ),
          ),
        );
      } else {
        _showError(l10n.tr('error'));
      }
    } catch (e) {
      _showError('${l10n.tr('error')}: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  /// Show error message on InfoBar
  void _showError(String message) {
    displayInfoBar(
      context,
      builder: (context, close) => InfoBar(
        title: Text(context.l10n.tr('error')),
        content: Text(message),
        severity: InfoBarSeverity.error,
        onClose: close,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    
    return ScaffoldPage.scrollable(
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.tr('compress_title'),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: FluentTheme.of(context).brightness == Brightness.light 
                                ? Colors.grey : Colors.grey,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: _selectedFiles.isEmpty
                            ? Center(child: Text(l10n.tr('compress_no_files')))
                            : ListView.builder(
                                itemCount: _selectedFiles.length,
                                itemBuilder: (context, index) {
                                  final file = _selectedFiles[index];
                                  final isDirectory = file['size'] == 0;
                                  return ListTile(
                                    leading: Icon(isDirectory 
                                        ? FluentIcons.folder 
                                        : FluentIcons.document),
                                    title: Text(file['name'] ?? 'Unknown'),
                                    subtitle: file['size'] != null && file['size'] > 0
                                        ? Text(NativeFilePicker.formatSize(file['size']))
                                        : null,
                                    trailing: IconButton(
                                      icon: const Icon(FluentIcons.delete),
                                      onPressed: () => _removeFile(index),
                                    ),
                                  );
                                },
                              ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Button(
                            onPressed: _isProcessing ? null : _selectFiles,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(FluentIcons.attach),
                                const SizedBox(width: 8),
                                Text(l10n.tr('compress_select_files')),
                              ],
                            ),
                          ),
                          Button(
                            onPressed: _isProcessing ? null : _selectFolder,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(FluentIcons.folder),
                                const SizedBox(width: 8),
                                Text(l10n.tr('compress_select_folder')),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (!_isProcessing)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.tr('compress_options'),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text('${l10n.tr('compress_format')}: '),
                        const SizedBox(width: 8),
                        ComboBox<ArchiveFormat>(
                          value: _selectedFormat,
                          items: ArchiveFormat.supportedFormats.map((format) {
                            return ComboBoxItem(
                              value: format,
                              child: Text('${format.displayName} (.${format.extension})'),
                            );
                          }).toList(),
                          onChanged: _isProcessing
                              ? null
                              : (format) {
                                  if (format != null) {
                                    setState(() {
                                      _selectedFormat = format;
                                    });
                                  }
                                },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Checkbox(
                      checked: _reduceQuality,
                      onChanged: (value) {
                        setState(() {
                          _reduceQuality = value ?? false;
                        });
                      },
                      content: Text(l10n.tr('compress_reduce_quality')),
                    ),
                    const SizedBox(height: 10),
                    Checkbox(
                      checked: _mergeArchive,
                      onChanged: (value) {
                        setState(() {
                          _mergeArchive = value ?? false;
                        });
                      },
                      content: Text(l10n.tr('compress_merge')),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: FilledButton(
                        onPressed: _startCompress,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(FluentIcons.play),
                            const SizedBox(width: 8),
                            Text(l10n.tr('compress_start')),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      _status,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    ProgressBar(value: _progress),
                    const SizedBox(height: 10),
                    Center(
                      child: Button(
                        onPressed: () => setState(() => _isProcessing = false),
                        child: Text(l10n.tr('cancel')),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}
