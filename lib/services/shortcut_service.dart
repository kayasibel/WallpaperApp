import 'dart:io';
import 'package:flutter/services.dart';

/// Ana ekrana uygulama kısayolu oluşturmak için servis sınıfı
class ShortcutService {
  static const MethodChannel _channel = MethodChannel('com.example.app/shortcuts');

  /// Ana ekrana widget olarak uygulama ikonu oluşturur (Badge olmaz!)
  /// 
  /// [appName]: Widget başlığı (kullanılmaz - label boş)
  /// [iconPath]: Widget ikonunun yerel dosya yolu
  /// [packageName]: Açılacak uygulamanın paketi (örn: "com.android.chrome")
  /// 
  /// Returns: Widget oluşturma işlemi başarılıysa `true`, aksi halde `false`
  Future<bool> createAppWidget({
    required String appName,
    required String iconPath,
    required String packageName,
  }) async {
    try {
      // Sadece Android için desteklenir
      if (!Platform.isAndroid) {
        print('ShortcutService: Widget oluşturma sadece Android\'de desteklenir');
        return false;
      }

      print('ShortcutService: Widget oluşturma isteği:');
      print('  - Package Name: $packageName');
      print('  - Icon Path: $iconPath');

      // Native koda method channel ile çağrı yap
      final result = await _channel.invokeMethod('createAppWidget', <String, dynamic>{
        'appName': appName,
        'iconPath': iconPath,
        'packageName': packageName,
      });
      
      print('ShortcutService: Widget native çağrı sonucu: $result');
      return result == true;
    } catch (e) {
      print('ShortcutService: Widget oluşturma hatası: $e');
      return false;
    }
  }

  /// Ana ekrana uygulama kısayolu oluşturur
  /// 
  /// [appName]: Kısayolun başlığı (örn: "Chrome")
  /// [iconPath]: Kısayol ikonunun yerel dosya yolu
  /// [packageName]: Açılacak uygulamanın paketi (örn: "com.android.chrome")
  /// 
  /// Returns: Kısayol oluşturma işlemi başarılıysa `true`, aksi halde `false`
  Future<bool> createAppShortcut({
    required String appName,
    required String iconPath,
    required String packageName,
  }) async {
    try {
      // Sadece Android için desteklenir
      if (!Platform.isAndroid) {
        print('ShortcutService: Kısayol oluşturma sadece Android\'de desteklenir');
        return false;
      }

      print('ShortcutService: Kısayol oluşturma isteği:');
      print('  - App Name: $appName');
      print('  - Package Name: $packageName');
      print('  - Icon Path: $iconPath');

      // Native koda method channel ile çağrı yap
      final result = await _channel.invokeMethod('createAppShortcut', <String, dynamic>{
        'appName': appName,
        'iconPath': iconPath,
        'packageName': packageName,
      });
      
      print('ShortcutService: Native çağrı sonucu: $result');
      return result == true;
    } on PlatformException catch (e) {
      print('ShortcutService: Hata oluştu: Native kısayol çağrısı başarısız oldu');
      print('ShortcutService: Platform Exception - Code: ${e.code}, Message: ${e.message}');
      return false;
    } catch (e) {
      print('ShortcutService: Hata oluştu: $e');
      return false;
    }
  }
}
