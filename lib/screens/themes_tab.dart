import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/theme_model.dart';
import 'theme_detail_screen.dart';

class ThemesTab extends StatefulWidget {
  const ThemesTab({super.key});

  @override
  State<ThemesTab> createState() => _ThemesTabState();
}

class _ThemesTabState extends State<ThemesTab> {
  String _selectedFilter = 'Tümü';

  final List<String> _filters = [
    'Tümü',
    'Retro',
    'Minimal',
    'Neon',
    'Modern',
  ];

  final List<ThemeModel> _allThemes = [
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

  // Filtreleme fonksiyonu
  List<ThemeModel> _getFilteredThemes() {
    if (_selectedFilter == 'Tümü') {
      return _allThemes;
    }
    return _allThemes
        .where((theme) => theme.title.contains(_selectedFilter))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredThemes = _getFilteredThemes();

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
          child: filteredThemes.isEmpty
              ? const Center(
                  child: Text(
                    'Bu kategoride tema bulunamadı',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: filteredThemes.length,
                  itemBuilder: (context, index) {
                    final theme = filteredThemes[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ThemeDetailScreen(theme: theme),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: CachedNetworkImage(
                                imageUrl: theme.previewImageUrl,
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
                            ),
                            // Premium Badge
                            if (theme.isPremium)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.amber,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.star,
                                        size: 12,
                                        color: Colors.black,
                                      ),
                                      SizedBox(width: 2),
                                      Text(
                                        'PRO',
                                        style: TextStyle(
                                          fontSize: 10,
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
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
