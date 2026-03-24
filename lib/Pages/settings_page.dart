import 'dart:io';
import 'package:file_selector/file_selector.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../main.dart';
import '../utils/storage_settings.dart';
import '../utils/language_settings.dart';
import '../l10n/app_localizations.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _autoClean = false;
  int _cacheSize = 0;
  String _tempPath = '';
  bool _isCleaning = false;
  String _currentLanguage = 'zh';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final autoClean = await StorageSettings.getAutoCleanEnabled();
    final cacheSize = await StorageSettings.getCacheSize();
    final tempPath = await StorageSettings.getTempDirectory();
    final language = await LanguageSettings.getCurrentLanguage();
    
    setState(() {
      _autoClean = autoClean;
      _cacheSize = cacheSize;
      _tempPath = tempPath;
      _currentLanguage = language;
    });
  }

  Future<void> _toggleAutoClean(bool value) async {
    await StorageSettings.setAutoCleanEnabled(value);
    setState(() {
      _autoClean = value;
    });
  }

  Future<void> _changeLanguage(String? languageCode) async {
    if (languageCode == null || languageCode == _currentLanguage) return;
    
    await LanguageSettings.setLanguage(languageCode);
    setState(() {
      _currentLanguage = languageCode;
    });
    
    if (mounted) {
      final languageProvider = LanguageProvider.of(context);
      languageProvider.setLocale(LanguageSettings.getLocale(languageCode));
      
      displayInfoBar(
        context,
        builder: (context, close) => InfoBar(
          title: Text(context.l10n.tr('success')),
          content: Text('${context.l10n.tr('settings_language')}: ${LanguageSettings.getLanguageName(languageCode)}'),
          severity: InfoBarSeverity.success,
          onClose: close,
        ),
      );
    }
  }

  Future<void> _clearCache() async {
    setState(() {
      _isCleaning = true;
    });
    
    try {
      await StorageSettings.clearCache();
      final newSize = await StorageSettings.getCacheSize();
      setState(() {
        _cacheSize = newSize;
        _isCleaning = false;
      });
      
      if (mounted) {
        displayInfoBar(
          context,
          builder: (context, close) => InfoBar(
            title: Text(context.l10n.tr('success')),
            content: Text(context.l10n.tr('tip_cleaned')),
            severity: InfoBarSeverity.success,
            onClose: close,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isCleaning = false;
      });
      
      if (mounted) {
        displayInfoBar(
          context,
          builder: (context, close) => InfoBar(
            title: Text(context.l10n.tr('error')),
            content: Text('${context.l10n.tr('error')}: $e'),
            severity: InfoBarSeverity.error,
            onClose: close,
          ),
        );
      }
    }
  }

  /// Navigate to GitHub
  Future<void> _openGitHub() async {
    final uri = Uri.parse('https://github.com/Youfyyt/easy_compress_assistant');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          displayInfoBar(
            context,
            builder: (context, close) => InfoBar(
              title: Text(context.l10n.tr('error')),
              content: const Text('Cannot open link'),
              severity: InfoBarSeverity.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        displayInfoBar(
          context,
          builder: (context, close) => InfoBar(
            title: Text(context.l10n.tr('error')),
            content: Text('${context.l10n.tr('error')}: $e'),
            severity: InfoBarSeverity.error,
            onClose: close,
          ),
        );
      }
    }
  }

  /// Save sponsor QR code
  Future<void> _saveQRCode() async {
    try {
      late final ByteData byteData;
      try {
        byteData = await rootBundle.load('assets/images/qr_code.png');
      } catch (_) {
        if (mounted) {
          displayInfoBar(
            context,
            builder: (context, close) => InfoBar(
              title: Text(context.l10n.tr('result_qr_placeholder')),
              content: Text(context.l10n.tr('result_qr_contact')),
              severity: InfoBarSeverity.info,
            ),
          );
        }
        return;
      }
      
      final bytes = byteData.buffer.asUint8List();
      
      final location = await getSaveLocation(
        suggestedName: 'QR_Code.png',
      );
      
      if (location != null) {
        final file = File(location.path);
        await file.writeAsBytes(bytes);
        
        if (mounted) {
          displayInfoBar(
            context,
            builder: (context, close) => InfoBar(
              title: Text(context.l10n.tr('success')),
              content: Text('${context.l10n.tr('result_save_qr')}: ${location.path}'),
              severity: InfoBarSeverity.success,
              onClose: close,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        displayInfoBar(
          context,
          builder: (context, close) => InfoBar(
            title: Text(context.l10n.tr('error')),
            content: Text('${context.l10n.tr('error')}: $e'),
            severity: InfoBarSeverity.error,
            onClose: close,
          ),
        );
      }
    }
  }

  /// Show sponsor QR code dialog
  void _showSponsorDialog() {
    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (context) => ContentDialog(
        title: Text(l10n.tr('result_qr_code')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.tr('result_qr_desc')),
            const SizedBox(height: 16),
            FutureBuilder<Uint8List?>(
              future: () async {
                try {
                  final data = await rootBundle.load('assets/images/qr_code.png');
                  return data.buffer.asUint8List();
                } catch (_) {
                  return null;
                }
              }(),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  return Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Image.memory(
                      snapshot.data!,
                      fit: BoxFit.contain,
                    ),
                  );
                } else {
                  return Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(FluentIcons.q_r_code, size: 48, color: Colors.grey),
                        const SizedBox(height: 8),
                        Text(l10n.tr('result_qr_placeholder'), style: const TextStyle(color: Colors.grey)),
                        const SizedBox(height: 4),
                        Text(l10n.tr('result_qr_contact'), 
                          style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 8),
            const Text('Alipay / WeChat Pay', style: TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          Button(
            child: Text(l10n.tr('close')),
            onPressed: () => Navigator.pop(context),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _saveQRCode();
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(FluentIcons.save),
                const SizedBox(width: 8),
                Text(l10n.tr('result_save_qr')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Copy path to clipboard
  Future<void> _copyPath(String path) async {
    await Clipboard.setData(ClipboardData(text: path));
    if (mounted) {
      displayInfoBar(
        context,
        builder: (context, close) => InfoBar(
          title: Text(context.l10n.tr('success')),
          content: Text(context.l10n.tr('tip_copied')),
          severity: InfoBarSeverity.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final l10n = context.l10n;

    return ScaffoldPage.scrollable(
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.tr('settings_title'),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Storage settings
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            FluentIcons.save_as,
                            size: 20,
                            color: theme.accentColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l10n.tr('settings_storage'),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      ListTile(
                        leading: const Icon(FluentIcons.delete),
                        title: Text(l10n.tr('settings_auto_clean')),
                        subtitle: Text(l10n.tr('settings_auto_clean_desc')),
                        trailing: ToggleSwitch(
                          checked: _autoClean,
                          onChanged: _toggleAutoClean,
                        ),
                      ),
                      const Divider(),

                      ListTile(
                        leading: const Icon(FluentIcons.clear),
                        title: Text(l10n.tr('settings_manual_clean')),
                        subtitle: Text(
                          '${l10n.tr('settings_cache_size')}: ${StorageSettings.formatSize(_cacheSize)}',
                          style: theme.typography.caption,
                        ),
                        trailing: _isCleaning
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: ProgressRing(strokeWidth: 2),
                              )
                            : FilledButton(
                                onPressed: _cacheSize > 0 ? _clearCache : null,
                                child: Text(l10n.tr('settings_clean')),
                              ),
                      ),
                      const Divider(),

                      ListTile(
                        leading: const Icon(FluentIcons.folder),
                        title: Text(l10n.tr('settings_temp_dir')),
                        subtitle: Text(
                          _tempPath,
                          style: theme.typography.caption,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: IconButton(
                          icon: const Icon(FluentIcons.copy),
                          onPressed: () => _copyPath(_tempPath),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Language settings
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            FluentIcons.globe,
                            size: 20,
                            color: theme.accentColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l10n.tr('settings_language'),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      ListTile(
                        leading: const Icon(FluentIcons.locale_language),
                        title: Text(l10n.tr('settings_language')),
                        subtitle: Text(l10n.tr('settings_language_desc')),
                        trailing: ComboBox<String>(
                          value: _currentLanguage,
                          items: LanguageSettings.supportedLanguages.entries.map((entry) {
                            return ComboBoxItem(
                              value: entry.key,
                              child: Text(entry.value),
                            );
                          }).toList(),
                          onChanged: _changeLanguage,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // About
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            FluentIcons.info,
                            size: 20,
                            color: theme.accentColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l10n.tr('settings_about'),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        title: const Text('Easy Compress Assistant'),
                        subtitle: Text('${l10n.tr('settings_version')} 1.0.0'),
                      ),
                      ListTile(
                        title: Text(l10n.tr('settings_description')),
                      ),
                      ListTile(
                        leading: const Icon(FluentIcons.open_source),
                        title: Text('${l10n.tr('settings_author')}: Youfy'),
                        subtitle: Text(l10n.tr('settings_github')),
                        trailing: Button(
                          onPressed: _openGitHub,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(FluentIcons.open_in_new_window),
                              const SizedBox(width: 4),
                              Text(l10n.tr('settings_github')),
                            ],
                          ),
                        ),
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(FluentIcons.certificate),
                        title: Text(l10n.tr('settings_licenses')),
                        subtitle: Text(l10n.tr('settings_licenses_desc')),
                        trailing: Button(
                          onPressed: () {
                            Navigator.pushNamed(context, '/licenses');
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(FluentIcons.open_in_new_window),
                              const SizedBox(width: 4),
                              Text(l10n.tr('settings_view')),
                            ],
                          ),
                        ),
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(FluentIcons.heart),
                        title: Text(l10n.tr('settings_sponsor')),
                        subtitle: Text(l10n.tr('settings_sponsor_desc')),
                        trailing: FilledButton(
                          onPressed: _showSponsorDialog,
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(Colors.orange),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(FluentIcons.heart),
                              const SizedBox(width: 4),
                              Text(l10n.tr('settings_sponsor')),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
