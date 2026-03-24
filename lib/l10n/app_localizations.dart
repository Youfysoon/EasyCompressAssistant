import 'package:flutter/material.dart';

/// Application localization class
class AppLocalizations {
  final Locale locale;
  
  AppLocalizations(this.locale);
  
  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }
  
  static const LocalizationsDelegate<AppLocalizations> delegate = 
      _AppLocalizationsDelegate();
  
  /// All supported localized texts
  static final Map<String, Map<String, String>> _localizedValues = {
    'zh': {
      'app_name': '极速压缩助手',
      'confirm': '确定',
      'cancel': '取消',
      'save': '保存',
      'delete': '删除',
      'close': '关闭',
      'success': '成功',
      'error': '错误',
      'loading': '加载中...',
      'nav_compress': '压缩',
      'nav_decompress': '解压',
      'nav_settings': '设置',
      'compress_title': '压缩',
      'compress_select_files': '选择文件',
      'compress_select_folder': '选择目录',
      'compress_options': '选项',
      'compress_reduce_quality': '降低图片质量',
      'compress_merge': '合并为单个归档',
      'compress_format': '格式',
      'compress_start': '开始压缩',
      'compress_no_files': '未选择文件或目录',
      'compress_processing': '正在压缩...',
      'compress_complete': '压缩完成',
      'decompress_title': '解压',
      'decompress_select_archives': '选择归档',
      'decompress_select_folder': '选择目录',
      'decompress_options': '选项',
      'decompress_extract_subfolders': '解压子文件夹',
      'decompress_preserve_structure': '保留原始结构',
      'decompress_start': '开始解压',
      'decompress_no_files': '未选择归档文件',
      'decompress_processing': '正在解压...',
      'decompress_complete': '解压完成',
      'licenses':'许可证',
      'save_as':'另存为',
      'saved_to':"已保存到",
      'info': '提示',
      'share_failed': '分享失败',
      'share_error': '分享错误',
      'tip_share_windows_unsupported': 'Windows 平台暂不支持系统分享功能',
      'operation_complete': '操作完成',
      'settings_title': '设置',
      'settings_storage': '存储设置',
      'settings_auto_clean': '关闭程序时自动清理缓存',
      'settings_auto_clean_desc': '退出应用时自动清理临时文件',
      'settings_manual_clean': '手动清理缓存',
      'settings_cache_size': '当前缓存大小',
      'settings_clean': '清理',
      'settings_temp_dir': '临时目录',
      'settings_language': '语言设置',
      'settings_language_desc': '选择界面显示语言',
      'settings_about': '关于',
      'settings_version': '版本',
      'settings_description': '一款简单高效的文件压缩解压工具',
      'settings_author': '作者',
      'settings_github': '访问 GitHub',
      'settings_sponsor': '赞助',
      'settings_sponsor_desc': '点击支持作者发展此项目',
      'result_compress_complete': '压缩完成',
      'result_decompress_complete': '解压完成',
      'result_archive_file': '归档文件',
      'result_folder': '文件夹',
      'result_file_size': '大小',
      'result_path': '路径',
      'result_share': '分享',
      'result_share_unsupported': '分享 (不支持)',
      'result_save_as': '另存为',
      'result_copy_path': '复制路径',
      'result_back': '返回',
      'result_qr_code': '赞助作者',
      'result_qr_desc': '感谢您对本项目的支持！\n扫描下方二维码进行赞助',
      'result_save_qr': '保存二维码',
      'result_qr_placeholder': '二维码暂未配置',
      'result_qr_contact': '请联系作者获取赞助方式',
      'tip_copied': '已复制到剪贴板',
      'tip_saved': '已保存',
      'tip_cleaned': '缓存已清理',
      'tip_please_select_files': '请先选择文件',
      'tip_no_files_in_directory': '该目录中没有文件',
      'tip_storage_permission_required': '需要存储权限才能访问目录',
      'error_cannot_access_directory': '无法访问目录',
      'settings_licenses': '开源许可证',
      'settings_licenses_desc': '查看项目依赖的开源许可证',
      'settings_view': '查看',
    },
    'en': {
      'app_name': 'Easy Compress Assistant',
      'confirm': 'OK',
      'cancel': 'Cancel',
      'save': 'Save',
      'delete': 'Delete',
      'close': 'Close',
      'success': 'Success',
      'error': 'Error',
      'loading': 'Loading',
      'nav_compress': 'Compress',
      'nav_decompress': 'Extract',
      'nav_settings': 'Settings',
      'compress_title': 'Compress',
      'compress_select_files': 'Select Files',
      'compress_select_folder': 'Select Folder',
      'compress_options': 'Options',
      'compress_reduce_quality': 'Reduce image quality',
      'compress_merge': 'Merge into single archive',
      'compress_format': 'Format',
      'compress_start': 'Start Compression',
      'compress_no_files': 'No files or folder selected',
      'compress_processing': 'Compressing...',
      'compress_complete': 'Compression Complete',
      'decompress_title': 'Extract',
      'decompress_select_archives': 'Select Archives',
      'decompress_select_folder': 'Select Folder',
      'decompress_options': 'Options',
      'decompress_extract_subfolders': 'Extract subfolders',
      'decompress_preserve_structure': 'Preserve original structure',
      'decompress_start': 'Start Extraction',
      'decompress_no_files': 'No archive files selected',
      'decompress_processing': 'Extracting...',
      'decompress_complete': 'Extraction Complete',
      'licenses':'Licenses',
      'save_as':'Save As',
      'saved_to':"Saved to",
      'info': 'Info',
      'share_failed': 'Share Failed',
      'share_error': 'Share Error',
      'tip_share_windows_unsupported': 'Sharing is not supported on Windows',
      'operation_complete': 'Operation Complete',
      'settings_title': 'Settings',
      'settings_storage': 'Storage Settings',
      'settings_auto_clean': 'Auto clean cache on exit',
      'settings_auto_clean_desc': 'Automatically clean temp files when app exits',
      'settings_manual_clean': 'Manual Clean Cache',
      'settings_cache_size': 'Current cache size',
      'settings_clean': 'Clean',
      'settings_temp_dir': 'Temp Directory',
      'settings_language': 'Language Settings',
      'settings_language_desc': 'Select interface language',
      'settings_about': 'About',
      'settings_version': 'Version',
      'settings_description': 'A simple and efficient file compression tool',
      'settings_author': 'Author',
      'settings_github': 'Visit GitHub',
      'settings_sponsor': 'Sponsor',
      'settings_sponsor_desc': 'Click to support the project',
      'result_compress_complete': 'Compression Complete',
      'result_decompress_complete': 'Extraction Complete',
      'result_archive_file': 'Archive File',
      'result_folder': 'Folder',
      'result_file_size': 'Size',
      'result_path': 'Path',
      'result_share': 'Share',
      'result_share_unsupported': 'Share (Unsupported)',
      'result_save_as': 'Save As',
      'result_copy_path': 'Copy Path',
      'result_back': 'Back',
      'result_qr_code': 'Sponsor Author',
      'result_qr_desc': 'Thank you for supporting this project!\nScan the QR code to sponsor',
      'result_save_qr': 'Save QR Code',
      'result_qr_placeholder': 'QR code not configured',
      'result_qr_contact': 'Contact author for sponsorship',
      'tip_copied': 'Copied to clipboard',
      'tip_saved': 'Saved successfully',
      'tip_cleaned': 'Cache cleaned',
      'tip_please_select_files': 'Please select files first',
      'tip_no_files_in_directory': 'No files found in this directory',
      'tip_storage_permission_required': 'Storage permission is required to access directories',
      'error_cannot_access_directory': 'Cannot access directory',
      'settings_licenses': 'Open Source Licenses',
      'settings_licenses_desc': 'View open source licenses of project dependencies',
      'settings_view': 'View',
    },
  };
  
  /// Get localized text
  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }
  
  /// Shorthand for translate
  String tr(String key) => translate(key);
}

/// Localization delegate
class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();
  
  @override
  bool isSupported(Locale locale) {
    return ['zh', 'en'].contains(locale.languageCode);
  }
  
  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }
  
  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

/// Global extension for convenient access
extension AppLocalizationsExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
