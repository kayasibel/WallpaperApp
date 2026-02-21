import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/language_service.dart';
import 'services/ad_manager.dart';
import 'services/rate_service.dart';
import 'screens/themes_tab.dart';
import 'screens/wallpaper_screen.dart';
import 'screens/favorites_tab.dart';
import 'screens/settings_screen.dart';

// Global ScaffoldMessenger key
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

// Global Navigator key - reklam sonrası navigation koruma
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase'i başlat (eğer henüz başlatılmamışsa)
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  // Google Mobile Ads SDK'yı başlat
  await AdManager.initialize();

  // Reklamları önceden yükle
  AdManager().preloadAllAds();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(
    ChangeNotifierProvider(
      create: (_) => LanguageProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AniTheme: Anime Wallpapers & Icons',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: scaffoldMessengerKey,
      navigatorKey: navigatorKey,
      // Reklam sonrası state koruması için
      restorationScopeId: 'app',
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  bool _rateCheckDone = false;

  final List<Widget> _screens = const [
    ThemesTab(),
    WallpaperScreen(),
    FavoritesTab(),
  ];

  @override
  void initState() {
    super.initState();
    // Uygulama açılış sayacını artır ve rating kontrolü yap
    _initRateService();
  }

  Future<void> _initRateService() async {
    // Açılış sayacını artır
    await RateService().incrementAppOpenCount();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Rating kontrolünü sadece bir kez yap
    if (!_rateCheckDone) {
      _rateCheckDone = true;
      // Rating hatırlatmasını kontrol et (45 sn sonra gösterir)
      RateService().checkRatingPrompt(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    final List<String> titles = [
      langProvider.getText('themes'),
      langProvider.getText('wallpapers'),
      langProvider.getText('favorites'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_currentIndex]),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: _buildGlassSettingsButton(),
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.palette_sharp),
            label: langProvider.getText('themes'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.wallpaper),
            label: langProvider.getText('wallpapers'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.favorite),
            label: langProvider.getText('favorites'),
          ),
        ],
      ),
    );
  }

  // Cam efektli ayarlar butonu
  Widget _buildGlassSettingsButton() {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white24),
          ),
          child: IconButton(
            icon: const Icon(Icons.settings_outlined, size: 20),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
            padding: EdgeInsets.zero,
          ),
        ),
      ),
    );
  }
}
