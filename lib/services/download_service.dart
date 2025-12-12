import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:gal/gal.dart';
import 'package:permission_handler/permission_handler.dart';

class DownloadService {
  /// Duvar kağıdını indir ve galeriye kaydet
  /// 
  /// [imageUrl] - İndirilecek resmin URL'si
  /// 
  /// Returns: Başarılı ise true, başarısız ise false
  Future<bool> downloadAndSaveWallpaper(String imageUrl) async {
    try {
      // 1. Depolama izni kontrolü ve isteği
      final permissionGranted = await _requestStoragePermission();
      if (!permissionGranted) {
        return false;
      }

      // 2. HTTP ile resmi ham Byte verisi olarak indir (önbellek kullanmadan)
      final response = await http.get(Uri.parse(imageUrl));

      if (response.statusCode != 200) {
        return false;
      }

      // 3. Geçici dosya oluştur
      final tempDir = Directory.systemTemp;
      final fileName = 'wallpaper_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final tempFile = File('${tempDir.path}/$fileName');
      
      // Ham Byte verisini geçici dosyaya yaz
      await tempFile.writeAsBytes(Uint8List.fromList(response.bodyBytes));
      
      // 4. Galeriye kaydet
      await Gal.putImage(tempFile.path);
      
      // 5. Geçici dosyayı temizle
      await tempFile.delete();

      return true;
    } catch (e) {
      // Hata durumunda false döndür
      print('Download error: $e');
      return false;
    }
  }

  /// Depolama iznini kontrol et ve iste
  /// 
  /// Returns: İzin verildi ise true, aksi halde false
  Future<bool> _requestStoragePermission() async {
    // Android 13+ için photos izni, altı için storage izni
    if (Platform.isAndroid) {
      final androidInfo = await _getAndroidVersion();
      
      if (androidInfo >= 33) {
        // Android 13+ (API 33+)
        final status = await Permission.photos.request();
        return status.isGranted;
      } else {
        // Android 12 ve altı
        final status = await Permission.storage.request();
        return status.isGranted;
      }
    } else if (Platform.isIOS) {
      // iOS için photos izni
      final status = await Permission.photos.request();
      return status.isGranted;
    }

    return false;
  }

  /// Android sürümünü al (API seviyesi)
  Future<int> _getAndroidVersion() async {
    if (Platform.isAndroid) {
      // Android 13+ kontrolü için
      // Photos permission'ın varlığını kontrol et
      try {
        await Permission.photos.status;
        // Eğer photos permission varsa Android 13+
        return 33;
      } catch (e) {
        return 32;
      }
    }
    return 0;
  }
}
