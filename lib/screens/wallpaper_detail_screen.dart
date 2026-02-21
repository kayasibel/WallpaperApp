import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../models/wallpaper_model.dart';
import '../services/favorite_service.dart';
import '../services/download_service.dart';
import '../services/language_service.dart';
import '../services/ad_manager.dart';
import '../utils/custom_snackbar.dart';

class WallpaperDetailScreen extends StatefulWidget {
  final WallpaperModel wallpaper;
  final int index;

  const WallpaperDetailScreen({
    super.key,
    required this.wallpaper,
    required this.index,
  });

  @override
  State<WallpaperDetailScreen> createState() => _WallpaperDetailScreenState();
}

class _WallpaperDetailScreenState extends State<WallpaperDetailScreen> {
  final FavoriteService _favoriteService = FavoriteService();
  final DownloadService _downloadService = DownloadService();
  final AdManager _adManager = AdManager();
  bool _showUI = true;
  bool _isFavorite = false;
  bool _isAdLoading = false;

  @override
  void initState() {
    super.initState();
    _loadFavoriteStatus();

    // Reklamı sayfa açılır açılmaz arka planda yükle
    _adManager.ensureRewardedAdLoaded();
  }

  // Favori durumunu yükle
  Future<void> _loadFavoriteStatus() async {
    final isFav = await _favoriteService.isFavorite(widget.wallpaper.id);
    setState(() {
      _isFavorite = isFav;
    });
  }

  // Favori durumunu değiştir
  Future<void> _toggleFavorite() async {
    final newStatus = await _favoriteService.toggleFavorite(
      widget.wallpaper.id,
    );
    setState(() {
      _isFavorite = newStatus;
    });
  }

  // Duvar kağıdını indir
  Future<void> _downloadWallpaper() async {
    final langProvider = Provider.of<LanguageProvider>(context, listen: false);

    // Loading göster
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final success = await _downloadService.downloadAndSaveWallpaper(
      widget.wallpaper.imageUrl,
    );

    // Loading kapat
    if (mounted) Navigator.pop(context);

    // Kullanıcıya feedback ver
    if (mounted) {
      if (success) {
        showCustomSnackBar(
          langProvider.getText('wallpaper_downloaded'),
          type: SnackBarType.success,
        );
      } else {
        showCustomSnackBar(
          langProvider.getText('download_failed'),
          type: SnackBarType.error,
        );
      }
    }
  }

  /// Reklam gösterip ardından duvar kağıdını uygular
  Future<void> _showRewardedAdThenApplyWallpaper() async {
    final langProvider = Provider.of<LanguageProvider>(context, listen: false);

    // Reklam hazır mı kontrol et
    if (!_adManager.isRewardedReady) {
      setState(() => _isAdLoading = true);

      // Kullanıcıya loading göster
      showCustomSnackBar(
        langProvider.getText('ad_loading'),
        type: SnackBarType.info,
      );

      // Timeout ile reklam yüklemesini bekle (max 4 saniye)
      final adReady = await _adManager.waitForRewardedAd();

      if (!mounted) return;
      setState(() => _isAdLoading = false);

      if (!adReady) {
        showCustomSnackBar(
          langProvider.getText('ad_not_ready'),
          type: SnackBarType.error,
        );
        return;
      }
    }

    // Reklam göster ve callback'te duvar kağıdını uygula
    _adManager.showRewardedAd(
      onUserEarnedReward: () {
        // Kullanıcı ödülü kazandı, duvar kağıdını uygula
        _applyWallpaper();
      },
      onAdDismissed: () {
        // Reklam kapatıldı ama ödül verilmedi
        if (mounted) {
          showCustomSnackBar(
            langProvider.getText('ad_reward_not_earned'),
            type: SnackBarType.info,
          );
        }
      },
      onAdFailedToShow: (error) {
        // Reklam gösterilemedi
        if (mounted) {
          showCustomSnackBar(
            langProvider.getText('ad_failed'),
            type: SnackBarType.error,
          );
        }
      },
    );
  }

  Future<void> _applyWallpaper() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final response = await http.get(Uri.parse(widget.wallpaper.imageUrl));
      final langProvider = Provider.of<LanguageProvider>(
        context,
        listen: false,
      );
      if (response.statusCode != 200) {
        throw Exception(langProvider.getText('image_download_failed'));
      }

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/wallpaper_${widget.wallpaper.id}.jpg');
      await file.writeAsBytes(response.bodyBytes);

      const platform = MethodChannel('com.example.app/wallpaper');
      await platform.invokeMethod('openWallpaperIntent', {
        'imagePath': file.path,
      });

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted && Navigator.canPop(context)) Navigator.pop(context);
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
            // 1. KATMAN: TAM EKRAN GÖRSEL
            Positioned.fill(
              child: Hero(
                tag: 'wallpaper_${widget.index}',
                child: CachedNetworkImage(
                  imageUrl: widget.wallpaper.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                  errorWidget: (context, url, error) =>
                      const Icon(Icons.error, color: Colors.white),
                ),
              ),
            ),

            // 2. KATMAN: GERİ BUTONU (SOL ÜST)
            Positioned(
              top: statusBarHeight + 10,
              left: 20,
              child: AnimatedOpacity(
                opacity: _showUI ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: ClipOval(
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
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: _showUI
                            ? () => Navigator.pop(context)
                            : null,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 3. KATMAN: ALT PANEL (BLUR + BUTON)
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // SOL: FAVORİ BUTONU
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _toggleFavorite,
                            borderRadius: BorderRadius.circular(24),
                            splashColor: Colors.white.withOpacity(0.3),
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: _isFavorite ? Colors.red : Colors.white,
                                size: 22,
                              ),
                            ),
                          ),
                        ),

                        // ORTA: UYGULA BUTONU
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _isAdLoading
                                    ? null
                                    : _showRewardedAdThenApplyWallpaper,
                                borderRadius: BorderRadius.circular(24),
                                splashColor: Colors.white.withOpacity(0.3),
                                child: Container(
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: Center(
                                    child: _isAdLoading
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : Text(
                                            langProvider.getText('apply'),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 1.2,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // SAĞ: İNDİRME BUTONU
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _downloadWallpaper,
                            borderRadius: BorderRadius.circular(24),
                            splashColor: Colors.white.withOpacity(0.3),
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.download_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
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
}
