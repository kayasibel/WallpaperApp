/// Cloudinary URL manipülasyon fonksiyonları
class CloudinaryHelper {
  /// Cloudinary URL'ine optimizasyon parametreleri ekler
  ///
  /// Örnek:
  /// Input:  https://res.cloudinary.com/demo/image/upload/v123/sample.jpg
  /// Output: https://res.cloudinary.com/demo/image/upload/w_600,f_auto,q_auto/v123/sample.jpg
  ///
  /// Parametreler:
  /// - w_600: 600px genişlik
  /// - f_auto: Otomatik format seçimi (WebP, AVIF vs.)
  /// - q_auto: Otomatik kalite optimizasyonu
  static String optimizeUrl(String url) {
    // Boş URL kontrolü
    if (url.isEmpty) return url;

    // Cloudinary URL değilse dokunma
    if (!url.contains('cloudinary.com') || !url.contains('/upload/')) {
      return url;
    }

    // Zaten optimize edilmişse tekrar ekleme
    if (url.contains('w_600') || url.contains('f_auto')) {
      return url;
    }

    // /upload/ sonrasına parametreleri ekle
    return url.replaceFirst(
      RegExp(r'/upload/'),
      '/upload/w_600,f_auto,q_auto/',
    );
  }

  /// Özel boyut için optimize edilmiş URL
  static String optimizeWithWidth(String url, int width) {
    if (url.isEmpty || !url.contains('cloudinary.com')) return url;

    return url.replaceFirst(
      RegExp(r'/upload/'),
      '/upload/w_$width,f_auto,q_auto/',
    );
  }

  /// Thumbnail için optimize edilmiş URL (küçük boyut)
  static String getThumbnail(String url) {
    return optimizeWithWidth(url, 300);
  }

  /// Full HD için optimize edilmiş URL
  static String getFullHD(String url) {
    return optimizeWithWidth(url, 1920);
  }

  /// Detay ekranı için optimize edilmiş URL (akıllı kırpma ile)
  ///
  /// Parametreler:
  /// - c_fill: Alanı tam doldurur
  /// - g_auto: Yapay zeka ile en önemli kısmı merkeze alır
  /// - ar_9:16: Telefon ekranı oranı (dikey)
  /// - w_1080: 1080px genişlik
  static String getDetailOptimized(String url) {
    if (url.isEmpty || !url.contains('cloudinary.com')) return url;

    // Zaten optimize edilmişse tekrar ekleme
    if (url.contains('c_fill') || url.contains('g_auto')) {
      return url;
    }

    return url.replaceFirst(
      RegExp(r'/upload/'),
      '/upload/c_fill,g_auto,ar_9:16,w_1080,f_auto,q_auto/',
    );
  }
}
