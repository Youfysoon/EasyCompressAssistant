import 'package:fluent_ui/fluent_ui.dart';
import 'dart:io';
import '../utils/native_file_picker/native_file_picker.dart';
import '../utils/compression_util.dart';
import '../utils/app_config.dart';
import '../l10n/app_localizations.dart';
import 'result_page.dart';

class DecompressPage extends StatefulWidget {
  const DecompressPage({super.key});

  @override
  State<DecompressPage> createState() => _DecompressPageState();
}

class _DecompressPageState extends State<DecompressPage> {
  final List<Map<String, dynamic>> _selectedArchives = [];
  
  bool _isProcessing = false;
  double _progress = 0.0;
  String _status = '';
  bool _extractSubfolders = true;
  bool _preserveStructure = true;

  /// Select archives
  /// Open file picker to allow user to select archive files
  Future<void> _selectArchives() async {
    final files = await NativeFilePicker.pickFiles(multiple: true);
    if (files.isNotEmpty) {
      setState(() {
        for (final file in files) {
          final name = file['name'] as String? ?? '';
          // Check if file extension is a supported archive format
          if (name.toLowerCase().endsWith('.zip') ||
              name.toLowerCase().endsWith('.rar') ||
              name.toLowerCase().endsWith('.7z') ||
              name.toLowerCase().endsWith('.tar') ||
              name.toLowerCase().endsWith('.gz')) {
            // Avoid adding duplicate files
            if (!_selectedArchives.any((f) => f['path'] == file['path'])) {
              _selectedArchives.add(file);
            }
          }
        }
      });
    }
  }

  /// Select directory
  /// Open directory picker to allow user to select a directory
  Future<void> _selectFolder() async {
    final dirPath = await NativeFilePicker.pickDirectory();
    if (dirPath != null) {
      setState(() {
        _selectedArchives.clear();
        _selectedArchives.add({
          'name': dirPath.split(Platform.pathSeparator).last,
          'path': dirPath,
          'size': 0,
        });
      });
    }
  }

  // Remove archive at specified index
  void _removeArchive(int index) {
    setState(() {
      _selectedArchives.removeAt(index);
    });
  }

  // Start decompression operation
  Future<void> _startDecompress() async {
    final l10n = context.l10n;
    
    // Check if archive files are selected
    if (_selectedArchives.isEmpty) {
      _showError(l10n.tr('decompress_no_files'));
      return;
    }

    // Update UI status to processing
    setState(() {
      _isProcessing = true;
      _progress = 0.0;
      _status = '${l10n.tr('loading')}...';
    });

    try {
      // Get the first archive file path
      final archivePath = _selectedArchives.first['path'] as String?;
      if (archivePath == null || archivePath.isEmpty) {
        _showError(l10n.tr('error'));
        setState(() => _isProcessing = false);
        return;
      }

      // Currently only supports ZIP format
      if (!archivePath.toLowerCase().endsWith('.zip')) {
        _showError('Only ZIP format is supported');
        setState(() => _isProcessing = false);
        return;
      }

      // Create output directory name
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final outputDir = await AppConfig.getExtractOutputPath('extracted_$timestamp');

      setState(() {
        _progress = 0.3;
        _status = l10n.tr('decompress_processing');
      });

      // Perform actual extraction
      final success = await CompressionUtil.extractArchive(
        sourceZipPath: archivePath,
        destinationDirPath: outputDir,
      );

      if (!mounted) return;
      
      // Update completion status
      setState(() {
        _progress = 1.0;
        _status = success ? l10n.tr('decompress_complete') : l10n.tr('error');
      });

      // If extraction succeeds, navigate to result page
      if (success) {
        Navigator.of(context).push(
          FluentPageRoute(
            builder: (context) => ResultPage(
              path: outputDir,
              isArchive: false,
              operationTitle: l10n.tr('result_decompress_complete'),
            ),
          ),
        );
      } else {
        _showError(l10n.tr('error'));
      }
    } catch (e) {
      _showError('${l10n.tr('error')}: $e');
    } finally {
      // Restore non-processing state
      setState(() => _isProcessing = false);
    }
  }

  // Show error message
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
              // Page title
              Text(
                l10n.tr('decompress_title'),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              // Archive file selection card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Archive file list area
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
                        child: _selectedArchives.isEmpty
                            ? Center(child: Text(l10n.tr('decompress_no_files')))
                            : ListView.builder(
                                itemCount: _selectedArchives.length,
                                itemBuilder: (context, index) {
                                  final archive = _selectedArchives[index];
                                  return ListTile(
                                    leading: const Icon(FluentIcons.archive),
                                    title: Text(archive['name'] ?? 'Unknown'),
                                    subtitle: archive['size'] != null && archive['size'] > 0
                                        ? Text(NativeFilePicker.formatSize(archive['size']))
                                        : null,
                                    trailing: IconButton(
                                      icon: const Icon(FluentIcons.delete),
                                      onPressed: () => _removeArchive(index),
                                    ),
                                  );
                                },
                              ),
                      ),
                      const SizedBox(height: 10),
                      // Buttons for selecting archives/directories
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Button(
                            onPressed: _isProcessing ? null : _selectArchives,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(FluentIcons.attach),
                                const SizedBox(width: 8),
                                Text(l10n.tr('decompress_select_archives')),
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
                                Text(l10n.tr('decompress_select_folder')),
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
              // Show options if not processing
              if (!_isProcessing)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Decompression options title
                    Text(
                      l10n.tr('decompress_options'),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    // Extract subfolders checkbox
                    Checkbox(
                      checked: _extractSubfolders,
                      onChanged: (value) {
                        setState(() {
                          _extractSubfolders = value ?? false;
                        });
                      },
                      content: Text(l10n.tr('decompress_extract_subfolders')),
                    ),
                    const SizedBox(height: 10),
                    // Preserve structure checkbox
                    Checkbox(
                      checked: _preserveStructure,
                      onChanged: (value) {
                        setState(() {
                          _preserveStructure = value ?? false;
                        });
                      },
                      content: Text(l10n.tr('decompress_preserve_structure')),
                    ),
                    const SizedBox(height: 20),
                    // Start decompression button
                    Center(
                      child: FilledButton(
                        onPressed: _startDecompress,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(FluentIcons.play),
                            const SizedBox(width: 8),
                            Text(l10n.tr('decompress_start')),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              // Show progress if processing
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    // Status message
                    Text(
                      _status,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    // Progress bar
                    ProgressBar(value: _progress),
                    const SizedBox(height: 10),
                    // Cancel button
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
