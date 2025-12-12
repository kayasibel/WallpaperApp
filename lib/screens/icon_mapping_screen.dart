import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps/app_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/theme_model.dart';
import '../services/shortcut_service.dart';

class IconMappingScreen extends StatefulWidget {
  final ThemeModel theme;

  const IconMappingScreen({
    super.key,
    required this.theme,
  });

  @override
  State<IconMappingScreen> createState() => _IconMappingScreenState();
}

class _IconMappingScreenState extends State<IconMappingScreen> {
  static const String _MAPPING_KEY_PREFIX = 'icon_map_';
  
  // Her ikon için seçilen uygulama paket adını sakla
  final Map<String, String> _iconPackageMap = {};
  // Her ikon için seçilen uygulama adını sakla (gösterim için)
  final Map<String, String> _iconAppNameMap = {};
  // Her ikon için seçilen uygulamanın ikon verisini sakla
  final Map<String, Uint8List> _iconAppIconMap = {};

  @override
  void initState() {
    super.initState();
    _loadSavedMappings();
  }

  Future<void> _selectAppForIcon(String iconId) async {
    // Yükleniyor göstergesi
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    List<AppInfo> apps = [];
    try {
      // Kurulu uygulamaları al (ikonlar ve sistem uygulamaları dahil)
      apps = await InstalledApps.getInstalledApps(
        withIcon: true,
        excludeSystemApps: false,
      );
      
      // Launcher aktivitesi olmayan uygulamaları filtrele (manuel filtreleme)
      apps = apps.where((app) => app.packageName != null).toList();
    } catch (e) {
      print('Uygulamalar alınamadı: $e');
      if (mounted) {
        Navigator.pop(context); // Loading dialog'u kapat
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Uygulamalar yüklenemedi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    if (mounted) {
      Navigator.pop(context); // Loading dialog'u kapat
    }

    if (apps.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hiç uygulama bulunamadı!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Uygulamaları alfabetik sırala
    apps.sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));

    // BottomSheet ile uygulama listesi göster
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
                    const Text(
                      'Uygulama Seç',
                      style: TextStyle(
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
                      title: Text(app.name ?? 'Bilinmeyen'),
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

  // Kaydedilmiş eşleştirmeleri yükle
  Future<void> _loadSavedMappings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      for (var icon in widget.theme.icons) {
        final key = _MAPPING_KEY_PREFIX + icon.id;
        final packageName = prefs.getString(key);
        
        if (packageName != null && packageName.isNotEmpty) {
          try {
            // Uygulama bilgilerini al
            final appInfo = await InstalledApps.getAppInfo(packageName);
            
            if (appInfo != null) {
              setState(() {
                _iconPackageMap[icon.id] = packageName;
                _iconAppNameMap[icon.id] = appInfo.name ?? packageName;
                
                // İkonu yükle
                if (appInfo.icon != null) {
                  _iconAppIconMap[icon.id] = appInfo.icon!;
                }
              });
              print('Eşleştirme yüklendi: ${icon.id} -> $packageName');
            }
          } catch (e) {
            print('Uygulama bilgisi alınamadı ($packageName): $e');
          }
        }
      }
    } catch (e) {
      print('Eşleştirmeler yüklenemedi: $e');
    }
  }

  Future<void> _applyIcon(ThemeIcon icon) async {
    final packageName = _iconPackageMap[icon.id];
    final appName = _iconAppNameMap[icon.id];
    
    if (packageName == null || packageName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen önce bir uygulama seçin!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // İkon indiriliyor mesajı
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('İkon indiriliyor...'),
        duration: Duration(seconds: 3),
      ),
    );

    // İkon indirme işlemi
    File? iconFile;
    try {
      // İkon görselini indir
      final response = await http.get(Uri.parse(icon.iconUrl));
      
      if (response.statusCode != 200) {
        throw Exception('İkon indirilemedi: HTTP ${response.statusCode}');
      }

      // Geçici dizine kaydet
      final tempDir = await getTemporaryDirectory();
      iconFile = File('${tempDir.path}/temp_icon_${icon.id}.png');
      await iconFile.writeAsBytes(response.bodyBytes);

      print('İkon başarıyla indirildi: ${iconFile.path}');
    } catch (e) {
      print('İkon indirme hatası: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('İkon indirilemedi: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    // Kısayol oluşturma mesajı
    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kısayol Oluşturuluyor...'),
          duration: Duration(seconds: 2),
        ),
      );
    }

    // ShortcutService kullanarak kısayol oluştur
    final shortcutService = ShortcutService();
    final success = await shortcutService.createAppShortcut(
      appName: appName ?? packageName,
      packageName: packageName,
      iconPath: iconFile.path,
    );

    // Geçici dosyayı sil (başarılı veya başarısız olsun)
    try {
      if (iconFile.existsSync()) {
        await iconFile.delete();
        print('Geçici ikon dosyası silindi');
      }
    } catch (e) {
      print('Geçici dosya silinemedi: $e');
    }

    // Sonuç mesajı
    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Simge başarıyla uygulandı!'
                : 'Simge uygulanamadı.',
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.theme.title} - Simge Eşleştirme'),
      ),
      body: widget.theme.icons.isEmpty
          ? const Center(
              child: Text('Bu temada simge bulunmuyor'),
            )
          : ListView.builder(
              itemCount: widget.theme.icons.length,
              itemBuilder: (context, index) {
                final icon = widget.theme.icons[index];
                final selectedPackage = _iconPackageMap[icon.id];
                final selectedAppName = _iconAppNameMap[icon.id];
                final selectedAppIcon = _iconAppIconMap[icon.id];

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    // Simge görseli
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: icon.iconUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 50,
                          height: 50,
                          color: Colors.grey[800],
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 50,
                          height: 50,
                          color: Colors.grey[800],
                          child: const Icon(Icons.error, size: 20),
                        ),
                      ),
                    ),
                    // Simge adı
                    title: Text(
                      icon.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: selectedAppName == null
                        ? const Text(
                            'Uygulama seçilmedi',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          )
                        : null,
                    // Düğmeler
                    trailing: SizedBox(
                      width: 200,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Uygulama Seç
                          Expanded(
                            child: SizedBox(
                              height: 40,
                              child: OutlinedButton(
                                onPressed: () => _selectAppForIcon(icon.id),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                ),
                                child: selectedAppIcon != null
                                    ? Image.memory(
                                        selectedAppIcon,
                                        width: 24,
                                        height: 24,
                                        errorBuilder: (context, error, stackTrace) {
                                          return const Text('Seç');
                                        },
                                      )
                                    : const Text('Seç'),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Simgeyi Uygula
                          Expanded(
                            child: SizedBox(
                              height: 40,
                              child: ElevatedButton(
                                onPressed: () => _applyIcon(icon),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                ),
                                child: const Text('Uygula'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
