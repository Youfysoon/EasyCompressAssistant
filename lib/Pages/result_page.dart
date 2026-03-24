import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:file_selector/file_selector.dart';
import 'dart:io';
import '../utils/archive_formats.dart';
import '../l10n/app_localizations.dart';  // 导入本地化文件

/// Result display page
/// Shows compression/decompression results, provides sharing, save as, copy path functions
class ResultPage extends StatelessWidget {
  /// File/directory path
  final String path;
  
  /// Whether it's an archive file (true=archive, false=extracted directory)
  final bool isArchive;
  
  /// Operation type description (if empty, will use localized default)
  final String operationTitle;

  const ResultPage({
    super.key,
    required this.path,
    required this.isArchive,
    this.operationTitle = '',  // 空字符串表示使用默认本地化文本
  });

  static const _channel = MethodChannel('com.youfy.easy_compress_assistant/share');

  /// Get filename/directory name
  String get _fileName => path.split(Platform.pathSeparator).last;

  /// Get file size (archive only)
  Future<int?> _getFileSize(BuildContext context) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        return await file.length();
      }
    } catch (e) {
      debugPrint('Error getting file size: $e');
      // show error message on info bar
      _showError(context, '${context.l10n.tr('error')}: $e');
    }
    return null;
  }

  /// Share file (Android/iOS only)
  Future<void> _shareFile(BuildContext context) async {
    if (Platform.isWindows) {
      if (context.mounted) {
        _showInfo(context, context.l10n.tr('tip_share_windows_unsupported'));
      }
      return;
    }
    
    try {
      final result = await _channel.invokeMethod<bool>('shareFile', {'path': path});
      if (result != true && context.mounted) {
        _showError(context, context.l10n.tr('share_failed'));
      }
    } catch (e) {
      if (context.mounted) {
        _showError(context, '${context.l10n.tr('share_error')}: $e');
      }
    }
  }

  /// Save as
  Future<void> _saveAs(BuildContext context) async {
    try {
      final originalName = path.split(Platform.pathSeparator).last;
      final format = ArchiveFormat.detectFromFileName(originalName) ?? ArchiveFormat.zip;
      
      if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        final suggestedName = ArchiveFileName.ensureExtension(originalName, format);
        final location = await getSaveLocation(
          acceptedTypeGroups: [
            XTypeGroup(
              label: format.displayName,
              extensions: [format.extension],
            ),
          ],
          suggestedName: suggestedName,
        );
        if (location != null) {
          String destPath = location.path;
          if (!destPath.toLowerCase().endsWith('.${format.extension}')) {
            destPath = '$destPath.${format.extension}';
          }
          
          final sourceFile = File(path);
          final destFile = File(destPath);
          await sourceFile.copy(destFile.path);
          if (context.mounted) {
            _showSuccess(context, '${context.l10n.tr('saved_to')}: $destPath');
          }
        }
      } else {
        final result = await _channel.invokeMethod<Map>('saveAs', {
          'path': path,
          'suggestedName': ArchiveFileName.ensureExtension(originalName, format),
          'mimeType': format.mimeType,
        });
        if (result != null && result['success'] == true) {
          if (context.mounted) {
            _showSuccess(context, '${context.l10n.tr('saved_to')}:${result['destination']}');
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showError(context, '${context.l10n.tr('error')}: $e');  // 使用context.l10n替代l10n
      }
    }
  }

  /// Copy path to clipboard
  Future<void> _copyPath(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: path));
    if (context.mounted) {
      _showSuccess(context, context.l10n.tr('tip_copied'));
    }
  }

  void _showInfo(BuildContext context, String message) {
    displayInfoBar(
      context,
      builder: (context, close) => InfoBar(
        title: Text(context.l10n.tr('info')),
        content: Text(message),
        severity: InfoBarSeverity.info,
        onClose: close,
      ),
    );
  }

  void _showError(BuildContext context, String message) {
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

  void _showSuccess(BuildContext context, String message) {
    displayInfoBar(
      context,
      builder: (context, close) => InfoBar(
        title: Text(context.l10n.tr('success')),
        content: Text(message),
        severity: InfoBarSeverity.success,
        onClose: close,
      ),
    );
  }

  /// Format file size
  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / 1048576).toStringAsFixed(1)} MB';
    return '${(bytes / 1073741824).toStringAsFixed(1)} GB';
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final l10n = context.l10n;
    final title = operationTitle.isEmpty 
        ? l10n.tr('operation_complete') 
        : operationTitle;

    return ScaffoldPage(
      header: PageHeader(
        title: Text(title),
      ),
      content: LayoutBuilder(
        builder: (context, constraints) {
          final isLandscape = constraints.maxWidth > constraints.maxHeight;
          
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isLandscape ? constraints.maxWidth * 0.6 : constraints.maxWidth * 0.9,
                maxHeight: isLandscape ? constraints.maxHeight * 0.9 : constraints.maxHeight * 0.6,
              ),
              child: Card(
                padding: const EdgeInsets.all(32),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isArchive ? FluentIcons.archive : FluentIcons.folder,
                        size: 64,
                        color: theme.accentColor,
                      ),
                      const SizedBox(height: 24),
                      
                      Text(
                        _fileName,
                        style: theme.typography.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.accentColor.withAlpha(30),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          isArchive ? context.l10n.tr('result_archive_file') : context.l10n.tr('result_folder'),
                          style: TextStyle(
                            color: theme.accentColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      if (isArchive)
                        FutureBuilder<int?>(
                          future: _getFileSize(context),
                          builder: (context, snapshot) {
                            if (snapshot.hasData && snapshot.data != null) {
                              return Text(
                                '${context.l10n.tr('result_file_size')}: ${_formatSize(snapshot.data!)}',
                                style: theme.typography.body,
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      const SizedBox(height: 32),
                      
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                path,
                                style: theme.typography.caption,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(FluentIcons.copy),
                              onPressed: () => _copyPath(context),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        alignment: WrapAlignment.center,
                        children: [
                          if (isArchive)
                            FilledButton(
                              onPressed: () => _shareFile(context),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Platform.isWindows 
                                      ? FluentIcons.blocked
                                      : FluentIcons.share),
                                  const SizedBox(width: 8),
                                  Text(Platform.isWindows ? context.l10n.tr('result_share_unsupported') : context.l10n.tr('result_share')),
                                ],
                              ),
                            ),
                          
                          Button(
                            onPressed: () => _saveAs(context),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(FluentIcons.save_as),
                                const SizedBox(width: 8),
                                Text(context.l10n.tr('result_save_as')),
                              ],
                            ),
                          ),
                          
                          Button(
                            onPressed: () => _copyPath(context),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(FluentIcons.copy),
                                const SizedBox(width: 8),
                                Text(context.l10n.tr('result_copy_path')),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      Button(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(context.l10n.tr('result_back')),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
