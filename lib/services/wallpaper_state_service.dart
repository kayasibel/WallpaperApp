import 'package:shared_preferences/shared_preferences.dart';

/// Duvar kağıdı ayarlama sürecinin state yönetimi
/// Aktivite restart olsa bile süreci takip eder
class WallpaperStateService {
  static const String _keyIsProcessRunning = 'is_wallpaper_process_running';
  static const String _keyThemeId = 'wallpaper_process_theme_id';
  static const String _keyWallpaperId = 'wallpaper_process_wallpaper_id';
  static const String _keyScreenType = 'wallpaper_process_screen_type'; // theme, wallpaper
  static const String _keyLocation = 'wallpaper_process_location'; // 1=home, 2=lock, 3=both
  static const String _keyTimestamp = 'wallpaper_process_timestamp';

  /// Duvar kağıdı ayarlama sürecini başlat (flag'leri kaydet)
  Future<void> startWallpaperProcess({
    String? themeId,
    String? wallpaperId,
    required String screenType, // 'theme' veya 'wallpaper'
    required int location,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsProcessRunning, true);
    await prefs.setString(_keyScreenType, screenType);
    await prefs.setInt(_keyLocation, location);
    await prefs.setInt(_keyTimestamp, DateTime.now().millisecondsSinceEpoch);
    
    if (themeId != null) {
      await prefs.setString(_keyThemeId, themeId);
    }
    if (wallpaperId != null) {
      await prefs.setString(_keyWallpaperId, wallpaperId);
    }
  }

  /// Sürecin devam edip etmediğini kontrol et
  Future<bool> isProcessRunning() async {
    final prefs = await SharedPreferences.getInstance();
    final isRunning = prefs.getBool(_keyIsProcessRunning) ?? false;
    
    if (!isRunning) return false;
    
    // Timestamp kontrolü - 30 saniyeden eski ise süreci iptal et (timeout)
    final timestamp = prefs.getInt(_keyTimestamp) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - timestamp > 30000) {
      await clearProcess();
      return false;
    }
    
    return true;
  }

  /// Kayıtlı süreç bilgilerini al
  Future<Map<String, dynamic>?> getProcessInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final isRunning = await isProcessRunning();
    
    if (!isRunning) return null;
    
    return {
      'screenType': prefs.getString(_keyScreenType) ?? 'theme',
      'themeId': prefs.getString(_keyThemeId),
      'wallpaperId': prefs.getString(_keyWallpaperId),
      'location': prefs.getInt(_keyLocation) ?? 1,
    };
  }

  /// Süreci temizle (başarı veya hata sonrası)
  Future<void> clearProcess() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIsProcessRunning);
    await prefs.remove(_keyThemeId);
    await prefs.remove(_keyWallpaperId);
    await prefs.remove(_keyScreenType);
    await prefs.remove(_keyLocation);
    await prefs.remove(_keyTimestamp);
  }

  /// Location değerini string'e çevir
  String getLocationName(int location) {
    switch (location) {
      case 1:
        return 'Ana Ekran';
      case 2:
        return 'Kilit Ekranı';
      case 3:
        return 'Her İkisi';
      default:
        return 'Ana Ekran';
    }
  }
}
