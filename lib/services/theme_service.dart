import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/theme_model.dart';

/// Firestore Theme Service
/// 
/// Koleksiyonlar:
/// - themes: Tema bilgileri
/// - icons: İkon paketleri
class ThemeService {
  static final ThemeService _instance = ThemeService._internal();
  factory ThemeService() => _instance;
  ThemeService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Real-time themes stream (tüm temalar)
  Stream<List<ThemeModel>> getThemesStream() {
    return _firestore.collection('themes').snapshots().map((snapshot) {
      print('Firestore\'dan ${snapshot.docs.length} tema geldi');
      return snapshot.docs.map((doc) => ThemeModel.fromFirestore(doc)).toList();
    }).handleError((error) {
      print('❌ Themes stream hatası: $error');
      print('❌ Hata tipi: ${error.runtimeType}');
      return <ThemeModel>[];
    });
  }

  /// Kategoriye göre filtrelenmiş themes stream
  Stream<List<ThemeModel>> getThemesByCategoryStream(String category) {
    if (category == 'Tümü' || category.isEmpty) {
      return getThemesStream();
    }

    return _firestore
        .collection('themes')
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snapshot) {
      print('Kategori "$category" için ${snapshot.docs.length} tema geldi');
      return snapshot.docs.map((doc) => ThemeModel.fromFirestore(doc)).toList();
    }).handleError((error) {
      print('❌ Theme kategori filtreleme hatası ($category): $error');
      return <ThemeModel>[];
    });
  }

  /// Tek bir tema getir (ID ile)
  Future<ThemeModel?> getThemeById(String id) async {
    try {
      print('Tema ID: $id getiriliyor...');
      final doc = await _firestore.collection('themes').doc(id).get();
      if (doc.exists) {
        print('✅ Tema ID: $id bulundu');
        return ThemeModel.fromFirestore(doc);
      }
      print('⚠️ Tema ID: $id bulunamadı');
      return null;
    } catch (e) {
      print('❌ Tema getirme hatası (ID: $id): $e');
      return null;
    }
  }

  /// İkon paketi getir (iconPackId ile)
  Future<IconPackModel?> getIconPackById(String iconPackId) async {
    try {
      print('İkon paketi ID: $iconPackId getiriliyor...');
      final doc = await _firestore.collection('icons').doc(iconPackId).get();
      if (doc.exists) {
        print('✅ İkon paketi ID: $iconPackId bulundu');
        final iconPack = IconPackModel.fromFirestore(doc);
        print('✅ İkon sayısı: ${iconPack.iconCount}');
        return iconPack;
      }
      print('⚠️ İkon paketi ID: $iconPackId bulunamadı');
      return null;
    } catch (e) {
      print('❌ İkon paketi getirme hatası (ID: $iconPackId): $e');
      print('❌ Hata tipi: ${e.runtimeType}');
      return null;
    }
  }

  /// İkon paketindeki belirli bir ikonu getir
  Future<String?> getIconUrl(String iconPackId, String iconName) async {
    try {
      final iconPack = await getIconPackById(iconPackId);
      return iconPack?.icons[iconName];
    } catch (e) {
      print('❌ İkon URL getirme hatası: $e');
      return null;
    }
  }
}
