import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/wallpaper_model.dart';

/// Firestore Wallpaper Service
///
/// Firestore koleksiyonu: 'wallpapers'
/// Beklenen field'lar: url, title, category, createdAt
class WallpaperService {
  static final WallpaperService _instance = WallpaperService._internal();
  factory WallpaperService() => _instance;
  WallpaperService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Real-time wallpaper stream (tüm wallpaper'lar)
  ///
  /// Varsayılan sıralama ile döner (createdAt olmadan)
  Stream<List<WallpaperModel>> getWallpapersStream() {
    return _firestore
        .collection('wallpapers')
        .snapshots()
        .map((snapshot) {
          print('Firestore\'dan ${snapshot.docs.length} wallpaper geldi');
          return snapshot.docs
              .map((doc) => WallpaperModel.fromFirestore(doc))
              .toList();
        })
        .handleError((error) {
          print('❌ Wallpaper stream hatası: $error');
          print('❌ Hata tipi: ${error.runtimeType}');
          return <WallpaperModel>[];
        });
  }

  /// Kategoriye göre filtrelenmiş real-time stream
  ///
  /// Eğer category "Tümü" ise tüm wallpaper'ları döner
  /// Aksi halde where('category', isEqualTo: category) filtresi uygular
  Stream<List<WallpaperModel>> getWallpapersByCategoryStream(String category) {
    // "Tümü" kategorisi için tüm wallpaper'ları getir
    if (category == 'Tümü' || category.isEmpty) {
      return getWallpapersStream();
    }

    // Belirli kategori için filtreleme (orderBy kaldırıldı)
    return _firestore
        .collection('wallpapers')
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snapshot) {
          print(
            'Kategori "$category" için ${snapshot.docs.length} wallpaper geldi',
          );
          return snapshot.docs
              .map((doc) => WallpaperModel.fromFirestore(doc))
              .toList();
        })
        .handleError((error) {
          print('❌ Kategori filtreleme hatası ($category): $error');
          print('❌ Hata tipi: ${error.runtimeType}');
          return <WallpaperModel>[];
        });
  }

  /// Tek bir wallpaper getir (ID ile)
  Future<WallpaperModel?> getWallpaperById(String id) async {
    try {
      print('Wallpaper ID: $id getiriliyor...');
      final doc = await _firestore.collection('wallpapers').doc(id).get();
      if (doc.exists) {
        print('✅ Wallpaper ID: $id bulundu');
        return WallpaperModel.fromFirestore(doc);
      }
      print('⚠️ Wallpaper ID: $id bulunamadı');
      return null;
    } catch (e) {
      print('❌ Wallpaper getirme hatası (ID: $id): $e');
      print('❌ Hata tipi: ${e.runtimeType}');
      return null;
    }
  }
}
