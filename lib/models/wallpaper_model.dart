import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/cloudinary_helper.dart';

/// Wallpaper (Duvar Kağıdı) modeli
///
/// Firestore field names:
/// - url: Cloudinary'den gelen ham görsel linki
/// - title: Wallpaper başlığı
/// - category: Kategori adı (Anime, Doğa, Teknoloji, Minimal, Tümü)
/// - createdAt: Oluşturulma tarihi (Timestamp)
class WallpaperModel {
  final String id;
  final String imageUrl;
  final String category;
  final String title;

  WallpaperModel({
    required this.id,
    required this.imageUrl,
    required this.category,
    required this.title,
  });

  /// Firestore document'inden WallpaperModel oluştur
  ///
  /// Beklenen Firestore yapısı:
  /// ```json
  /// {
  ///   "url": "https://res.cloudinary.com/.../image.jpg",
  ///   "title": "Sunset Beach",
  ///   "category": "Doğa",
  ///   "createdAt": Timestamp
  /// }
  /// ```
  factory WallpaperModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    // Null check - eğer data yoksa default değerlerle oluştur
    if (data == null) {
      return WallpaperModel(
        id: doc.id,
        imageUrl: '',
        category: 'Tümü',
        title: 'Untitled',
      );
    }

    // Firestore'dan URL al ve optimize et
    final rawUrl = data['url'] as String? ?? '';
    final optimizedUrl = CloudinaryHelper.optimizeUrl(rawUrl);

    return WallpaperModel(
      id: doc.id,
      imageUrl: optimizedUrl,
      category: data['category'] as String? ?? 'Tümü',
      title: data['title'] as String? ?? 'Untitled',
    );
  }

  /// Firestore'a kaydetmek için Map dönüşümü
  Map<String, dynamic> toFirestore() {
    return {
      'url': imageUrl,
      'category': category,
      'title': title,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
