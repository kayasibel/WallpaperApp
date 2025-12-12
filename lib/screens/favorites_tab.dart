import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/wallpaper_model.dart';
import '../models/theme_model.dart';
import '../data/wallpaper_data.dart';
import '../services/favorite_service.dart';
import 'wallpaper_detail_screen.dart';
import 'theme_detail_screen.dart';

class FavoritesTab extends StatefulWidget {
  const FavoritesTab({super.key});

  @override
  State<FavoritesTab> createState() => _FavoritesTabState();
}

class _FavoritesTabState extends State<FavoritesTab> {
  final WallpaperData _wallpaperData = WallpaperData();
  final FavoriteService _favoriteService = FavoriteService();
  List<WallpaperModel> _favoriteWallpapers = [];
  List<ThemeModel> _favoriteThemes = [];
  bool _isLoading = true;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Sekme değiştiğinde favorileri yeniden yükle
    _loadFavorites();
  }

  // Favori duvar kağıtlarını ve temaları yükle
  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
    });

    // Favori duvar kağıdı ID'lerini çek
    final favoriteWallpaperIds = await _favoriteService.getFavorites();
    final favoriteWallpapers = _wallpaperData.getWallpapersByIds(favoriteWallpaperIds);

    // Favori tema ID'lerini çek
    final favoriteThemeIds = await _favoriteService.getFavoriteThemes();
    
    // ThemesTab'daki temalar ile eşleştir (ThemesTab'dan almamız gerekiyor)
    // Geçici olarak ThemesTab'daki _allThemes listesini kopyalayacağız
    final allThemes = _getAllThemes();
    final favoriteThemes = allThemes.where((theme) => favoriteThemeIds.contains(theme.id)).toList();

    setState(() {
      _favoriteWallpapers = favoriteWallpapers;
      _favoriteThemes = favoriteThemes;
      _isLoading = false;
    });
  }

  // ThemesTab'daki tema listesini al (geçici çözüm - ideal olarak merkezi data source olmalı)
  List<ThemeModel> _getAllThemes() {
    return [
      ThemeModel(
        id: 't1',
        title: 'Retro Vibes',
        previewImageUrl: 'https://picsum.photos/id/200/300/400',
        iconCount: 48,
        isPremium: false,
      ),
      ThemeModel(
        id: 't2',
        title: 'Minimal Dark',
        previewImageUrl: 'https://picsum.photos/id/201/300/400',
        iconCount: 52,
        isPremium: true,
      ),
      ThemeModel(
        id: 't3',
        title: 'Neon Nights',
        previewImageUrl: 'https://picsum.photos/id/202/300/400',
        iconCount: 60,
        isPremium: false,
      ),
      ThemeModel(
        id: 't4',
        title: 'Modern Clean',
        previewImageUrl: 'https://picsum.photos/id/203/300/400',
        iconCount: 45,
        isPremium: false,
      ),
      ThemeModel(
        id: 't5',
        title: 'Retro Gaming',
        previewImageUrl: 'https://picsum.photos/id/204/300/400',
        iconCount: 55,
        isPremium: true,
      ),
      ThemeModel(
        id: 't6',
        title: 'Minimal Light',
        previewImageUrl: 'https://picsum.photos/id/205/300/400',
        iconCount: 50,
        isPremium: false,
      ),
      ThemeModel(
        id: 't7',
        title: 'Neon Cyber',
        previewImageUrl: 'https://picsum.photos/id/206/300/400',
        iconCount: 58,
        isPremium: true,
      ),
      ThemeModel(
        id: 't8',
        title: 'Modern Glass',
        previewImageUrl: 'https://picsum.photos/id/207/300/400',
        iconCount: 62,
        isPremium: false,
      ),
      ThemeModel(
        id: 't9',
        title: 'Retro Wave',
        previewImageUrl: 'https://picsum.photos/id/208/300/400',
        iconCount: 47,
        isPremium: false,
      ),
      ThemeModel(
        id: 't10',
        title: 'Minimal Pro',
        previewImageUrl: 'https://picsum.photos/id/209/300/400',
        iconCount: 65,
        isPremium: true,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final hasWallpapers = _favoriteWallpapers.isNotEmpty;
    final hasThemes = _favoriteThemes.isNotEmpty;
    final isEmpty = !hasWallpapers && !hasThemes;

    if (isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 64,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 16),
            Text(
              'Henüz favori yok',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Beğendiğiniz duvar kağıtlarını ve temaları favorilere ekleyin',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Tab Bar
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            border: Border(
              bottom: BorderSide(
                color: Colors.grey[800]!,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTabIndex = 0;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: _selectedTabIndex == 0
                              ? Theme.of(context).colorScheme.primary
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Duvar Kağıtları (${_favoriteWallpapers.length})',
                        style: TextStyle(
                          color: _selectedTabIndex == 0
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey,
                          fontWeight: _selectedTabIndex == 0
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTabIndex = 1;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: _selectedTabIndex == 1
                              ? Theme.of(context).colorScheme.primary
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Temalar (${_favoriteThemes.length})',
                        style: TextStyle(
                          color: _selectedTabIndex == 1
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey,
                          fontWeight: _selectedTabIndex == 1
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Content
        Expanded(
          child: _selectedTabIndex == 0
              ? _buildWallpapersGrid()
              : _buildThemesGrid(),
        ),
      ],
    );
  }

  Widget _buildWallpapersGrid() {
    if (_favoriteWallpapers.isEmpty) {
      return const Center(
        child: Text('Henüz favori duvar kağıdı yok'),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.7,
      ),
      itemCount: _favoriteWallpapers.length,
      itemBuilder: (context, index) {
        final wallpaper = _favoriteWallpapers[index];
        return GestureDetector(
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WallpaperDetailScreen(
                  wallpaper: wallpaper,
                  index: index,
                ),
              ),
            );
            // Detay ekranından döndükten sonra favorileri yeniden yükle
            _loadFavorites();
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: wallpaper.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[800],
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[800],
                    child: const Icon(Icons.error),
                  ),
                ),
                // Kategori etiketi
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      wallpaper.category,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // Favori ikonu
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.red,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildThemesGrid() {
    if (_favoriteThemes.isEmpty) {
      return const Center(
        child: Text('Henüz favori tema yok'),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.75,
      ),
      itemCount: _favoriteThemes.length,
      itemBuilder: (context, index) {
        final theme = _favoriteThemes[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ThemeDetailScreen(theme: theme),
              ),
            ).then((_) => _loadFavorites());
          },
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: CachedNetworkImage(
                    imageUrl: theme.previewImageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[900],
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[900],
                      child: const Icon(Icons.error),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    theme.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

