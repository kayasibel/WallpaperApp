import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../models/theme_model.dart';
import '../services/shortcut_service.dart';
import '../services/favorite_service.dart';
import 'icon_mapping_screen.dart';

class ThemeDetailScreen extends StatefulWidget {
  final ThemeModel theme;

  const ThemeDetailScreen({
    super.key,
    required this.theme,
  });

  @override
  State<ThemeDetailScreen> createState() => _ThemeDetailScreenState();
}

class _ThemeDetailScreenState extends State<ThemeDetailScreen> {
  final FavoriteService _favoriteService = FavoriteService();
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    final isFav = await _favoriteService.isFavoriteTheme(widget.theme.id);
    setState(() {
      _isFavorite = isFav;
    });
  }

  Future<void> _toggleFavorite() async {
    final newStatus = await _favoriteService.toggleFavoriteTheme(widget.theme);
    setState(() {
      _isFavorite = newStatus;
    });

    // Kullanıcıya geri bildirim
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isFavorite ? 'Favorilere eklendi' : 'Favorilerden çıkarıldı',
        ),
        duration: const Duration(seconds: 1),
        backgroundColor: _isFavorite ? Colors.green : Colors.grey,
      ),
    );
  }

  void _handleApplyOrPurchase() {
    if (widget.theme.isPremium) {
      // Premium tema için satın alma işlemi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.theme.title} için premium üyelik gerekli!'),
          duration: const Duration(seconds: 2),
          action: SnackBarAction(
            label: 'Tamam',
            onPressed: () {},
          ),
        ),
      );
    } else {
      // IconMappingScreen'e geçiş yap
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => IconMappingScreen(theme: widget.theme),
        ),
      );
    }
  }

  void _applyWallpaper() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Duvar kağıdı uygulandı simülasyonu'),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _handleOldApplyOrPurchase() {
    if (widget.theme.isPremium) {
      // Premium tema için satın alma işlemi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.theme.title} için premium üyelik gerekli!'),
          duration: const Duration(seconds: 2),
          action: SnackBarAction(
            label: 'Tamam',
            onPressed: () {},
          ),
        ),
      );
    } else {
      // Ücretsiz tema için indirme işlemi ve uygulama adımları
      showModalBottomSheet(
        context: context,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        builder: (bottomSheetContext) => Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Başlık
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tema Uygulama Adımları',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(bottomSheetContext),
                    icon: const Icon(Icons.close),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              // Adımlar
              _buildStep(
                '1',
                'Tema dosyası cihazınıza indirilecektir.',
              ),
              const SizedBox(height: 12),
              _buildStep(
                '2',
                'Cihazınızın Ayarlar > Ana Ekran > Temalar bölümüne gidin.',
              ),
              const SizedBox(height: 12),
              _buildStep(
                '3',
                'İndirilen temayı listeden seçin ve "Uygula" butonuna tıklayın.',
              ),
              const SizedBox(height: 12),
              _buildStep(
                '4',
                'Tema otomatik olarak ana ekranınıza uygulanacaktır.',
              ),
              const SizedBox(height: 24),
              // İndir Butonu
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    // Alt pencereyi kapat
                    Navigator.pop(bottomSheetContext);
                    
                    // Kısayol oluşturma dialog'unu göster
                    _showShortcutDialog();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Uygula',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildStep(String number, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[300],
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  // Kısayol oluşturma dialog'u
  void _showShortcutDialog() {
    final TextEditingController appNameController = TextEditingController(text: 'My Theme Shortcut');
    final TextEditingController packageNameController = TextEditingController(text: 'com.example.wallpaper_theme_app');

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Kısayol Oluştur'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: appNameController,
              decoration: const InputDecoration(
                labelText: 'Kısayol Adı',
                hintText: 'Örn: Chrome',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: packageNameController,
              decoration: const InputDecoration(
                labelText: 'Paket Adı',
                hintText: 'Örn: com.android.chrome',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
            },
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Dialog'u kapat
              Navigator.pop(dialogContext);

              final appName = appNameController.text.trim();
              final packageName = packageNameController.text.trim();

              if (appName.isEmpty || packageName.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Lütfen tüm alanları doldurun!'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }

              // Başlangıç mesajı
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
                final response = await http.get(Uri.parse(widget.theme.previewImageUrl));
                
                if (response.statusCode != 200) {
                  throw Exception('İkon indirilemedi: HTTP ${response.statusCode}');
                }

                // Geçici dizine kaydet
                final tempDir = await getTemporaryDirectory();
                iconFile = File('${tempDir.path}/temp_icon.png');
                await iconFile.writeAsBytes(response.bodyBytes);

                print('İkon başarıyla indirildi: ${iconFile.path}');
              } catch (e) {
                print('İkon indirme hatası: $e');
                if (context.mounted) {
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
              if (context.mounted) {
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
                appName: appName,
                packageName: packageName,
                iconPath: iconFile.path, // Yerel dosya yolu
              );

              // Geçici dosyayı sil
              if (success && iconFile.existsSync()) {
                try {
                  await iconFile.delete();
                  print('Geçici ikon dosyası silindi');
                } catch (e) {
                  print('Geçici dosya silinemedi: $e');
                }
              }

              // Sonuç mesajı
              if (context.mounted) {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Kısayol Başarıyla Ana Ekrana Eklendi!'
                          : 'Kısayol Oluşturulamadı!',
                    ),
                    duration: const Duration(seconds: 2),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            child: const Text('Oluştur'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Tam Ekran Önizleme Görseli
            Stack(
              children: [
                // Ana Görsel
                CachedNetworkImage(
                  imageUrl: widget.theme.previewImageUrl,
                  fit: BoxFit.cover,
                  height: MediaQuery.of(context).size.height * 0.6,
                  width: double.infinity,
                  placeholder: (context, url) => Container(
                    height: MediaQuery.of(context).size.height * 0.6,
                    color: Colors.grey[900],
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: MediaQuery.of(context).size.height * 0.6,
                    color: Colors.grey[900],
                    child: const Icon(
                      Icons.error,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                ),
                // Geri Butonu
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.black54,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        IconButton(
                          onPressed: _toggleFavorite,
                          icon: Icon(
                            _isFavorite ? Icons.favorite : Icons.favorite_border,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.black54,
                            foregroundColor: _isFavorite ? Colors.red : Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Premium Badge
                if (widget.theme.isPremium)
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 8,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star,
                            size: 16,
                            color: Colors.black,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'PREMIUM',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            // Detay Bilgileri
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tema Başlığı
                    Text(
                      widget.theme.title,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // İkon Sayısı
                    Row(
                      children: [
                        Icon(
                          Icons.apps,
                          size: 20,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${widget.theme.iconCount} İkon',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Açıklama
                    const Text(
                      'Açıklama',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.theme.isPremium
                          ? 'Bu premium tema paketi, ${widget.theme.iconCount} adet özenle tasarlanmış ikon içerir. Premium özelliklerden yararlanmak için üyelik gereklidir.'
                          : 'Bu ücretsiz tema paketi, ${widget.theme.iconCount} adet özenle tasarlanmış ikon içerir. Hemen uygulayarak kullanmaya başlayabilirsiniz.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[400],
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Duvar Kağıdı Uygula Butonu
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: _applyWallpaper,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.wallpaper,
                              size: 20,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Duvar Kağıdı Uygula',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Ana Buton - Uygulama Simgeleri Ayarla
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _handleApplyOrPurchase,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.theme.isPremium
                              ? Colors.amber
                              : Theme.of(context).colorScheme.primary,
                          foregroundColor: widget.theme.isPremium
                              ? Colors.black
                              : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              widget.theme.isPremium
                                  ? Icons.shopping_cart
                                  : Icons.apps,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              widget.theme.isPremium
                                  ? 'Premium Üye Ol'
                                  : 'Uygulama Simgeleri Ayarla',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Ek Bilgi
                    if (widget.theme.isPremium)
                      Center(
                        child: Text(
                          'Premium temaları uygulamak için üye olun',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
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
    );
  }
}
