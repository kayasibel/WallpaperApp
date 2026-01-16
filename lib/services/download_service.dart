import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:gal/gal.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

class DownloadService {
  /// Duvar kağıdını indir ve galeriye kaydet
  /// 
  /// [imageUrl] - İndirilecek resmin URL'si
  /// 
  /// Returns: Başarılı ise true, başarısız ise false
  Future<bool> downloadAndSaveWallpaper(String imageUrl) async {
    try {
      print('📥 İndirme başladı: $imageUrl');
      
      // 1. Depolama izni kontrolü ve isteği
      final permissionGranted = await _requestStoragePermission();
      print('🔐 İzin durumu: $permissionGranted');
      if (!permissionGranted) {
        print('❌ İzin reddedildi');
        return false;
      }

      // 2. HTTP ile resmi ham Byte verisi olarak indir (önbellek kullanmadan)
      print('🌐 HTTP isteği gönderiliyor...');
      final response = await http.get(Uri.parse(imageUrl));
      print('📊 HTTP durum kodu: ${response.statusCode}');

      if (response.statusCode != 200) {
        print('❌ HTTP hatası: ${response.statusCode}');
        return false;
      }

      // 3. Geçici dosya oluştur
      final tempDir = Directory.systemTemp;
      final fileName = 'wallpaper_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final tempFile = File('${tempDir.path}/$fileName');
      print('📁 Geçici dosya: ${tempFile.path}');
      
      // Ham Byte verisini geçici dosyaya yaz
      await tempFile.writeAsBytes(Uint8List.fromList(response.bodyBytes));
      print('💾 Dosya yazıldı: ${response.bodyBytes.length} bytes');
      
      // 4. Galeriye kaydet
      print('🖼️ Galeriye kaydediliyor...');
      await Gal.putImage(tempFile.path);
      print('✅ Galeriye kaydedildi');
      
      // 5. Geçici dosyayı temizle
      await tempFile.delete();
      print('🗑️ Geçici dosya silindi');

      return true;
    } catch (e, stackTrace) {
      // Hata durumunda detaylı log
      print('❌ Download error: $e');
      print('📍 Stack trace: $stackTrace');
      return false;
    }
  }

  /// Depolama iznini kontrol et ve iste
  /// 
  /// Returns: İzin verildi ise true, aksi halde false
  Future<bool> _requestStoragePermission() async {
    // Android için sürüm bazlı izin kontrolü
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;
      print('📱 Android SDK: $sdkInt');
      
      if (sdkInt >= 33) {
        // Android 13+ (API 33+) - READ_MEDIA_IMAGES
        print('🔐 Android 13+ - Photos izni isteniyor');
        final status = await Permission.photos.request();
        print('📋 Photos izin durumu: $status');
        return status.isGranted;
      } else if (sdkInt >= 30) {
        // Android 11-12 (API 30-32) - WRITE_EXTERNAL_STORAGE
        print('🔐 Android 11-12 - Storage izni isteniyor');
        final status = await Permission.storage.request();
        print('📋 Storage izin durumu: $status');
        return status.isGranted;
      } else {
        // Android 10 ve altı (API 29-)
        print('🔐 Android 10- - Storage izni isteniyor');
        final status = await Permission.storage.request();
        print('📋 Storage izin durumu: $status');
        return status.isGranted;
      }
    } else if (Platform.isIOS) {
      // iOS için photos izni
      final status = await Permission.photos.request();
      return status.isGranted;
    }

    return false;
  }
}
