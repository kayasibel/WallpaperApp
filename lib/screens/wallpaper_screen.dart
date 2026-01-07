import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../models/wallpaper_model.dart';
import '../services/wallpaper_service.dart';
import '../services/language_service.dart';
import 'wallpaper_detail_screen.dart';

class WallpaperScreen extends StatefulWidget {
  const WallpaperScreen({super.key});

  @override
  State<WallpaperScreen> createState() => _WallpaperScreenState();
}

class _WallpaperScreenState extends State<WallpaperScreen> {
  final WallpaperService _wallpaperService = WallpaperService();
  String _selectedFilterKey = 'all';

  // Kategori key'ini Firestore kategori değerine çevir
  String _getCategoryFromKey(String key) {
    final Map<String, String> categoryMap = {
      'all': 'Tümü',
      'anime': 'Anime',
      'nature': 'Doğa',
      'technology': 'Teknoloji',
      'minimal': 'Minimal',
    };
    return categoryMap[key] ?? 'Tümü';
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);

    final Map<String, String> filters = {
      'all': langProvider.getText('all'),
      'anime': langProvider.getText('anime'),
      'nature': langProvider.getText('nature'),
      'technology': langProvider.getText('technology'),
      'minimal': langProvider.getText('minimal'),
    };

    final selectedCategory = _getCategoryFromKey(_selectedFilterKey);

    return Column(
      children: [
        // Filtre Çipleri
        SizedBox(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            itemCount: filters.length,
            itemBuilder: (context, index) {
              final filterKey = filters.keys.elementAt(index);
              final filterName = filters[filterKey]!;
              final isSelected = _selectedFilterKey == filterKey;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Text(filterName),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedFilterKey = filterKey;
                    });
                  },
                  selectedColor: Theme.of(context).colorScheme.primaryContainer,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest,
                ),
              );
            },
          ),
        ),
        // StreamBuilder ile real-time grid
        Expanded(
          child: StreamBuilder<List<WallpaperModel>>(
            stream: _wallpaperService.getWallpapersByCategoryStream(
              selectedCategory,
            ),
            builder: (context, snapshot) {
              // Loading state
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              // Error state
              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Bir hata oluştu: ${snapshot.error}',
                        style: const TextStyle(fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              // Empty state - Geliştirilmiş boş durum mesajı
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.wallpaper_outlined,
                        size: 80,
                        color: Colors.grey.shade700,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        selectedCategory == 'Tümü'
                            ? 'Henüz duvar kağıdı eklenmemiş'
                            : langProvider.getText('no_wallpapers_found'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        selectedCategory == 'Tümü'
                            ? 'Firebase Console\'dan wallpapers koleksiyonuna\nveri ekleyin'
                            : 'Bu kategoride henüz wallpaper bulunmuyor',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              // Data state - Grid View
              final wallpapers = snapshot.data!;
              return GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.6,
                ),
                itemCount: wallpapers.length,
                itemBuilder: (context, index) {
                  final wallpaper = wallpapers[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WallpaperDetailScreen(
                            wallpaper: wallpaper,
                            index: index,
                          ),
                        ),
                      );
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
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
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
            },
          ),
        ),
      ],
    );
  }
}
