import '../models/wallpaper_model.dart';

class WallpaperData {
  // Singleton pattern
  static final WallpaperData _instance = WallpaperData._internal();
  factory WallpaperData() => _instance;
  WallpaperData._internal();

  // Tüm duvar kağıtları - tek bir merkezi liste
  final List<WallpaperModel> allWallpapers = [
    WallpaperModel(
      id: 'w1',
      imageUrl: 'https://picsum.photos/id/10/400/600',
      category: 'Anime',
      title: 'Anime Wallpaper 1',
    ),
    WallpaperModel(
      id: 'w2',
      imageUrl: 'https://picsum.photos/id/20/400/600',
      category: 'Anime',
      title: 'Anime Wallpaper 2',
    ),
    WallpaperModel(
      id: 'w3',
      imageUrl: 'https://picsum.photos/id/30/400/600',
      category: 'Doğa',
      title: 'Doğa Wallpaper 1',
    ),
    WallpaperModel(
      id: 'w4',
      imageUrl: 'https://picsum.photos/id/40/400/600',
      category: 'Doğa',
      title: 'Doğa Wallpaper 2',
    ),
    WallpaperModel(
      id: 'w5',
      imageUrl: 'https://picsum.photos/id/50/400/600',
      category: 'Teknoloji',
      title: 'Teknoloji Wallpaper 1',
    ),
    WallpaperModel(
      id: 'w6',
      imageUrl: 'https://picsum.photos/id/60/400/600',
      category: 'Teknoloji',
      title: 'Teknoloji Wallpaper 2',
    ),
    WallpaperModel(
      id: 'w7',
      imageUrl: 'https://picsum.photos/id/70/400/600',
      category: 'Minimal',
      title: 'Minimal Wallpaper 1',
    ),
    WallpaperModel(
      id: 'w8',
      imageUrl: 'https://picsum.photos/id/80/400/600',
      category: 'Minimal',
      title: 'Minimal Wallpaper 2',
    ),
    WallpaperModel(
      id: 'w9',
      imageUrl: 'https://picsum.photos/id/90/400/600',
      category: 'Anime',
      title: 'Anime Wallpaper 3',
    ),
    WallpaperModel(
      id: 'w10',
      imageUrl: 'https://picsum.photos/id/100/400/600',
      category: 'Doğa',
      title: 'Doğa Wallpaper 3',
    ),
  ];

  // ID'ye göre duvar kağıdı bul
  WallpaperModel? getWallpaperById(String id) {
    try {
      return allWallpapers.firstWhere((wallpaper) => wallpaper.id == id);
    } catch (e) {
      return null;
    }
  }

  // Kategoriye göre filtrele
  List<WallpaperModel> getWallpapersByCategory(String category) {
    if (category == 'Tümü') {
      return allWallpapers;
    }
    return allWallpapers
        .where((wallpaper) => wallpaper.category == category)
        .toList();
  }

  // Birden fazla ID'ye göre duvar kağıtları bul
  List<WallpaperModel> getWallpapersByIds(List<String> ids) {
    return allWallpapers
        .where((wallpaper) => ids.contains(wallpaper.id))
        .toList();
  }
}
