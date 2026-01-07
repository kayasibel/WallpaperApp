import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/cloudinary_helper.dart';

/// Icon Pack Model - icons koleksiyonundaki veri yapısı
///
/// Firestore yapısı:
/// {
///   "id": "retro_pack_1",
///   "packName": "Retro Icons",
///   "icons": {
///     "camera": "https://cloudinary.com/.../camera.png",
///     "whatsapp": "https://cloudinary.com/.../whatsapp.png",
///     "instagram": "https://cloudinary.com/.../instagram.png"
///   }
/// }
class IconPackModel {
  final String id;
  final String packName;
  final Map<String, String> icons; // iconName: iconUrl

  IconPackModel({
    required this.id,
    required this.packName,
    required this.icons,
  });

  factory IconPackModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      return IconPackModel(id: doc.id, packName: '', icons: {});
    }

    // icons field'ını Map<String, String> olarak çevir
    final iconsData = data['icons'] as Map<String, dynamic>? ?? {};
    final Map<String, String> icons = {};

    iconsData.forEach((key, value) {
      if (value is String) {
        // Cloudinary URL'lerini optimize et
        icons[key] = CloudinaryHelper.optimizeUrl(value);
      }
    });

    return IconPackModel(
      id: data['id'] ?? doc.id,
      packName: data['packName'] ?? '',
      icons: icons,
    );
  }

  // İkon sayısını getir
  int get iconCount => icons.length;

  // Tüm ikon URL'lerini liste olarak getir
  List<String> get iconUrls => icons.values.toList();

  // Tüm ikon isimlerini liste olarak getir
  List<String> get iconNames => icons.keys.toList();
}

/// Theme Model - themes koleksiyonundaki veri yapısı
///
/// Firestore yapısı:
/// {
///   "themeName": "Retro Vibes",
///   "previewImage": "https://cloudinary.com/.../preview.png",
///   "wallpaperUrl": "https://cloudinary.com/.../wallpaper.jpg",
///   "iconPackId": "retro_pack_1",
///   "category": "Retro"
/// }
class ThemeModel {
  final String id;
  final String themeName;
  final String previewImage;
  final String wallpaperUrl;
  final String iconPackId;
  final String category;

  ThemeModel({
    required this.id,
    required this.themeName,
    required this.previewImage,
    required this.wallpaperUrl,
    required this.iconPackId,
    required this.category,
  });

  factory ThemeModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      return ThemeModel(
        id: doc.id,
        themeName: 'Untitled Theme',
        previewImage: '',
        wallpaperUrl: '',
        iconPackId: '',
        category: 'Tümü',
      );
    }

    // Cloudinary URL'lerini optimize et
    final rawPreviewImage = data['previewImage'] as String? ?? '';
    final rawWallpaperUrl = data['wallpaperUrl'] as String? ?? '';

    return ThemeModel(
      id: doc.id,
      themeName: data['themeName'] as String? ?? 'Untitled Theme',
      previewImage: CloudinaryHelper.optimizeWithWidth(rawPreviewImage, 800),
      wallpaperUrl: CloudinaryHelper.getFullHD(rawWallpaperUrl),
      iconPackId: data['iconPackId'] as String? ?? '',
      category: data['category'] as String? ?? 'Tümü',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'themeName': themeName,
      'previewImage': previewImage,
      'wallpaperUrl': wallpaperUrl,
      'iconPackId': iconPackId,
      'category': category,
    };
  }
}
