import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/wallpaper_model.dart';
import '../data/wallpaper_data.dart';
import 'wallpaper_detail_screen.dart';

class WallpaperScreen extends StatefulWidget {
  const WallpaperScreen({super.key});

  @override
  State<WallpaperScreen> createState() => _WallpaperScreenState();
}

class _WallpaperScreenState extends State<WallpaperScreen> {
  final WallpaperData _wallpaperData = WallpaperData();
  String _selectedFilter = 'Tümü';

  final List<String> _filters = [
    'Tümü',
    'Anime',
    'Doğa',
    'Teknoloji',
    'Minimal',
  ];

  // Filtreleme fonksiyonu
  List<WallpaperModel> _getFilteredWallpapers() {
    return _wallpaperData.getWallpapersByCategory(_selectedFilter);
  }

  @override
  Widget build(BuildContext context) {
    final filteredWallpapers = _getFilteredWallpapers();

    return Column(
      children: [
        // Filtre Çipleri
        SizedBox(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            itemCount: _filters.length,
            itemBuilder: (context, index) {
              final filter = _filters[index];
              final isSelected = _selectedFilter == filter;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Text(filter),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedFilter = filter;
                    });
                  },
                  selectedColor: Theme.of(context).colorScheme.primaryContainer,
                  backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
              );
            },
          ),
        ),
        // Grid View
        Expanded(
          child: filteredWallpapers.isEmpty
              ? const Center(
                  child: Text(
                    'Bu kategoride duvar kağıdı bulunamadı',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: filteredWallpapers.length,
                  itemBuilder: (context, index) {
                    final wallpaper = filteredWallpapers[index];
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
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
