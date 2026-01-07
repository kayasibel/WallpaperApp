import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../models/theme_model.dart';
import '../services/theme_service.dart';
import '../services/language_service.dart';
import 'theme_detail_screen.dart';

class ThemesTab extends StatefulWidget {
  const ThemesTab({super.key});

  @override
  State<ThemesTab> createState() => _ThemesTabState();
}

class _ThemesTabState extends State<ThemesTab> {
  final ThemeService _themeService = ThemeService();
  String _selectedFilterKey = 'all';

  // Kategori key'ini Firestore kategori değerine çevir
  String _getCategoryFromKey(String key) {
    final Map<String, String> categoryMap = {
      'all': 'Tümü',
      'retro': 'Retro',
      'minimal': 'Minimal',
      'neon': 'Neon',
      'modern': 'Modern',
    };
    return categoryMap[key] ?? 'Tümü';
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);

    final Map<String, String> filters = {
      'all': langProvider.getText('all'),
      'retro': langProvider.getText('retro'),
      'minimal': langProvider.getText('minimal'),
      'neon': langProvider.getText('neon'),
      'modern': langProvider.getText('modern'),
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
          child: StreamBuilder<List<ThemeModel>>(
            stream: _themeService.getThemesByCategoryStream(selectedCategory),
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

              // Empty state
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.palette_outlined,
                        size: 80,
                        color: Colors.grey.shade700,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        selectedCategory == 'Tümü'
                            ? 'Henüz tema eklenmemiş'
                            : langProvider.getText('no_themes_found'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        selectedCategory == 'Tümü'
                            ? 'Firebase Console\'dan themes koleksiyonuna\nveri ekleyin'
                            : 'Bu kategoride henüz tema bulunmuyor',
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
              final themes = snapshot.data!;
              return GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.6,
                ),
                itemCount: themes.length,
                itemBuilder: (context, index) {
                  final theme = themes[index];
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
