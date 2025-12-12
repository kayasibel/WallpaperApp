import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/wallpaper_model.dart';
import '../services/favorite_service.dart';
import 'package:wallpaper_theme_app/services/download_service.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:wallpaper_manager_plus/wallpaper_manager_plus.dart';

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
  bool _isFavorite = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavoriteStatus();
  }

  // Favori durumunu yükle
  Future<void> _loadFavoriteStatus() async {
    final isFav = await _favoriteService.isFavorite(widget.wallpaper.id);
    setState(() {
      _isFavorite = isFav;
      _isLoading = false;
    });
  }

  // Favori durumunu değiştir
  Future<void> _toggleFavorite() async {
    final newStatus = await _favoriteService.toggleFavorite(widget.wallpaper.id);
    setState(() {
      _isFavorite = newStatus;
    });

    // Kullanıcıya bilgi ver
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isFavorite ? 'Favorilere eklendi' : 'Favorilerden çıkarıldı',
          ),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  // Duvar kağıdını indir
  Future<void> _downloadWallpaper() async {
    // İndiriliyor mesajı göster
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('İndiriliyor...'),
          duration: Duration(seconds: 2),
        ),
      );
    }

    // İndirme işlemini başlat
    final success = await _downloadService.downloadAndSaveWallpaper(
      widget.wallpaper.imageUrl,
    );

    // Sonuç mesajını göster
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success 
              ? 'İndirme Başarılı!' 
              : 'İndirme Başarısız! (İzin Gerekli)',
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  // Duvar kağıdını uygula
  Future<void> _applyWallpaper() async {
    try {
      // Başlangıç mesajı
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Duvar Kağıdı Ayarlanıyor...'),
            duration: Duration(seconds: 3),
          ),
        );
      }

      // 1. Resmi http ile indir
      final response = await http.get(Uri.parse(widget.wallpaper.imageUrl));
      if (response.statusCode != 200) {
        throw Exception('Resim indirilemedi: ${response.statusCode}');
      }

      // 2. Geçici dizine kaydet
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/wallpaper_${widget.wallpaper.id}.jpg');
      await file.writeAsBytes(response.bodyBytes);

      // 3. Duvar kağıdını ayarla
      await WallpaperManagerPlus().setWallpaper(
        file,
        WallpaperManagerPlus.homeScreen,
      );

      // 4. Başarı mesajı
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Duvar Kağıdı Başarıyla Ayarlandı!'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Hata mesajı
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Duvar Kağıdı Ayarlama Başarısız oldu! (İzin veya Dosya Hatası)'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.wallpaper.title),
        actions: [
          _isLoading
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : IconButton(
                  icon: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite ? Colors.red : null,
                  ),
                  onPressed: _toggleFavorite,
                ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _downloadWallpaper,
          ),
          IconButton(
            icon: const Icon(Icons.wallpaper),
            onPressed: _applyWallpaper,
            tooltip: 'Duvar Kağıdı Olarak Ayarla',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Hero(
                tag: 'wallpaper_${widget.index}',
                child: CachedNetworkImage(
                  imageUrl: widget.wallpaper.imageUrl,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const Icon(
                    Icons.error,
                    size: 48,
                  ),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.wallpaper.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Chip(
                  label: Text(widget.wallpaper.category),
                  avatar: const Icon(Icons.category, size: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
