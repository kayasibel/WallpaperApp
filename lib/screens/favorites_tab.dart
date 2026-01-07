import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../models/wallpaper_model.dart';
import '../models/theme_model.dart';
import '../services/wallpaper_service.dart';
import '../services/theme_service.dart';
import '../services/favorite_service.dart';
import '../services/language_service.dart';
import 'wallpaper_detail_screen.dart';
import 'theme_detail_screen.dart';

class FavoritesTab extends StatefulWidget {
  const FavoritesTab({super.key});

  @override
  State<FavoritesTab> createState() => _FavoritesTabState();
}

class _FavoritesTabState extends State<FavoritesTab> {
  final WallpaperService _wallpaperService = WallpaperService();
  final ThemeService _themeService = ThemeService();
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

    // Favori duvar kağıdı ID'lerini çek ve Firestore'dan getir
    final favoriteWallpaperIds = await _favoriteService.getFavorites();
    final List<WallpaperModel> favoriteWallpapers = [];

    for (String id in favoriteWallpaperIds) {
      final wallpaper = await _wallpaperService.getWallpaperById(id);
      if (wallpaper != null) {
        favoriteWallpapers.add(wallpaper);
      }
    }

    // Favori tema ID'lerini çek ve Firestore'dan getir
    final favoriteThemeIds = await _favoriteService.getFavoriteThemes();
    final List<ThemeModel> favoriteThemes = [];

    for (String id in favoriteThemeIds) {
      final theme = await _themeService.getThemeById(id);
      if (theme != null) {
        favoriteThemes.add(theme);
      }
    }

    setState(() {
      _favoriteWallpapers = favoriteWallpapers;
      _favoriteThemes = favoriteThemes;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final hasWallpapers = _favoriteWallpapers.isNotEmpty;
    final hasThemes = _favoriteThemes.isNotEmpty;
    final isEmpty = !hasWallpapers && !hasThemes;

    if (isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 64, color: Colors.grey[600]),
            const SizedBox(height: 16),
            Text(
              langProvider.getText('favorites'),
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              langProvider.getText('no_favorites'),
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
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
              bottom: BorderSide(color: Colors.grey[800]!, width: 1),
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
                        '${langProvider.getText('wallpapers_count')} (${_favoriteWallpapers.length})',
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
                        '${langProvider.getText('themes_count')} (${_favoriteThemes.length})',
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
      final langProvider = Provider.of<LanguageProvider>(
        context,
        listen: false,
      );
      return Center(
        child: Text(langProvider.getText('no_favorite_wallpapers')),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.6,
      ),
      itemCount: _favoriteWallpapers.length,
      itemBuilder: (context, index) {
        final wallpaper = _favoriteWallpapers[index];
        return GestureDetector(
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    WallpaperDetailScreen(wallpaper: wallpaper, index: index),
              ),
            );
            // Detay ekranından döndükten sonra favorileri yeniden yükle
            _loadFavorites();
          },
          child: Card(
            elevation: 8,
            shadowColor: Colors.black.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: wallpaper.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[800],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[800],
                      child: const Icon(Icons.error),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildThemesGrid() {
    if (_favoriteThemes.isEmpty) {
      final langProvider = Provider.of<LanguageProvider>(
        context,
        listen: false,
      );
      return Center(child: Text(langProvider.getText('no_favorite_themes')));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.6,
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
            elevation: 8,
            shadowColor: Colors.black.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: theme.previewImage,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[800],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[800],
                      child: const Icon(Icons.error),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
