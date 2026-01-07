# Firebase Firestore Entegrasyonu - Wallpapers & Themes

## ✅ Tamamlanan Değişiklikler

### 1. **Bağımlılıklar Eklendi**
- `cloud_firestore: ^5.6.12`
- `firebase_core: ^3.15.2`

### 2. **Modeller Güncellendi**

#### `wallpaper_model.dart`
- ✅ `fromFirestore` factory constructor eklendi
- ✅ Cloudinary URL optimizasyonu ayrı `CloudinaryHelper` util'ine taşındı
- ✅ Null safety ve hata kontrolü geliştirildi

#### `theme_model.dart` (YENİ YAPIDA)
- ✅ **IconPackModel** oluşturuldu (icons koleksiyonu için)
  - `id`: Icon pack benzersiz kimliği
  - `icons`: Map<String, String> yapısında iconName → iconUrl
  - `iconCount`, `iconUrls`, `iconNames` getter'ları
- ✅ **ThemeModel** yeniden yapılandırıldı
  - `themeName`: Tema adı
  - `previewImage`: Önizleme görseli (UI'da gösterilir)
  - `wallpaperUrl`: Duvar kağıdı görseli (uygulamada kullanılır)
  - `iconPackId`: icons koleksiyonuna referans
  - `category`: Kategori adı
- ❌ **Kaldırılan alanlar**: `isPremium`, `iconCount`, doğrudan icon listesi

### 3. **Yeni Utility Oluşturuldu** (`cloudinary_helper.dart`)
- ✅ Bağımsız Cloudinary URL manipülasyon fonksiyonları
- ✅ `optimizeUrl()`: Varsayılan optimizasyon (w_600,f_auto,q_auto)
- ✅ `optimizeWithWidth()`: Özel genişlik optimizasyonu
- ✅ `getThumbnail()`: 300px thumbnail
- ✅ `getFullHD()`: 1920px full HD
- ✅ Zaten optimize edilmiş URL'leri tekrar işlemez

### 4. **Yeni Service'ler Oluşturuldu**

#### `wallpaper_service.dart`
- ✅ Singleton pattern ile `WallpaperService` sınıfı
- ✅ Real-time `Stream<List<WallpaperModel>>` desteği
- ✅ Kategoriye göre filtreleme (`getWallpapersByCategoryStream`)
- ✅ ID ile tekil wallpaper getirme (`getWallpaperById`)
- ✅ `.handleError()` ile hata yönetimi eklendi
- ✅ `.orderBy()` kaldırıldı (createdAt alanı zorunlu değil)

#### `theme_service.dart` (YENİ)
- ✅ Singleton pattern ile `ThemeService` sınıfı
- ✅ Real-time tema stream'leri:
  - `getThemesStream()`: Tüm temalar
  - `getThemesByCategoryStream(category)`: Kategoriye göre filtreli
- ✅ İlişkisel sorgular:
  - `getThemeById(id)`: Tekil tema
  - `getIconPackById(iconPackId)`: Icon pack verisi (icons koleksiyonundan)
  - `getIconUrl(iconPackId, iconName)`: Belirli bir icon URL'i
- ✅ Detaylı loglama (✅ ⚠️ ❌)

### 5. **Screen Güncellemeleri**

#### `wallpaper_screen.dart`
- ✅ Eski `WallpaperData` import'u kaldırıldı
- ✅ `StreamBuilder` ile real-time veri akışı
- ✅ Modern loading, error ve empty state'ler
- ✅ Boş koleksiyon için özel mesaj: "Henüz duvar kağıdı eklenmemiş"
- ✅ Kategori bazlı farklı boş durum mesajları

#### `themes_tab.dart` (TAMAMEN YENİDEN YAZILDI)
- ✅ Hard-coded `_allThemes` listesi **kaldırıldı**
- ✅ `ThemeService` ile Firestore entegrasyonu
- ✅ StreamBuilder ile real-time tema güncellemeleri
- ✅ Kategori filtreleme korundu (Tümü, Retro, Minimal, Neon, Modern)
- ✅ Modern empty state'ler (palette ikonu, yardımcı mesajlar)
- ✅ Card UI: previewImage, themeName, category gösterimi

#### `theme_detail_screen.dart` (GÜNCELLENDI)
- ✅ `ThemeService` entegrasyonu eklendi
- ✅ **wallpaperUrl** kullanımı (previewImage DEĞİL!) wallpaper uygulamada
- ✅ **previewImage** kullanımı UI gösteriminde
- ✅ `isPremium` kontrolü **tamamen kaldırıldı**
- ✅ Yeni `_showIconsBottomSheet()` metodu:
  - İcon pack'i Firestore'dan getirir
  - DraggableScrollableSheet ile BottomSheet
  - GridView (4 sütun) ile icon gösterimi
  - Her icon: CachedNetworkImage + icon adı
  - Icon sayısı başlıkta gösterilir

#### `favorites_tab.dart`
- ✅ `WallpaperData` yerine `WallpaperService` kullanımı
- ✅ Favori wallpaper'lar artık Firestore'dan çekiliyor

### 6. **Firebase Başlatma** (`main.dart`)
- ✅ `Firebase.initializeApp()` eklendi
- ✅ `firebase_options.dart` import edildi

---

## 📊 Firestore Veri Yapısı (3 Koleksiyon)

### 1. Koleksiyon: `wallpapers`

**Zorunlu Alanlar:**

| Alan | Tip | Açıklama | Örnek |
|------|-----|----------|-------|
| `url` | String | Cloudinary ham görsel linki | `https://res.cloudinary.com/.../image.jpg` |
| `title` | String | Wallpaper başlığı | `"Sunset Beach"` |
| `category` | String | Kategori adı (**Türkçe**) | `"Anime"`, `"Doğa"`, `"Teknoloji"`, `"Minimal"` |

**Opsiyonel Alanlar:**
- `createdAt` (Timestamp): Sıralama için kullanılır (zorunlu değil)

**Desteklenen Kategoriler:**
- `Anime`, `Doğa`, `Teknoloji`, `Minimal`

---

### 2. Koleksiyon: `themes` (YENİ)

**Zorunlu Alanlar:**

| Alan | Tip | Açıklama | Örnek |
|------|-----|----------|-------|
| `themeName` | String | Tema adı | `"Retro Vibes"` |
| `previewImage` | String | Önizleme görseli (UI'da gösterilir) | `https://res.cloudinary.com/.../preview.png` |
| `wallpaperUrl` | String | Duvar kağıdı görseli (uygulamada kullanılır) | `https://res.cloudinary.com/.../wallpaper.jpg` |
| `iconPackId` | String | Icon pack referansı | `"retro_pack_1"` |
| `category` | String | Kategori adı | `"Retro"`, `"Minimal"`, `"Neon"`, `"Modern"` |

**Önemli Notlar:**
- ✅ `previewImage` UI'da gösterilir (800px optimize edilir)
- ✅ `wallpaperUrl` duvar kağıdı uygulamada kullanılır (1920px Full HD)
- ✅ `iconPackId` icons koleksiyonundaki belgeye işaret eder
- ❌ `isPremium` alanı **kaldırıldı** (artık kullanılmıyor)

**Desteklenen Kategoriler:**
- `Retro`, `Minimal`, `Neon`, `Modern`

**Örnek Belge:**

```json
{
  "themeName": "Retro Vibes",
  "previewImage": "https://res.cloudinary.com/demo/image/upload/retro_preview.png",
  "wallpaperUrl": "https://res.cloudinary.com/demo/image/upload/retro_wallpaper.jpg",
  "iconPackId": "retro_pack_1",
  "category": "Retro"
}
```

---

### 3. Koleksiyon: `icons` (YENİ - İlişkisel)

**Yapı:** Her belge bir icon pack'i temsil eder

| Alan | Tip | Açıklama | Örnek |
|------|-----|----------|-------|
| `id` | String (Field) | Icon pack benzersiz kimliği | `"retro_pack_1"` |
| `packName` | String (Field) | Icon pack görünen adı | `"Retro Icons"` |
| `icons` | Map<String, String> | iconName → iconUrl eşleştirmesi | Aşağıdaki örneğe bakın |

**Örnek Belge (Document ID: `retro_pack_1`):**

```json
{
  "id": "retro_pack_1",
  "packName": "Retro Icons",
  "icons": {
    "camera": "https://res.cloudinary.com/demo/image/upload/retro/camera.png",
    "whatsapp": "https://res.cloudinary.com/demo/image/upload/retro/whatsapp.png",
    "instagram": "https://res.cloudinary.com/demo/image/upload/retro/instagram.png"
  }
}
```

**İlişkisel Bağlantı:**
```
themes/theme_doc_1 → iconPackId: "retro_pack_1"
                                    ↓
                          icons/retro_pack_1 → id: "retro_pack_1"
                                              packName: "Retro Icons"
                                              icons: {camera: "...", whatsapp: "...", instagram: "..."}
```

**Kullanım:**
1. Tema detayında `theme.iconPackId` kullanarak
2. `ThemeService.getIconPackById(iconPackId)` ile icon pack getir
3. BottomSheet'te GridView ile göster

---

## 🔧 Firebase Kurulum Adımları

### 1. Firebase CLI Kurulumu ve Yapılandırma

```bash
# Firebase CLI'yi yükle (eğer yoksa)
npm install -g firebase-tools

# Firebase'e giriş yap
firebase login

# Flutter projesinde Firebase'i yapılandır
flutterfire configure
```

Bu komut otomatik olarak:
- Firebase projeni seçer/oluşturur
- `firebase_options.dart` dosyasını güncel bilgilerle yeniden oluşturur
- Android ve iOS yapılandırma dosyalarını ekler

### 2. Firestore Koleksiyonlarını Oluştur

#### A. `wallpapers` Koleksiyonu

Firebase Console → Firestore Database → Start Collection:

**Koleksiyon ID:** `wallpapers`

**İlk Belge Örneği:**

```json
{
  "url": "https://res.cloudinary.com/demo/image/upload/v1/sample.jpg",
  "title": "Anime Girl Sunset",
  "category": "Anime"
}
```

#### B. `themes` Koleksiyonu (YENİ)

**Koleksiyon ID:** `themes`

**İlk Belge Örneği:**

```json
{
  "themeName": "Retro Vibes",
  "previewImage": "https://res.cloudinary.com/demo/image/upload/retro_preview.png",
  "wallpaperUrl": "https://res.cloudinary.com/demo/image/upload/retro_wallpaper.jpg",
  "iconPackId": "retro_pack_1",
  "category": "Retro"
}
```

#### C. `icons` Koleksiyonu (YENİ)

**Koleksiyon ID:** `icons`

**Document ID:** `retro_pack_1` (manuel belirle)

**Belge İçeriği:**

```json
{
  "id": "retro_pack_1",
  "packName": "Retro Icons",
  "icons": {
    "camera": "https://res.cloudinary.com/demo/image/upload/retro/camera.png",
    "whatsapp": "https://res.cloudinary.com/demo/image/upload/retro/whatsapp.png",
    "instagram": "https://res.cloudinary.com/demo/image/upload/retro/instagram.png"
  }
}
```

**Önemli Notlar:**
- ✅ `id`: Icon pack benzersiz kimliği (field olarak)
- ✅ `packName`: Icon pack görünen adı (örn: "Retro Icons", "Minimal Set")
- ✅ `icons`: Map yapısında iconName → iconUrl
- ✅ Şimdilik 3 icon: camera, whatsapp, instagram
- ✅ `category` değerleri **Türkçe** olmalı: "Anime", "Doğa", "Teknoloji", "Minimal"
- ✅ `iconPackId` mutlaka `icons` koleksiyonundaki bir Document ID olmalı
- ✅ `icons` Map yapısında: key = icon adı (string), value = URL (string)

### 3. Firestore Güvenlik Kuralları

Firebase Console → Firestore Database → Rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Wallpapers koleksiyonunu herkese okuma izni ver
    match /wallpapers/{wallpaperId} {
      allow read: if true;  // Herkes okuyabilir
      allow write: if false; // Sadece admin yazabilir (Firebase Console'dan)
    }
    
    // Themes koleksiyonunu herkese okuma izni ver
    match /themes/{themeId} {
      allow read: if true;
      allow write: if false;
    }
    
    // Icons koleksiyonunu herkese okuma izni ver
    match /icons/{iconPackId} {
      allow read: if true;
      allow write: if false;
    }
  }
}
```

**Deploy:** Kuralları kaydettikten sonra "Yayınla" butonuna tıklayın.

---

## 🚀 Cloudinary Optimizasyonu

### Otomatik URL Dönüşümü

`CloudinaryHelper` utility'si URL'leri otomatik optimize eder:

```dart
// Orijinal URL (Firestore'da saklanır):
https://res.cloudinary.com/demo/image/upload/sample.jpg

// Otomatik optimize edilmiş (uygulamada kullanılır):
https://res.cloudinary.com/demo/image/upload/w_600,f_auto,q_auto/sample.jpg
```

**Optimizasyon Parametreleri:**
- `w_600`: 600px genişlik (mobil için ideal)
- `f_auto`: Otomatik format (WebP, AVIF vs.)
- `q_auto`: Otomatik kalite optimizasyonu

### Özel Kullanımlar

```dart
import '../utils/cloudinary_helper.dart';

// Varsayılan optimizasyon
String optimized = CloudinaryHelper.optimizeUrl(rawUrl);

// Özel genişlik
String large = CloudinaryHelper.optimizeWithWidth(rawUrl, 1200);

// Thumbnail
String thumb = CloudinaryHelper.getThumbnail(rawUrl);

// Full HD
String fullHd = CloudinaryHelper.getFullHD(rawUrl);
```

---

## 🎨 Kullanıcı Arayüzü

### Boş Durum Mesajları

**Koleksiyon Tamamen Boş:**
```
📱 Henüz duvar kağıdı eklenmemiş
Firebase Console'dan wallpapers koleksiyonuna
veri ekleyin
```

**Kategori Filtresi Boş:**
```
📱 Bu kategoride duvar kağıdı bulunamadı
Bu kategoride henüz wallpaper bulunmuyor
```

### Real-time Güncelleme

Firestore Console'dan yeni wallpaper eklediğinizde:
- ✅ Uygulama **otomatik olarak** güncellenir
- ✅ Sayfa yenilemeye gerek yok
- ✅ Kategori filtreleri anında çalışır

---

## 🐛 Hata Ayıklama

### "Firebase not initialized" Hatası
```bash
flutter clean
flutter pub get
flutter run
```

### StreamBuilder Veri Gelmiyor

**Kontrol Listesi:**
1. ✅ Firestore Rules okuma izni var mı?
2. ✅ `wallpapers` koleksiyonunda veri var mı?
3. ✅ Internet bağlantısı aktif mi?
4. ✅ `createdAt` alanı Timestamp tipinde mi?
5. ✅ Kategori isimleri **Türkçe** mi? ("Anime", "Doğa" vs.)

**Konsol Logları:**
```bash
flutter logs | grep -i firestore
```

### Cloudinary Görseller Yüklenmiyor

- ✅ URL'lerin geçerli Cloudinary linkleri olduğundan emin ol
- ✅ `https://res.cloudinary.com/` ile başlamalı
- ✅ `/upload/` kelimesi URL'de olmalı
- ✅ Cloudinary hesabınız public access'e izin veriyor mu?

### Kategori Filtreleme Çalışmıyor

- ✅ Firestore'daki `category` değerleri **tam olarak** şunlar olmalı:
  - `Anime` (A büyük)
  - `Doğa` (D büyük, ğ karakteri)
  - `Teknoloji` (T büyük)
  - `Minimal` (M büyük)
- ❌ Yanlış: "anime", "ANIME", "doga", "doğa"

---

## 📝 Örnek Veri Ekleme (Firebase Console)

### Adım Adım:

1. Firebase Console → Firestore Database
2. `wallpapers` koleksiyonu → **Add Document**
3. Document ID: **(Otomatik bırak)**
4. Alanları ekle:

| Field | Type | Value |
|-------|------|-------|
| url | string | `https://res.cloudinary.com/demo/image/upload/v1/sample.jpg` |
| title | string | `Anime Girl Sunset` |
| category | string | `Anime` |
| createdAt | timestamp | **[NOW]** seç |

5. **Kaydet** → Uygulama anında güncellenir! 🎉

### Toplu Veri Ekleme (İsteğe Bağlı)

Firebase Console → Firestore → İçe Aktar:

```json
{
  "wallpapers": {
    "doc1": {
      "url": "https://res.cloudinary.com/.../anime1.jpg",
      "title": "Cyberpunk City",
      "category": "Anime",
      "createdAt": {"_seconds": 1703600000, "_nanoseconds": 0}
    },
    "doc2": {
      "url": "https://res.cloudinary.com/.../nature1.jpg",
      "title": "Mountain Sunrise",
      "category": "Doğa",
      "createdAt": {"_seconds": 1703600100, "_nanoseconds": 0}
    }
  }
}
```

---

## 🎯 Performans İpuçları

### 1. Cloudinary Optimizasyonu
- ✅ Varsayılan `w_600` mobil için ideal
- ✅ `f_auto` otomatik WebP/AVIF dönüşümü
- ✅ `q_auto` dosya boyutunu %40-60 azaltır

### 2. Firestore İndeksleme
Kategori filtresi için composite index gerekebilir:

```
Koleksiyon: wallpapers
Alanlar: category (Ascending), createdAt (Descending)
```

Firebase hatası verirse otomatik link verir, tıklayın.

### 3. Cached Network Image
- ✅ Görseller otomatik cache'lenir
- ✅ 2. açılışta internet gerektirmez
- ✅ Disk ve memory cache destekli

---

## ⚠️ Önemli Notlar

- **Tema Sekmesine Dokunulmadı**: Sadece wallpaper sekmesi Firestore'a bağlandı
- **Eski Kod Temizlendi**: `WallpaperData` import'ları kaldırıldı
- **Kategori İsimleri**: Firestore'da **Türkçe** kategoriler kullanın ("Anime", "Doğa")
- **URL Formatı**: Cloudinary URL'leri `/upload/` içermeli
- **Real-time**: StreamBuilder sayesinde canlı veri akışı var

---

## 📚 Ek Kaynaklar

- [Firebase Firestore Dökümantasyonu](https://firebase.google.com/docs/firestore)
- [FlutterFire CLI](https://firebase.flutter.dev/docs/cli)
- [Cloudinary Transformations](https://cloudinary.com/documentation/image_transformations)
- [StreamBuilder Best Practices](https://api.flutter.dev/flutter/widgets/StreamBuilder-class.html)
