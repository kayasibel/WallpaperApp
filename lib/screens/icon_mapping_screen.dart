import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps/app_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../models/theme_model.dart';
import '../services/shortcut_service.dart';
import '../services/language_service.dart';
import '../utils/custom_snackbar.dart';

class IconMappingScreen extends StatefulWidget {
  final ThemeModel theme;
  final IconPackModel iconPack;

  const IconMappingScreen({
    super.key,
    required this.theme,
    required this.iconPack,
  });

  @override
  State<IconMappingScreen> createState() => _IconMappingScreenState();
}

class _IconMappingScreenState extends State<IconMappingScreen> {
  static const String _MAPPING_KEY_PREFIX = 'icon_map_';
  static const MethodChannel _channel = MethodChannel(
    'com.example.app/shortcuts',
  );

  // Her ikon için seçilen uygulama paket adını sakla
  final Map<String, String> _iconPackageMap = {};
  // Her ikon için seçilen uygulama adını sakla (gösterim için)
  final Map<String, String> _iconAppNameMap = {};
  // Her ikon için seçilen uygulamanın ikon verisini sakla
  final Map<String, Uint8List> _iconAppIconMap = {};

  // Uygulama listesi cache (performans için)
  List<AppInfo>? _cachedApps;
  bool _isLoadingApps = false;

  @override
  void initState() {
    super.initState();
    _loadSavedMappings();
    _setupWidgetSuccessListener();
    _loadAppsInBackground(); // Uygulamaları arka planda yükle
  }

  void _setupWidgetSuccessListener() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'widgetAddedSuccess') {
        if (mounted) {
          final langProvider = Provider.of<LanguageProvider>(
            context,
            listen: false,
          );
          showCustomSnackBar(
            langProvider.getText('icon_added_success'),
            type: SnackBarType.success,
          );
        }
      }
    });
  }

  // Uygulamaları arka planda yükle (cache için)
  Future<void> _loadAppsInBackground() async {
    if (_isLoadingApps || _cachedApps != null) return;
    
    setState(() {
      _isLoadingApps = true;
    });

    try {
      final apps = await InstalledApps.getInstalledApps(
        withIcon: true,
        excludeSystemApps: false,
      );

      // Launcher aktivitesi olmayan uygulamaları filtrele
      final filteredApps = apps.where((app) => app.packageName != null).toList();
      
      // Alfabetik sırala
      filteredApps.sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));

      if (mounted) {
        setState(() {
          _cachedApps = filteredApps;
          _isLoadingApps = false;
        });
      }
    } catch (e) {
      print('Uygulamalar yüklenemedi: $e');
      if (mounted) {
        setState(() {
          _isLoadingApps = false;
        });
      }
    }
  }

  Future<void> _selectAppForIcon(String iconId) async {
    // Eğer uygulamalar henüz yüklenmediyse loading göster
    if (_cachedApps == null) {
      if (_isLoadingApps) {
        // Zaten yükleniyorsa dialog göster
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(child: CircularProgressIndicator()),
        );
        
        // Yüklenene kadar bekle
        while (_cachedApps == null && _isLoadingApps) {
          await Future.delayed(const Duration(milliseconds: 100));
        }
        
        if (mounted) {
          Navigator.pop(context); // Loading dialog'u kapat
        }
      } else {
        // Yüklenmeye başlanılmamışsa şimdi yükle
        await _loadAppsInBackground();
      }
    }

    final apps = _cachedApps;
    
    if (apps == null || apps.isEmpty) {
      final langProvider = Provider.of<LanguageProvider>(
        context,
        listen: false,
      );
      showCustomSnackBar(
        langProvider.getText('no_apps_found'),
        type: SnackBarType.info,
      );
      return;
    }

    // BottomSheet ile uygulama listesi göster (cache'ten)
    if (mounted) {
      final selectedApp = await showModalBottomSheet<AppInfo>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (bottomSheetContext) => DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) => Column(
            children: [
              // Başlık
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      Provider.of<LanguageProvider>(
                        context,
                      ).getText('select_app'),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(bottomSheetContext),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Uygulama Listesi
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: apps.length,
                  itemBuilder: (context, index) {
                    final app = apps[index];
                    return ListTile(
                      leading: app.icon != null
                          ? Image.memory(
                              app.icon!,
                              width: 40,
                              height: 40,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.android, size: 40);
                              },
                            )
                          : const Icon(Icons.android, size: 40),
                      title: Text(
                        app.name ??
                            Provider.of<LanguageProvider>(
                              context,
                              listen: false,
                            ).getText('unknown'),
                      ),
                      onTap: () {
                        Navigator.pop(bottomSheetContext, app);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );

      // Seçilen uygulamayı state'e kaydet
      if (selectedApp != null) {
        setState(() {
          _iconPackageMap[iconId] = selectedApp.packageName;
          _iconAppNameMap[iconId] = selectedApp.name ?? selectedApp.packageName;
          // Uygulama ikonunu da kaydet
          if (selectedApp.icon != null) {
            _iconAppIconMap[iconId] = selectedApp.icon!;
          }
        });
        // Eşleştirmeyi kalıcı olarak kaydet
        await _saveMapping(iconId, selectedApp.packageName);
      }
    }
  }

  // Eşleştirmeyi SharedPreferences'a kaydet
  Future<void> _saveMapping(String iconId, String packageName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_MAPPING_KEY_PREFIX + iconId, packageName);
      print('Eşleştirme kaydedildi: $iconId -> $packageName');
    } catch (e) {
      print('Eşleştirme kaydedilemedi: $e');
    }
  }

  // Kaydedilmiş eşleştirmeleri yükle + Akıllı Otomatik Eşleştirme
  Future<void> _loadSavedMappings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      for (var iconName in widget.iconPack.iconNames) {
        final key = _MAPPING_KEY_PREFIX + iconName;
        final packageName = prefs.getString(key);

        // ADIM 1: Kullanıcının manuel seçimi var mı kontrol et
        if (packageName != null && packageName.isNotEmpty) {
          try {
            // Uygulama bilgilerini al
            final appInfo = await InstalledApps.getAppInfo(packageName);

            if (appInfo != null) {
              setState(() {
                _iconPackageMap[iconName] = packageName;
                _iconAppNameMap[iconName] = appInfo.name ?? packageName;

                // İkonu yükle
                if (appInfo.icon != null) {
                  _iconAppIconMap[iconName] = appInfo.icon!;
                }
              });
              print('Eşleştirme yüklendi (manuel): $iconName -> $packageName');
            }
          } catch (e) {
            print('Uygulama bilgisi alınamadı ($packageName): $e');
          }
        } else {
          // ADIM 2 & 3: Manuel seçim yok, Akıllı Otomatik Eşleştirme dene
          // İkon ismini paket adı olarak kullan
          final potentialPackageName = iconName;
          
          try {
            // Cihazda bu paket adıyla uygulama yüklü mü kontrol et
            final appInfo = await InstalledApps.getAppInfo(potentialPackageName);

            if (appInfo != null) {
              // ADIM 3: Yüklü! Otomatik olarak eşleştir
              setState(() {
                _iconPackageMap[iconName] = potentialPackageName;
                _iconAppNameMap[iconName] = appInfo.name ?? potentialPackageName;

                // İkonu yükle
                if (appInfo.icon != null) {
                  _iconAppIconMap[iconName] = appInfo.icon!;
                }
              });
              print('Otomatik eşleştirme başarılı: $iconName -> $potentialPackageName');
            } else {
              print('Otomatik eşleştirme yapılamadı: $iconName (uygulama yüklü değil)');
            }
          } catch (e) {
            // Uygulama yüklü değil veya erişim hatası
            print('Otomatik eşleştirme denemesi başarısız: $iconName -> $e');
          }
        }
      }
    } catch (e) {
      print('Eşleştirmeler yüklenemedi: $e');
    }
  }

  Future<void> _applyIcon(String iconName, String iconUrl) async {
    final langProvider = Provider.of<LanguageProvider>(context, listen: false);
    final packageName = _iconPackageMap[iconName];
    final appName = _iconAppNameMap[iconName];

    if (packageName == null || packageName.isEmpty) {
      showCustomSnackBar(
        langProvider.getText('select_app_first'),
        type: SnackBarType.info,
      );
      return;
    }

    // İkon indirme işlemi
    File? iconFile;
    try {
      // İkon görselini indir
      final response = await http.get(Uri.parse(iconUrl));

      if (response.statusCode != 200) {
        final langProvider = Provider.of<LanguageProvider>(
          context,
          listen: false,
        );
        throw Exception(langProvider.getText('icon_download_failed'));
      }

      // KALICI dizine kaydet (getApplicationDocumentsDirectory kullan)
      final appDir = await getApplicationDocumentsDirectory();
      final iconsDir = Directory('${appDir.path}/widget_icons');
      if (!await iconsDir.exists()) {
        await iconsDir.create(recursive: true);
      }

      iconFile = File(
        '${iconsDir.path}/widget_icon_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await iconFile.writeAsBytes(response.bodyBytes);

      print('İkon başarıyla kalıcı dizine kaydedildi: ${iconFile.path}');
    } catch (e) {
      print('İkon indirme hatası: $e');
      return;
    }

    // ShortcutService kullanarak WIDGET oluştur (ROZET YOK!)
    final shortcutService = ShortcutService();
    await shortcutService.createAppWidget(
      appName: appName ?? packageName,
      packageName: packageName,
      iconPath: iconFile.path,
    );

    // NOT: İkon dosyasını SİLME! Widget'ın buna ihtiyacı var.
    // Dosya kalıcı dizinde kalacak.
    print('İkon dosyası widget için saklandı: ${iconFile.path}');

    // Başarı mesajı Android callback'ten gelecek (kullanıcı "Add" seçerse)
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    return Scaffold(
      appBar: AppBar(title: Text(langProvider.getText('icon_mapping_title'))),
      body: widget.iconPack.icons.isEmpty
          ? Center(child: Text(langProvider.getText('no_icons_in_theme')))
          : ListView.builder(
              itemCount: widget.iconPack.iconCount,
              itemBuilder: (context, index) {
                final iconName = widget.iconPack.iconNames[index];
                final iconUrl = widget.iconPack.icons[iconName]!;
                final selectedPackage = _iconPackageMap[iconName];
                final selectedAppName = _iconAppNameMap[iconName];
                final selectedAppIcon = _iconAppIconMap[iconName];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        // Simge görseli (Sol)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CachedNetworkImage(
                            imageUrl: iconUrl,
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              width: 56,
                              height: 56,
                              color: Colors.grey[800],
                              child: const Center(
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              width: 56,
                              height: 56,
                              color: Colors.grey[800],
                              child: const Icon(Icons.error, size: 24),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Butonlar (Sağ)
                        Expanded(
                          child: Row(
                            children: [
                              // Uygulama Seç Butonu
                              Expanded(
                                child: SizedBox(
                                  height: 56,
                                  child: OutlinedButton(
                                    onPressed: () => _selectAppForIcon(iconName),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                    ),
                                    child: selectedAppIcon != null
                                        ? Image.memory(
                                            selectedAppIcon,
                                            width: 40,
                                            height: 40,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                                  return Text(
                                                    langProvider.getText(
                                                      'select_app',
                                                    ),
                                                  );
                                                },
                                          )
                                        : Text(
                                            langProvider.getText('select_app'),
                                            style: const TextStyle(fontSize: 13),
                                          ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Simgeyi Uygula Butonu
                              Expanded(
                                child: SizedBox(
                                  height: 56,
                                  child: ElevatedButton(
                                    onPressed: () => _applyIcon(iconName, iconUrl),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                    ),
                                    child: Text(
                                      langProvider.getText('apply'),
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
