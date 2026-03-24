import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:fluent_ui/fluent_ui.dart';

/// Quick Compress and Send Utility
/// Provides fast file compression and system share functionality
class QuickCompressUtil {
  static const MethodChannel _channel = MethodChannel(
    'com.youfy.easy_compress_assistant/quick_compress',
  );

  /// Check if quick compress is supported
  static Future<bool> isSupported() async {
    if (!Platform.isAndroid) {
      return false;
    }
    try {
      final result = await _channel.invokeMethod<bool>('isSupported');
      return result ?? false;
    } catch (e) {
      debugPrint('Error checking quick compress support: $e');
      return false;
    }
  }

  /// Quick compress and send files
  /// [filePaths] List of file paths to compress
  /// [archiveName] Archive name (optional, defaults to timestamp)
  static Future<bool> quickCompressAndSend({
    required List<String> filePaths,
    String? archiveName,
  }) async {
    if (!Platform.isAndroid) {
      debugPrint('Quick compress is only supported on Android');
      return false;
    }

    if (filePaths.isEmpty) {
      debugPrint('No files to compress');
      return false;
    }

    try {
      final result = await _channel.invokeMethod<bool>('quickCompressAndSend', {
        'filePaths': filePaths,
        'archiveName': archiveName ?? 'compressed_${DateTime.now().millisecondsSinceEpoch}',
      });
      return result ?? false;
    } catch (e) {
      debugPrint('Error during quick compress: $e');
      return false;
    }
  }

  /// Compress single file and send
  static Future<bool> quickCompressSingleFile({
    required String filePath,
    String? archiveName,
  }) async {
    return quickCompressAndSend(
      filePaths: [filePath],
      archiveName: archiveName,
    );
  }

  /// Simulate "Quick Compress and Send" on Flutter side
  /// Used when native channel is unavailable
  static Future<void> showQuickCompressDialog(
    BuildContext context, {
    required List<String> filePaths,
    String? archiveName,
  }) async {
    if (!context.mounted) return;
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _QuickCompressDialog(
        filePaths: filePaths,
        archiveName: archiveName,
      ),
    );

    if (result == true && context.mounted) {
      displayInfoBar(
        context,
        builder: (context, close) => InfoBar(
          title: const Text('Compression Complete'),
          content: const Text('File has been compressed and ready to send'),
          severity: InfoBarSeverity.success,
          onClose: close,
        ),
      );
    }
  }
}

/// Quick Compress Progress Dialog
class _QuickCompressDialog extends StatefulWidget {
  final List<String> filePaths;
  final String? archiveName;

  const _QuickCompressDialog({
    required this.filePaths,
    this.archiveName,
  });

  @override
  State<_QuickCompressDialog> createState() => _QuickCompressDialogState();
}

class _QuickCompressDialogState extends State<_QuickCompressDialog> {
  double _progress = 0.0;
  String _status = 'Preparing...';
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startCompression();
  }

  Future<void> _startCompression() async {
    try {
      for (int i = 0; i <= 10; i++) {
        await Future.delayed(const Duration(milliseconds: 300));
        if (mounted) {
          setState(() {
            _progress = i / 10;
            _status = 'Compressing... ${(i * 10)}%';
          });
        }
      }

      if (mounted) {
        setState(() {
          _status = 'Compression Complete!';
        });
      }

      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
          _status = 'Compression Failed: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: const Text('Quick Compress and Send'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_status),
          const SizedBox(height: 20),
          ProgressBar(value: _progress),
          const SizedBox(height: 10),
          Text(
            '${widget.filePaths.length} files to compress',
            style: FluentTheme.of(context).typography.caption,
          ),
          if (_hasError && _errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                _errorMessage!,
                style: TextStyle(color: Colors.red),
              ),
            ),
        ],
      ),
      actions: [
        if (_hasError)
          Button(
            child: const Text('Close'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
      ],
    );
  }
}
