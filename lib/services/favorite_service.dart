import 'package:shared_preferences/shared_preferences.dart';
import '../models/theme_model.dart';

class FavoriteService {
  static const String _favoritesKey = 'favorite_wallpapers';
  static const String _favoriteThemesKey = 'favorite_themes';

  // SharedPreferences instance'ını al
  Future<SharedPreferences> _getPrefs() async {
    return await SharedPreferences.getInstance();
  }

  // ============ WALLPAPER FAVORİLERİ ============

  // Favori duvar kağıtlarının ID listesini al
  Future<List<String>> getFavorites() async {
    final prefs = await _getPrefs();
    return prefs.getStringList(_favoritesKey) ?? [];
  }

  // Bir duvar kağıdını favorilere ekle veya çıkar (toggle)
  Future<bool> toggleFavorite(String wallpaperId) async {
    final prefs = await _getPrefs();
    final favorites = await getFavorites();

    if (favorites.contains(wallpaperId)) {
      // Eğer favorilerdeyse, çıkar
      favorites.remove(wallpaperId);
      await prefs.setStringList(_favoritesKey, favorites);
      return false; // Artık favori değil
    } else {
      // Eğer favorilerde değilse, ekle
      favorites.add(wallpaperId);
      await prefs.setStringList(_favoritesKey, favorites);
      return true; // Artık favori
    }
  }

  // Bir duvar kağıdının favori olup olmadığını kontrol et
  Future<bool> isFavorite(String wallpaperId) async {
    final favorites = await getFavorites();
    return favorites.contains(wallpaperId);
  }

  // Tüm favorileri temizle
  Future<void> clearFavorites() async {
    final prefs = await _getPrefs();
    await prefs.remove(_favoritesKey);
  }

  // Favori sayısını al
  Future<int> getFavoriteCount() async {
    final favorites = await getFavorites();
    return favorites.length;
  }

  // ============ THEME FAVORİLERİ ============

  // Favori temaların ID listesini al
  Future<List<String>> getFavoriteThemes() async {
    final prefs = await _getPrefs();
    return prefs.getStringList(_favoriteThemesKey) ?? [];
  }

  // Bir temayı favorilere ekle veya çıkar (toggle)
  Future<bool> toggleFavoriteTheme(ThemeModel theme) async {
    final prefs = await _getPrefs();
    final favorites = await getFavoriteThemes();

    if (favorites.contains(theme.id)) {
      // Eğer favorilerdeyse, çıkar
      favorites.remove(theme.id);
      await prefs.setStringList(_favoriteThemesKey, favorites);
      return false; // Artık favori değil
    } else {
      // Eğer favorilerde değilse, ekle
      favorites.add(theme.id);
      await prefs.setStringList(_favoriteThemesKey, favorites);
      return true; // Artık favori
    }
  }

  // Bir temanın favori olup olmadığını kontrol et
  Future<bool> isFavoriteTheme(String themeId) async {
    final favorites = await getFavoriteThemes();
    return favorites.contains(themeId);
  }

  // Tüm favori temaları temizle
  Future<void> clearFavoriteThemes() async {
    final prefs = await _getPrefs();
    await prefs.remove(_favoriteThemesKey);
  }

  // Favori tema sayısını al
  Future<int> getFavoriteThemeCount() async {
    final favorites = await getFavoriteThemes();
    return favorites.length;
  }
}
