// Import Fluent UI package for modern UI creation
import 'package:fluent_ui/fluent_ui.dart';
import 'Pages/compress_page.dart';
import 'Pages/decompress_page.dart';
import 'Pages/settings_page.dart';
import 'Pages/result_page.dart';
import 'Pages/license_page.dart';
import 'utils/notification_util.dart';
import 'utils/app_data_util.dart';
import 'utils/storage_settings.dart';
import 'utils/language_settings.dart';
import 'l10n/app_localizations.dart';
import 'widgets/responsive_navigation.dart';

/// Application entry point
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await NotificationUtil.initialize();
  } catch (e) {
    debugPrint('Notification initialization failed: $e');
  }
  
  try {
    await AppDataUtil.requestStoragePermission();
  } catch (e) {
    debugPrint('Storage permission request failed: $e');
  }

  runApp(const MyApp());
}

/// Global language state management
/// 
/// This class provides a way to pass language settings throughout the widget tree
/// and notifies dependents when the locale changes.
class LanguageProvider extends InheritedWidget {
  final Locale locale;
  final Function(Locale) setLocale;

  const LanguageProvider({
    super.key,
    required this.locale,
    required this.setLocale,
    required super.child,
  });

  /// Static method to get the nearest LanguageProvider instance
  static LanguageProvider of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<LanguageProvider>()!;
  }

  @override
  bool updateShouldNotify(LanguageProvider oldWidget) {
    return oldWidget.locale != locale;
  }
}

/// Main application state management class
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  // Default to Simplified Chinese
  Locale _locale = const Locale('zh', 'CN');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadSavedLanguage();
  }

  /// Load saved language settings from local storage
  Future<void> _loadSavedLanguage() async {
    final languageCode = await LanguageSettings.getCurrentLanguage();
    setState(() {
      _locale = LanguageSettings.getLocale(languageCode);
    });
  }

  /// Update the language used by the app
  void _setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Automatically clean cache when app closes (if enabled)
    if (state == AppLifecycleState.detached) {
      StorageSettings.autoCleanIfEnabled();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LanguageProvider(
      locale: _locale,
      setLocale: _setLocale,
      child: FluentApp(
        title: 'Easy Compress Assistant',
        debugShowCheckedModeBanner: false,
        
        // Language configuration
        locale: _locale,
        supportedLocales: const [
          Locale('zh', 'CN'),
          Locale('en', 'US'),
        ],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          DefaultMaterialLocalizations.delegate,
          DefaultWidgetsLocalizations.delegate,
        ],
        
        // Light theme configuration with MiSans font family
        theme: FluentThemeData(
          brightness: Brightness.light,
          accentColor: Colors.blue,
          fontFamily: 'MiSans',
          typography: Typography.raw(
            display: const TextStyle(fontFamily: 'MiSans', fontSize: 48, color: Colors.black),
            titleLarge: const TextStyle(fontFamily: 'MiSans', fontSize: 28, color: Colors.black),
            title: const TextStyle(fontFamily: 'MiSans', fontSize: 20, color: Colors.black),
            subtitle: const TextStyle(fontFamily: 'MiSans', fontSize: 16, color: Colors.black),
            bodyLarge: const TextStyle(fontFamily: 'MiSans', fontSize: 16, color: Colors.black),
            body: const TextStyle(fontFamily: 'MiSans', fontSize: 14, color: Colors.black),
            caption: const TextStyle(fontFamily: 'MiSans', fontSize: 12, color: Colors.grey),
          ),
        ),
        
        // Dark theme configuration with MiSans font family
        darkTheme: FluentThemeData(
          brightness: Brightness.dark,
          accentColor: Colors.blue,
          fontFamily: 'MiSans',
          typography: Typography.raw(
            display: const TextStyle(fontFamily: 'MiSans', fontSize: 48, color: Colors.white),
            titleLarge: const TextStyle(fontFamily: 'MiSans', fontSize: 28, color: Colors.white),
            title: const TextStyle(fontFamily: 'MiSans', fontSize: 20, color: Colors.white),
            subtitle: const TextStyle(fontFamily: 'MiSans', fontSize: 16, color: Colors.white),
            bodyLarge: const TextStyle(fontFamily: 'MiSans', fontSize: 16, color: Colors.white),
            body: const TextStyle(fontFamily: 'MiSans', fontSize: 14, color: Colors.white),
            caption: const TextStyle(fontFamily: 'MiSans', fontSize: 12, color: Colors.grey),
          ),
        ),
        
        home: const MainApp(),
        routes: {
          '/settings': (context) => const SettingsPage(),
          // Result page route with arguments
          '/result': (context) {
            final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
            return ResultPage(
              path: args?['path'] ?? '',
              isArchive: args?['isArchive'] ?? true,
              operationTitle: args?['operationTitle'] ?? 'Done',
            );
          },
          // License page route
          '/licenses': (context) => const LicensePage(),
        },
      ),
    );
  }
}

/// Main application interface with responsive navigation
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    
    return ResponsiveNavigation(
      title: l10n.tr('app_name'),
      items: [
        NavItem(
          icon: FluentIcons.save,
          label: l10n.tr('nav_compress'),
          body: const CompressPage(),
        ),
        NavItem(
          icon: FluentIcons.open_folder_horizontal,
          label: l10n.tr('nav_decompress'),
          body: const DecompressPage(),
        ),
        NavItem(
          icon: FluentIcons.settings,
          label: l10n.tr('nav_settings'),
          body: const SettingsPage(),
        ),
      ],
    );
  }
}