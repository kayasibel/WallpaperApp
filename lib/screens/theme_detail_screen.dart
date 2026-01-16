import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../models/theme_model.dart';
import '../services/favorite_service.dart';
import '../services/theme_service.dart';
import '../services/language_service.dart';
import '../utils/custom_snackbar.dart';
import '../utils/cloudinary_helper.dart';
import 'icon_mapping_screen.dart';

class ThemeDetailScreen extends StatefulWidget {
  final ThemeModel theme;

  const ThemeDetailScreen({super.key, required this.theme});

  @override
  State<ThemeDetailScreen> createState() => _ThemeDetailScreenState();
}

class _ThemeDetailScreenState extends State<ThemeDetailScreen> {
  final FavoriteService _favoriteService = FavoriteService();
  final ThemeService _themeService = ThemeService();
  bool _isFavorite = false;
  bool _showUI = true;

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
  }

  /// İkonları görüntüle - IconMappingScreen'e yönlendir
  Future<void> _navigateToIconMapping() async {
    final langProvider = Provider.of<LanguageProvider>(context, listen: false);

    // İkon paketini Firestore'dan getir
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final iconPack = await _themeService.getIconPackById(
      widget.theme.iconPackId,
    );

    if (!mounted) return;
    Navigator.pop(context); // Loading dialog'u kapat

    if (iconPack == null || iconPack.icons.isEmpty) {
      showCustomSnackBar(
        langProvider.getText('no_icons_in_theme'),
        type: SnackBarType.info,
      );
      return;
    }

    // IconMappingScreen'e yönlendir ve iconPack'i gönder
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              IconMappingScreen(theme: widget.theme, iconPack: iconPack),
        ),
      );
    }
  }

  /// Duvar kağıdını uygula - wallpaperUrl kullan
  Future<void> _applyWallpaper() async {
    final langProvider = Provider.of<LanguageProvider>(context, listen: false);

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // wallpaperUrl kullan (previewImage DEĞİL!)
      final response = await http.get(Uri.parse(widget.theme.wallpaperUrl));
      if (response.statusCode != 200) {
        throw Exception(langProvider.getText('image_download_failed'));
      }

      final tempDir = await getTemporaryDirectory();
      final file = File(
        '${tempDir.path}/wallpaper_theme_${widget.theme.id}.jpg',
      );
      await file.writeAsBytes(response.bodyBytes);

      const platform = MethodChannel('com.example.app/wallpaper');
      await platform.invokeMethod('openWallpaperIntent', {
        'imagePath': file.path,
      });

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted && Navigator.canPop(context)) Navigator.pop(context);
      print('❌ Wallpaper uygulama hatası: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => setState(() => _showUI = !_showUI),
        child: Stack(
          children: [
            // 1. KATMAN: TAM EKRAN GÖRSEL - AKIİLLI KIRPMA (previewImage kullan)
            Positioned.fill(
              child: CachedNetworkImage(
                imageUrl: CloudinaryHelper.getDetailOptimized(
                  widget.theme.previewImage,
                ),
                fit: BoxFit.contain,
                alignment: Alignment.center,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
                errorWidget: (context, url, error) =>
                    const Icon(Icons.error, color: Colors.white),
              ),
            ),

            // 2. KATMAN: �ST BUTONLAR (Geri ve Favori)
            Positioned(
              top: statusBarHeight + 10,
              left: 20,
              right: 20,
              child: AnimatedOpacity(
                opacity: _showUI ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildGlassCircleButton(
                      icon: Icons.arrow_back,
                      onTap: () => Navigator.pop(context),
                    ),
                    _buildGlassCircleButton(
                      icon: _isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      iconColor: _isFavorite ? Colors.red : Colors.white,
                      onTap: _toggleFavorite,
                    ),
                  ],
                ),
              ),
            ),

            // 3. KATMAN: ALT PANEL (Cam Efekti ve Aksiyonlar)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              bottom: _showUI ? (bottomPadding + 30) : -150,
              left: 20,
              right: 20,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Row(
                      children: [
                        // SOL BUTON: Duvar Ka��d�
                        Expanded(
                          child: _buildActionButton(
                            label: langProvider.getText('wallpaper_btn'),
                            icon: Icons.wallpaper,
                            onTap: _applyWallpaper,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // SAĞ BUTON: İkonlar (isPremium kaldırıldı)
                        Expanded(
                          child: _buildActionButton(
                            label: langProvider.getText('icons_btn'),
                            icon: Icons.apps,
                            onTap: _navigateToIconMapping,
                            isPrimary: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Cam efektli yuvarlak buton helper
  Widget _buildGlassCircleButton({
    required IconData icon,
    required VoidCallback onTap,
    Color iconColor = Colors.white,
  }) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white24),
          ),
          child: IconButton(
            icon: Icon(icon, color: iconColor, size: 20),
            onPressed: onTap,
          ),
        ),
      ),
    );
  }

  // Alt paneldeki aksiyon butonu helper
  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: isPrimary
                ? Colors.white.withOpacity(0.2)
                : Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(24),
            border: isPrimary ? Border.all(color: Colors.white24) : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
