import 'package:flutter/material.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _currentLocale = const Locale('en');

  LanguageProvider() {
    _loadLanguage();
  }

  Locale get currentLocale => _currentLocale;

  // Kaydedilmiş dili yükle, yoksa cihaz dilini kullan
  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLang = prefs.getString('language_code');

    if (savedLang != null) {
      _currentLocale = Locale(savedLang);
    } else {
      // Cihaz dilini kontrol et - desteklenen dillerden biri mi?
      final deviceLang = Platform.localeName.split('_')[0].toLowerCase();
      final supportedLangs = [
        'tr',
        'en',
        'es',
        'de',
        'fr',
        'ja',
        'ko',
        'zh',
        'pt',
        'ru',
      ];

      if (supportedLangs.contains(deviceLang)) {
        _currentLocale = Locale(deviceLang);
      } else {
        _currentLocale = const Locale('en'); // Varsayılan: İngilizce
      }
      await prefs.setString('language_code', _currentLocale.languageCode);
    }
    notifyListeners();
  }

  // Dil değiştir ve kaydet
  Future<void> setLanguage(String languageCode) async {
    _currentLocale = Locale(languageCode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', languageCode);
    notifyListeners();
  }

  // Dil ayarını sıfırla ve cihaz diline dön
  Future<void> resetToDeviceLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('language_code');

    // Cihaz dilini kontrol et - desteklenen dillerden biri mi?
    final deviceLang = Platform.localeName.split('_')[0].toLowerCase();
    final supportedLangs = [
      'tr',
      'en',
      'es',
      'de',
      'fr',
      'ja',
      'ko',
      'zh',
      'pt',
      'ru',
    ];

    if (supportedLangs.contains(deviceLang)) {
      _currentLocale = Locale(deviceLang);
    } else {
      _currentLocale = const Locale('en'); // Varsayılan: İngilizce
    }
    await prefs.setString('language_code', _currentLocale.languageCode);
    notifyListeners();
  }

  // Desteklenen diller
  static const List<Map<String, String>> supportedLanguages = [
    {'code': 'tr', 'name': 'Türkçe', 'flag': '🇹🇷'},
    {'code': 'en', 'name': 'English', 'flag': '🇬🇧'},
    {'code': 'es', 'name': 'Español', 'flag': '🇪🇸'},
    {'code': 'de', 'name': 'Deutsch', 'flag': '🇩🇪'},
    {'code': 'fr', 'name': 'Français', 'flag': '🇫🇷'},
    {'code': 'ja', 'name': '日本語', 'flag': '🇯🇵'},
    {'code': 'ko', 'name': '한국어', 'flag': '🇰🇷'},
    {'code': 'zh', 'name': '中文', 'flag': '🇨🇳'},
    {'code': 'pt', 'name': 'Português', 'flag': '🇧🇷'},
    {'code': 'ru', 'name': 'Русский', 'flag': '🇷🇺'},
  ];

  // Genişletilmiş çeviri sözlüğü
  static const Map<String, Map<String, String>> _texts = {
    'tr': {
      // Ana navigasyon
      'themes': 'Temalar',
      'wallpapers': 'Duvar Kağıtları',
      'favorites': 'Favoriler',
      'settings': 'Ayarlar',

      // Kategoriler - Temalar
      'all': 'Tümü',
      'retro': 'Retro',
      'minimal': 'Minimal',
      'neon': 'Neon',
      'modern': 'Modern',

      // Kategoriler - Duvar Kağıtları
      'anime': 'Anime',
      'nature': 'Doğa',
      'technology': 'Teknoloji',

      // Ayarlar ekranı
      'general': 'GENEL',
      'application': 'UYGULAMA',
      'language': 'Dil',
      'clear_cache': 'Önbelleği Temizle',
      'share': 'Uygulamayı Paylaş',
      'rate': 'Uygulamayı Değerlendir',
      'privacy': 'Gizlilik Politikası',
      'version': 'Versiyon',
      'select_lang': 'Dil Seçin',
      'turkish': 'Türkçe',
      'english': 'English',
      'spanish': 'Español',
      'german': 'Deutsch',
      'french': 'Français',
      'japanese': '日本語',
      'korean': '한국어',
      'chinese': '中文',
      'portuguese': 'Português',
      'russian': 'Русский',
      'cancel': 'İptal',
      'clear': 'Temizle',
      'clear_cache_title': 'Önbelleği Temizle',
      'clear_cache_message':
          'Önbelleği temizlemek istediğinize emin misiniz? Bu işlem geri alınamaz.',
      'cache_cleared': 'Önbellek temizlendi',
      'opening_store': 'Mağaza açılıyor...',
      'share_message': 'Paylaşım menüsü açılıyor...',
      'opening_privacy': 'Gizlilik politikası açılıyor...',
      'active': 'Aktif',

      // Detay ekranı
      'apply': 'Uygula',
      'download': 'İndir',
      'wallpaper_btn': 'Duvar Kağıdı',
      'icons_btn': 'İkonlar',
      'premium_btn': 'Premium',
      'no_themes_found': 'Bu kategoride tema bulunamadı',
      'no_wallpapers_found': 'Bu kategoride duvar kağıdı bulunamadı',

      // Favoriler ekranı
      'no_favorites':
          'Beğendiğiniz duvar kağıtlarını ve temaları favorilere ekleyin',
      'wallpapers_count': 'Duvar Kağıtları',
      'themes_count': 'Temalar',

      // İkon eşleştirme ekranı
      'icon_mapping_title': 'İkon Eşleştirme',
      'select_app': 'Uygulama Seç',
      'save_mappings': 'Kaydet',
      'apps_loaded_error': 'Uygulamalar yüklenemedi',
      'no_apps_found': 'Hiç uygulama bulunamadı!',
      'mapping_saved': 'İkon eşleştirmeleri kaydedildi',
      'select_app_for_icon': 'Bu ikon için bir uygulama seçin',
      'icon_added_success': 'İkon başarıyla ana ekrana eklendi',
      'select_app_first': 'Lütfen önce bir uygulama seçin!',
      'no_app_selected': 'Uygulama seçilmedi',
      'icon_ready': 'İkonunuz Hazır!',
      'add_to_home_screen': 'Şimdi Ana Ekrana Ekle',

      // Yeni eklemeler - QA audit
      'no_favorite_wallpapers': 'Henüz favori duvar kağıdı yok',
      'no_favorite_themes': 'Henüz favori tema yok',
      'premium_required': 'Premium üyelik gerekli',
      'image_download_failed': 'Resim indirilemedi',
      'icon_download_failed': 'İkon indirilemedi',
      'unknown': 'Bilinmeyen',
      'no_icons_in_theme': 'Bu temada simge bulunmuyor',

      // Mesajlar
      'added_to_favorites': 'Favorilere eklendi',
      'removed_from_favorites': 'Favorilerden çıkarıldı',
      'wallpaper_applied': 'Duvar kağıdı uygulandı',
      'wallpaper_downloaded': 'Duvar kağıdı indirildi',
      'error_occurred': 'Bir hata oluştu',
      'permission_required': 'İzin gerekli',
      'loading': 'Yükleniyor...',

      // Reklam mesajları
      'ad_loading': 'Reklam hazırlanıyor...',
      'ad_not_ready': 'Reklam hazır değil, lütfen tekrar deneyin',
      'ad_reward_not_earned': 'Reklamı izlemeden ödül kazanamazsınız',
      'ad_failed': 'Reklam gösterilemedi',

      // Rating dialog
      'rate_dialog_title': 'Uygulamayı Değerlendir',
      'rate_thanks_message': 'Bizi desteklediğin için teşekkürler!',
      'rate_on_playstore': 'Play Store\'da Puan Ver',
      'rate_feedback_message':
          'Seni geliştirmemize yardımcı ol. Hangi animeleri eklememizi istersin?',
      'rate_feedback_hint': 'Görüşlerinizi yazın...',
      'rate_send': 'Gönder',
      'rate_feedback_sent': 'Geri bildiriminiz için teşekkürler!',
      'rate_feedback_error': 'Geri bildirim gönderilemedi',

      // Rating reminder
      'rate_reminder_title': 'Uygulamamızı Değerlendirin',
      'rate_reminder_message':
          'Uygulamamız hoşunuza gitti mi? Değerlendirmeniz bizi çok mutlu eder!',
      'rate_now': 'Şimdi Değerlendir',
      'rate_later': 'Şimdi Değil',
      'rate_never': 'Bir Daha Sorma',
      'rate_later_message': 'Daha sonra hatırlatacağız',
    },
    'en': {
      // Main navigation
      'themes': 'Themes',
      'wallpapers': 'Wallpapers',
      'favorites': 'Favorites',
      'settings': 'Settings',

      // Categories - Themes
      'all': 'All',
      'retro': 'Retro',
      'minimal': 'Minimal',
      'neon': 'Neon',
      'modern': 'Modern',

      // Categories - Wallpapers
      'anime': 'Anime',
      'nature': 'Nature',
      'technology': 'Technology',

      // Settings screen
      'general': 'GENERAL',
      'application': 'APPLICATION',
      'language': 'Language',
      'clear_cache': 'Clear Cache',
      'share': 'Share App',
      'rate': 'Rate App',
      'privacy': 'Privacy Policy',
      'version': 'Version',
      'select_lang': 'Select Language',
      'turkish': 'Türkçe',
      'english': 'English',
      'spanish': 'Español',
      'german': 'Deutsch',
      'french': 'Français',
      'japanese': '日本語',
      'korean': '한국어',
      'chinese': '中文',
      'portuguese': 'Português',
      'russian': 'Русский',
      'cancel': 'Cancel',
      'clear': 'Clear',
      'clear_cache_title': 'Clear Cache',
      'clear_cache_message':
          'Are you sure you want to clear the cache? This action cannot be undone.',
      'cache_cleared': 'Cache cleared',
      'opening_store': 'Opening store...',
      'share_message': 'Opening share menu...',
      'opening_privacy': 'Opening privacy policy...',
      'active': 'Active',

      // Detail screen
      'apply': 'Apply',
      'download': 'Download',
      'wallpaper_btn': 'Wallpaper',
      'icons_btn': 'Icons',
      'premium_btn': 'Premium',
      'no_themes_found': 'No themes found in this category',
      'no_wallpapers_found': 'No wallpapers found in this category',

      // Favorites screen
      'no_favorites': 'Add your favorite wallpapers and themes to favorites',
      'wallpapers_count': 'Wallpapers',
      'themes_count': 'Themes',

      // Icon mapping screen
      'icon_mapping_title': 'Icon Mapping',
      'select_app': 'Select App',
      'save_mappings': 'Save',
      'apps_loaded_error': 'Could not load apps',
      'no_apps_found': 'No apps found!',
      'mapping_saved': 'Icon mappings saved',
      'select_app_for_icon': 'Select an app for this icon',
      'icon_added_success': 'Icon successfully added to home screen',
      'select_app_first': 'Please select an app first!',
      'no_app_selected': 'No app selected',
      'icon_ready': 'Your Icon is Ready!',
      'add_to_home_screen': 'Add to Home Screen Now',

      // New additions - QA audit
      'no_favorite_wallpapers': 'No favorite wallpapers yet',
      'no_favorite_themes': 'No favorite themes yet',
      'premium_required': 'Premium membership required',
      'image_download_failed': 'Image could not be downloaded',
      'icon_download_failed': 'Icon could not be downloaded',
      'unknown': 'Unknown',
      'no_icons_in_theme': 'This theme has no icons',

      // Messages
      'added_to_favorites': 'Added to favorites',
      'removed_from_favorites': 'Removed from favorites',
      'wallpaper_applied': 'Wallpaper applied',
      'wallpaper_downloaded': 'Wallpaper downloaded',
      'error_occurred': 'An error occurred',
      'permission_required': 'Permission required',
      'loading': 'Loading...',

      // Ad messages
      'ad_loading': 'Ad is loading...',
      'ad_not_ready': 'Ad not ready, please try again',
      'ad_reward_not_earned': 'You must watch the ad to earn the reward',
      'ad_failed': 'Could not show ad',

      // Rating dialog
      'rate_dialog_title': 'Rate the App',
      'rate_thanks_message': 'Thanks for your support!',
      'rate_on_playstore': 'Rate on Play Store',
      'rate_feedback_message':
          'Help us improve. What anime would you like us to add?',
      'rate_feedback_hint': 'Write your feedback...',
      'rate_send': 'Send',
      'rate_feedback_sent': 'Thanks for your feedback!',
      'rate_feedback_error': 'Could not send feedback',

      // Rating reminder
      'rate_reminder_title': 'Rate Our App',
      'rate_reminder_message':
          'Do you like our app? Your rating would make us very happy!',
      'rate_now': 'Rate Now',
      'rate_later': 'Not Now',
      'rate_never': 'Never Ask Again',
      'rate_later_message': 'We will remind you later',
    },
    'es': {
      // Navegación principal
      'themes': 'Temas',
      'wallpapers': 'Fondos',
      'favorites': 'Favoritos',
      'settings': 'Ajustes',

      // Categorías - Temas
      'all': 'Todos',
      'retro': 'Retro',
      'minimal': 'Minimal',
      'neon': 'Neón',
      'modern': 'Moderno',

      // Categorías - Fondos
      'anime': 'Anime',
      'nature': 'Naturaleza',
      'technology': 'Tecnología',

      // Pantalla de ajustes
      'general': 'GENERAL',
      'application': 'APLICACIÓN',
      'language': 'Idioma',
      'clear_cache': 'Limpiar caché',
      'share': 'Compartir app',
      'rate': 'Calificar app',
      'privacy': 'Política de privacidad',
      'version': 'Versión',
      'select_lang': 'Seleccionar idioma',
      'turkish': 'Türkçe',
      'english': 'English',
      'spanish': 'Español',
      'german': 'Deutsch',
      'french': 'Français',
      'japanese': '日本語',
      'korean': '한국어',
      'chinese': '中文',
      'portuguese': 'Português',
      'russian': 'Русский',
      'cancel': 'Cancelar',
      'clear': 'Limpiar',
      'clear_cache_title': 'Limpiar caché',
      'clear_cache_message':
          '¿Estás seguro de que quieres limpiar el caché? Esta acción no se puede deshacer.',
      'cache_cleared': 'Caché limpiado',
      'opening_store': 'Abriendo tienda...',
      'share_message': 'Abriendo menú de compartir...',
      'opening_privacy': 'Abriendo política de privacidad...',
      'active': 'Activo',

      // Pantalla de detalle
      'apply': 'Aplicar',
      'download': 'Descargar',
      'wallpaper_btn': 'Fondo',
      'icons_btn': 'Iconos',
      'premium_btn': 'Premium',
      'no_themes_found': 'No se encontraron temas en esta categoría',
      'no_wallpapers_found': 'No se encontraron fondos en esta categoría',

      // Pantalla de favoritos
      'no_favorites': 'Agrega tus fondos y temas favoritos a favoritos',
      'wallpapers_count': 'Fondos',
      'themes_count': 'Temas',

      // Pantalla de mapeo de iconos
      'icon_mapping_title': 'Mapeo de Iconos',
      'select_app': 'Seleccionar App',
      'save_mappings': 'Guardar',
      'apps_loaded_error': 'No se pudieron cargar las apps',
      'no_apps_found': '¡No se encontraron apps!',
      'mapping_saved': 'Mapeos de iconos guardados',
      'select_app_for_icon': 'Selecciona una app para este icono',
      'icon_added_success':
          'Icono agregado exitosamente a la pantalla de inicio',
      'select_app_first': '¡Por favor selecciona una app primero!',
      'no_app_selected': 'Ninguna app seleccionada',
      'icon_ready': '¡Tu icono está listo!',
      'add_to_home_screen': 'Agregar a pantalla de inicio',

      // Nuevas adiciones - QA audit
      'no_favorite_wallpapers': 'Aún no hay fondos favoritos',
      'no_favorite_themes': 'Aún no hay temas favoritos',
      'premium_required': 'Membresía premium requerida',
      'image_download_failed': 'No se pudo descargar la imagen',
      'icon_download_failed': 'No se pudo descargar el icono',
      'unknown': 'Desconocido',
      'no_icons_in_theme': 'Este tema no tiene iconos',

      // Mensajes
      'added_to_favorites': 'Añadido a favoritos',
      'removed_from_favorites': 'Eliminado de favoritos',
      'wallpaper_applied': 'Fondo aplicado',
      'wallpaper_downloaded': 'Fondo descargado',
      'error_occurred': 'Ocurrió un error',
      'permission_required': 'Permiso requerido',
      'loading': 'Cargando...',

      // Mensajes de anuncios
      'ad_loading': 'Cargando anuncio...',
      'ad_not_ready': 'Anuncio no listo, intente de nuevo',
      'ad_reward_not_earned': 'Debes ver el anuncio para obtener la recompensa',
      'ad_failed': 'No se pudo mostrar el anuncio',

      // Rating dialog
      'rate_dialog_title': 'Calificar App',
      'rate_thanks_message': '¡Gracias por tu apoyo!',
      'rate_on_playstore': 'Calificar en Play Store',
      'rate_feedback_message':
          'Ayúdanos a mejorar. ¿Qué anime te gustaría que agreguemos?',
      'rate_feedback_hint': 'Escribe tus comentarios...',
      'rate_send': 'Enviar',
      'rate_feedback_sent': '¡Gracias por tus comentarios!',
      'rate_feedback_error': 'No se pudo enviar el comentario',

      // Rating reminder
      'rate_reminder_title': 'Califica Nuestra App',
      'rate_reminder_message':
          '¿Te gusta nuestra app? ¡Tu calificación nos haría muy felices!',
      'rate_now': 'Calificar Ahora',
      'rate_later': 'Ahora No',
      'rate_never': 'No Preguntar Más',
      'rate_later_message': 'Te recordaremos más tarde',
    },
    'de': {
      // Hauptnavigation
      'themes': 'Themen',
      'wallpapers': 'Hintergrundbilder',
      'favorites': 'Favoriten',
      'settings': 'Einstellungen',

      // Kategorien - Themen
      'all': 'Alle',
      'retro': 'Retro',
      'minimal': 'Minimal',
      'neon': 'Neon',
      'modern': 'Modern',

      // Kategorien - Hintergrundbilder
      'anime': 'Anime',
      'nature': 'Natur',
      'technology': 'Technologie',

      // Einstellungen
      'general': 'ALLGEMEIN',
      'application': 'ANWENDUNG',
      'language': 'Sprache',
      'clear_cache': 'Cache leeren',
      'share': 'App teilen',
      'rate': 'App bewerten',
      'privacy': 'Datenschutz',
      'version': 'Version',
      'select_lang': 'Sprache auswählen',
      'turkish': 'Türkçe',
      'english': 'English',
      'spanish': 'Español',
      'german': 'Deutsch',
      'french': 'Français',
      'japanese': '日本語',
      'korean': '한국어',
      'chinese': '中文',
      'portuguese': 'Português',
      'russian': 'Русский',
      'cancel': 'Abbrechen',
      'clear': 'Leeren',
      'clear_cache_title': 'Cache leeren',
      'clear_cache_message':
          'Sind Sie sicher, dass Sie den Cache leeren möchten? Diese Aktion kann nicht rückgängig gemacht werden.',
      'cache_cleared': 'Cache geleert',
      'opening_store': 'Store wird geöffnet...',
      'share_message': 'Teilen-Menü wird geöffnet...',
      'opening_privacy': 'Datenschutzrichtlinie wird geöffnet...',
      'active': 'Aktiv',

      // Detailbildschirm
      'apply': 'Anwenden',
      'download': 'Herunterladen',
      'wallpaper_btn': 'Hintergrundbild',
      'icons_btn': 'Symbole',
      'premium_btn': 'Premium',
      'no_themes_found': 'Keine Themen in dieser Kategorie gefunden',
      'no_wallpapers_found':
          'Keine Hintergrundbilder in dieser Kategorie gefunden',

      // Favoriten-Bildschirm
      'no_favorites':
          'Füge deine Lieblings-Hintergrundbilder und Themen zu Favoriten hinzu',
      'wallpapers_count': 'Hintergrundbilder',
      'themes_count': 'Themen',

      // Symbol-Zuordnung Bildschirm
      'icon_mapping_title': 'Symbol-Zuordnung',
      'select_app': 'App auswählen',
      'save_mappings': 'Speichern',
      'apps_loaded_error': 'Apps konnten nicht geladen werden',
      'no_apps_found': 'Keine Apps gefunden!',
      'mapping_saved': 'Symbol-Zuordnungen gespeichert',
      'select_app_for_icon': 'Wähle eine App für dieses Symbol',
      'icon_added_success':
          'Symbol erfolgreich zum Startbildschirm hinzugefügt',
      'select_app_first': 'Bitte wähle zuerst eine App aus!',
      'no_app_selected': 'Keine App ausgewählt',
      'icon_ready': 'Ihr Icon ist bereit!',
      'add_to_home_screen': 'Jetzt zum Startbildschirm hinzufügen',

      // Neue Ergänzungen - QA audit
      'no_favorite_wallpapers': 'Noch keine Lieblings-Hintergrundbilder',
      'no_favorite_themes': 'Noch keine Lieblings-Themen',
      'premium_required': 'Premium-Mitgliedschaft erforderlich',
      'image_download_failed': 'Bild konnte nicht heruntergeladen werden',
      'icon_download_failed': 'Symbol konnte nicht heruntergeladen werden',
      'unknown': 'Unbekannt',
      'no_icons_in_theme': 'Dieses Thema hat keine Symbole',

      // Nachrichten
      'added_to_favorites': 'Zu Favoriten hinzugefügt',
      'removed_from_favorites': 'Aus Favoriten entfernt',
      'wallpaper_applied': 'Hintergrundbild angewendet',
      'wallpaper_downloaded': 'Hintergrundbild heruntergeladen',
      'error_occurred': 'Ein Fehler ist aufgetreten',
      'permission_required': 'Berechtigung erforderlich',
      'loading': 'Wird geladen...',

      // Anzeigen-Nachrichten
      'ad_loading': 'Anzeige wird geladen...',
      'ad_not_ready': 'Anzeige nicht bereit, bitte erneut versuchen',
      'ad_reward_not_earned':
          'Sie müssen die Anzeige ansehen, um die Belohnung zu erhalten',
      'ad_failed': 'Anzeige konnte nicht angezeigt werden',

      // Rating dialog
      'rate_dialog_title': 'App bewerten',
      'rate_thanks_message': 'Danke für deine Unterstützung!',
      'rate_on_playstore': 'Im Play Store bewerten',
      'rate_feedback_message':
          'Hilf uns zu verbessern. Welchen Anime möchtest du hinzufügen?',
      'rate_feedback_hint': 'Schreibe dein Feedback...',
      'rate_send': 'Senden',
      'rate_feedback_sent': 'Danke für dein Feedback!',
      'rate_feedback_error': 'Feedback konnte nicht gesendet werden',

      // Rating reminder
      'rate_reminder_title': 'Bewerte unsere App',
      'rate_reminder_message':
          'Gefällt dir unsere App? Deine Bewertung würde uns sehr freuen!',
      'rate_now': 'Jetzt bewerten',
      'rate_later': 'Nicht jetzt',
      'rate_never': 'Nie wieder fragen',
      'rate_later_message': 'Wir erinnern dich später',
    },
    'fr': {
      // Navigation principale
      'themes': 'Thèmes',
      'wallpapers': 'Fonds d\'écran',
      'favorites': 'Favoris',
      'settings': 'Paramètres',

      // Catégories - Thèmes
      'all': 'Tous',
      'retro': 'Rétro',
      'minimal': 'Minimal',
      'neon': 'Néon',
      'modern': 'Moderne',

      // Catégories - Fonds d'écran
      'anime': 'Anime',
      'nature': 'Nature',
      'technology': 'Technologie',

      // Écran des paramètres
      'general': 'GÉNÉRAL',
      'application': 'APPLICATION',
      'language': 'Langue',
      'clear_cache': 'Vider le cache',
      'share': 'Partager l\'app',
      'rate': 'Évaluer l\'app',
      'privacy': 'Politique de confidentialité',
      'version': 'Version',
      'select_lang': 'Sélectionner la langue',
      'turkish': 'Türkçe',
      'english': 'English',
      'spanish': 'Español',
      'german': 'Deutsch',
      'french': 'Français',
      'japanese': '日本語',
      'korean': '한국어',
      'chinese': '中文',
      'portuguese': 'Português',
      'russian': 'Русский',
      'cancel': 'Annuler',
      'clear': 'Vider',
      'clear_cache_title': 'Vider le cache',
      'clear_cache_message':
          'Êtes-vous sûr de vouloir vider le cache ? Cette action ne peut pas être annulée.',
      'cache_cleared': 'Cache vidé',
      'opening_store': 'Ouverture du magasin...',
      'share_message': 'Ouverture du menu de partage...',
      'opening_privacy': 'Ouverture de la politique de confidentialité...',
      'active': 'Actif',

      // Écran de détail
      'apply': 'Appliquer',
      'download': 'Télécharger',
      'wallpaper_btn': 'Fond d\'écran',
      'icons_btn': 'Icônes',
      'premium_btn': 'Premium',
      'no_themes_found': 'Aucun thème trouvé dans cette catégorie',
      'no_wallpapers_found': 'Aucun fond d\'écran trouvé dans cette catégorie',

      // Écran des favoris
      'no_favorites':
          'Ajoutez vos fonds d\'écran et thèmes préférés aux favoris',
      'wallpapers_count': 'Fonds d\'écran',
      'themes_count': 'Thèmes',

      // Écran de mappage d'icônes
      'icon_mapping_title': 'Mappage d\'Icônes',
      'select_app': 'Sélectionner l\'App',
      'save_mappings': 'Enregistrer',
      'apps_loaded_error': 'Impossible de charger les apps',
      'no_apps_found': 'Aucune app trouvée!',
      'mapping_saved': 'Mappages d\'icônes enregistrés',
      'select_app_for_icon': 'Sélectionnez une app pour cette icône',
      'icon_added_success': 'Icône ajoutée avec succès à l\'écran d\'accueil',
      'select_app_first': 'Veuillez d\'abord sélectionner une app!',
      'no_app_selected': 'Aucune app sélectionnée',
      'icon_ready': 'Votre icône est prête!',
      'add_to_home_screen': 'Ajouter à l\'accueil maintenant',
      // Nouvelles additions - QA audit
      'no_favorite_wallpapers': 'Pas encore de fonds d\'\u00e9cran favoris',
      'no_favorite_themes': 'Pas encore de thèmes favoris',
      'premium_required': 'Abonnement premium requis',
      'image_download_failed': 'Impossible de télécharger l\'image',
      'icon_download_failed': 'Impossible de télécharger l\'icône',
      'unknown': 'Inconnu',
      'no_icons_in_theme': 'Ce thème n\'a pas d\'icônes',
      // Messages
      'added_to_favorites': 'Ajouté aux favoris',
      'removed_from_favorites': 'Retiré des favoris',
      'wallpaper_applied': 'Fond d\'écran appliqué',
      'wallpaper_downloaded': 'Fond d\'écran téléchargé',
      'error_occurred': 'Une erreur s\'est produite',
      'permission_required': 'Permission requise',
      'loading': 'Chargement...',

      // Messages publicitaires
      'ad_loading': 'Chargement de la publicité...',
      'ad_not_ready': 'Publicité non prête, veuillez réessayer',
      'ad_reward_not_earned':
          'Vous devez regarder la publicité pour obtenir la récompense',
      'ad_failed': 'Impossible d\'afficher la publicité',

      // Rating dialog
      'rate_dialog_title': 'Évaluer l\'application',
      'rate_thanks_message': 'Merci pour votre soutien!',
      'rate_on_playstore': 'Noter sur Play Store',
      'rate_feedback_message':
          'Aidez-nous à améliorer. Quel anime aimeriez-vous ajouter?',
      'rate_feedback_hint': 'Écrivez votre avis...',
      'rate_send': 'Envoyer',
      'rate_feedback_sent': 'Merci pour votre avis!',
      'rate_feedback_error': 'Impossible d\'envoyer l\'avis',

      // Rating reminder
      'rate_reminder_title': 'Évaluez Notre Application',
      'rate_reminder_message':
          'Vous aimez notre app? Votre note nous ferait très plaisir!',
      'rate_now': 'Évaluer Maintenant',
      'rate_later': 'Pas Maintenant',
      'rate_never': 'Ne Plus Demander',
      'rate_later_message': 'Nous vous rappellerons plus tard',
    },
    'ja': {
      // メインナビゲーション
      'themes': 'テーマ',
      'wallpapers': '壁紙',
      'favorites': 'お気に入り',
      'settings': '設定',

      // カテゴリ - テーマ
      'all': 'すべて',
      'retro': 'レトロ',
      'minimal': 'ミニマル',
      'neon': 'ネオン',
      'modern': 'モダン',

      // カテゴリ - 壁紙
      'anime': 'アニメ',
      'nature': '自然',
      'technology': 'テクノロジー',

      // 設定画面
      'general': '一般',
      'application': 'アプリケーション',
      'language': '言語',
      'clear_cache': 'キャッシュをクリア',
      'share': 'アプリを共有',
      'rate': 'アプリを評価',
      'privacy': 'プライバシーポリシー',
      'version': 'バージョン',
      'select_lang': '言語を選択',
      'turkish': 'Türkçe',
      'english': 'English',
      'spanish': 'Español',
      'german': 'Deutsch',
      'french': 'Français',
      'japanese': '日本語',
      'korean': '한국어',
      'chinese': '中文',
      'portuguese': 'Português',
      'russian': 'Русский',
      'cancel': 'キャンセル',
      'clear': 'クリア',
      'clear_cache_title': 'キャッシュをクリア',
      'clear_cache_message': 'キャッシュをクリアしてもよろしいですか？この操作は元に戻せません。',
      'cache_cleared': 'キャッシュをクリアしました',
      'opening_store': 'ストアを開いています...',
      'share_message': '共有メニューを開いています...',
      'opening_privacy': 'プライバシーポリシーを開いています...',
      'active': 'アクティブ',

      // 詳細画面
      'apply': '適用',
      'download': 'ダウンロード',
      'wallpaper_btn': '壁紙',
      'icons_btn': 'アイコン',
      'premium_btn': 'プレミアム',
      'no_themes_found': 'このカテゴリにテーマが見つかりません',
      'no_wallpapers_found': 'このカテゴリに壁紙が見つかりません',

      // お気に入り画面
      'no_favorites': 'お気に入りの壁紙とテーマを追加してください',
      'wallpapers_count': '壁紙',
      'themes_count': 'テーマ',

      // アイコンマッピング画面
      'icon_mapping_title': 'アイコンマッピング',
      'select_app': 'アプリを選択',
      'save_mappings': '保存',
      'apps_loaded_error': 'アプリを読み込めませんでした',
      'no_apps_found': 'アプリが見つかりません！',
      'mapping_saved': 'アイコンマッピングを保存しました',
      'select_app_for_icon': 'このアイコン用のアプリを選択',
      'icon_added_success': 'アイコンをホーム画面に追加しました',
      'select_app_first': 'まずアプリを選択してください！',
      'no_app_selected': 'アプリが選択されていません',
      'icon_ready': 'アイコンの準備ができました！',
      'add_to_home_screen': 'ホーム画面に追加',

      // 新規追加 - QA audit
      'no_favorite_wallpapers': 'お気に入りの壁紙がまだありません',
      'no_favorite_themes': 'お気に入りのテーマがまだありません',
      'premium_required': 'プレミアム会員登録が必要です',
      'image_download_failed': '画像をダウンロードできませんでした',
      'icon_download_failed': 'アイコンをダウンロードできませんでした',
      'unknown': '不明',
      'no_icons_in_theme': 'このテーマにはアイコンがありません',

      // メッセージ
      'added_to_favorites': 'お気に入りに追加しました',
      'removed_from_favorites': 'お気に入りから削除しました',
      'wallpaper_applied': '壁紙を適用しました',
      'wallpaper_downloaded': '壁紙をダウンロードしました',
      'error_occurred': 'エラーが発生しました',
      'permission_required': '許可が必要です',
      'loading': '読み込み中...',

      // 広告メッセージ
      'ad_loading': '広告を読み込んでいます...',
      'ad_not_ready': '広告の準備ができていません。もう一度お試しください',
      'ad_reward_not_earned': '報酬を獲得するには広告を視聴してください',
      'ad_failed': '広告を表示できませんでした',

      // Rating dialog
      'rate_dialog_title': 'アプリを評価',
      'rate_thanks_message': 'ご支援ありがとうございます！',
      'rate_on_playstore': 'Play Storeで評価',
      'rate_feedback_message':
          '改善にご協力ください。どのアニメを追加してほしいですか？',
      'rate_feedback_hint': 'フィードバックを入力...',
      'rate_send': '送信',
      'rate_feedback_sent': 'フィードバックありがとうございます！',
      'rate_feedback_error': 'フィードバックを送信できませんでした',

      // Rating reminder
      'rate_reminder_title': 'アプリを評価してください',
      'rate_reminder_message':
          'アプリは気に入りましたか？評価いただけると嬉しいです！',
      'rate_now': '今すぐ評価',
      'rate_later': '後で',
      'rate_never': 'もう聞かない',
      'rate_later_message': '後でお知らせします',
    },
    'ko': {
      // 메인 네비게이션
      'themes': '테마',
      'wallpapers': '배경화면',
      'favorites': '즐겨찾기',
      'settings': '설정',

      // 카테고리 - 테마
      'all': '전체',
      'retro': '레트로',
      'minimal': '미니멀',
      'neon': '네온',
      'modern': '모던',

      // 카테고리 - 배경화면
      'anime': '애니메',
      'nature': '자연',
      'technology': '기술',

      // 설정 화면
      'general': '일반',
      'application': '애플리케이션',
      'language': '언어',
      'clear_cache': '캐시 지우기',
      'share': '앱 공유',
      'rate': '앱 평가',
      'privacy': '개인정보 처리방침',
      'version': '버전',
      'select_lang': '언어 선택',
      'turkish': 'Türkçe',
      'english': 'English',
      'spanish': 'Español',
      'german': 'Deutsch',
      'french': 'Français',
      'japanese': '日本語',
      'korean': '한국어',
      'chinese': '中文',
      'portuguese': 'Português',
      'russian': 'Русский',
      'cancel': '취소',
      'clear': '지우기',
      'clear_cache_title': '캐시 지우기',
      'clear_cache_message': '캐시를 지우시겠습니까? 이 작업은 취소할 수 없습니다.',
      'cache_cleared': '캐시가 지워졌습니다',
      'opening_store': '스토어 열는 중...',
      'share_message': '공유 메뉴 열는 중...',
      'opening_privacy': '개인정보 처리방침 열는 중...',
      'active': '활성',

      // 상세 화면
      'apply': '적용',
      'download': '다운로드',
      'wallpaper_btn': '배경화면',
      'icons_btn': '아이콘',
      'premium_btn': '프리미엄',
      'no_themes_found': '이 카테고리에 테마가 없습니다',
      'no_wallpapers_found': '이 카테고리에 배경화면이 없습니다',

      // 즐겨찾기 화면
      'no_favorites': '좋아하는 배경화면과 테마를 즐겨찾기에 추가하세요',
      'wallpapers_count': '배경화면',
      'themes_count': '테마',

      // 아이콘 매핑 화면
      'icon_mapping_title': '아이콘 매핑',
      'select_app': '앱 선택',
      'save_mappings': '저장',
      'apps_loaded_error': '앱을 불러올 수 없습니다',
      'no_apps_found': '앱을 찾을 수 없습니다!',
      'mapping_saved': '아이콘 매핑이 저장되었습니다',
      'select_app_for_icon': '이 아이콘에 사용할 앱을 선택하세요',
      'icon_added_success': '아이콘이 홈 화면에 추가되었습니다',
      'select_app_first': '먼저 앱을 선택해주세요!',
      'no_app_selected': '앱이 선택되지 않았습니다',
      'icon_ready': '아이콘이 준비되었습니다!',
      'add_to_home_screen': '홈 화면에 추가',

      // 신규 추가 - QA audit
      'no_favorite_wallpapers': '즐겨찾는 배경화면이 없습니다',
      'no_favorite_themes': '즐겨찾는 테마가 없습니다',
      'premium_required': '프리미엄 멤버십이 필요합니다',
      'image_download_failed': '이미지를 다운로드할 수 없습니다',
      'icon_download_failed': '아이콘을 다운로드할 수 없습니다',
      'unknown': '알 수 없음',
      'no_icons_in_theme': '이 테마에는 아이콘이 없습니다',

      // 메시지
      'added_to_favorites': '즐겨찾기에 추가됨',
      'removed_from_favorites': '즐겨찾기에서 삭제됨',
      'wallpaper_applied': '배경화면이 적용되었습니다',
      'wallpaper_downloaded': '배경화면이 다운로드되었습니다',
      'error_occurred': '오류가 발생했습니다',
      'permission_required': '권한이 필요합니다',
      'loading': '로딩 중...',

      // 광고 메시지
      'ad_loading': '광고 로딩 중...',
      'ad_not_ready': '광고가 준비되지 않았습니다. 다시 시도해 주세요',
      'ad_reward_not_earned': '보상을 받으려면 광고를 시청해야 합니다',
      'ad_failed': '광고를 표시할 수 없습니다',

      // Rating dialog
      'rate_dialog_title': '앱 평가',
      'rate_thanks_message': '지원해 주셔서 감사합니다!',
      'rate_on_playstore': 'Play Store에서 평가',
      'rate_feedback_message':
          '개선에 도움을 주세요. 어떤 애니메이션을 추가하면 좋을까요?',
      'rate_feedback_hint': '의견을 작성해 주세요...',
      'rate_send': '보내기',
      'rate_feedback_sent': '피드백 감사합니다!',
      'rate_feedback_error': '피드백을 보낼 수 없습니다',

      // Rating reminder
      'rate_reminder_title': '앱을 평가해 주세요',
      'rate_reminder_message':
          '앱이 마음에 드시나요? 평가해 주시면 감사하겠습니다!',
      'rate_now': '지금 평가',
      'rate_later': '나중에',
      'rate_never': '다시 묻지 않기',
      'rate_later_message': '나중에 알려드릴게요',
    },
    'zh': {
      // 主导航
      'themes': '主题',
      'wallpapers': '壁纸',
      'favorites': '收藏',
      'settings': '设置',

      // 分类 - 主题
      'all': '全部',
      'retro': '复古',
      'minimal': '极简',
      'neon': '霓虹',
      'modern': '现代',

      // 分类 - 壁纸
      'anime': '动漫',
      'nature': '自然',
      'technology': '科技',

      // 设置界面
      'general': '通用',
      'application': '应用',
      'language': '语言',
      'clear_cache': '清除缓存',
      'share': '分享应用',
      'rate': '评价应用',
      'privacy': '隐私政策',
      'version': '版本',
      'select_lang': '选择语言',
      'turkish': 'Türkçe',
      'english': 'English',
      'spanish': 'Español',
      'german': 'Deutsch',
      'french': 'Français',
      'japanese': '日本語',
      'korean': '한국어',
      'chinese': '中文',
      'portuguese': 'Português',
      'russian': 'Русский',
      'cancel': '取消',
      'clear': '清除',
      'clear_cache_title': '清除缓存',
      'clear_cache_message': '确定要清除缓存吗？此操作无法撤销。',
      'cache_cleared': '缓存已清除',
      'opening_store': '正在打开商店...',
      'share_message': '正在打开分享菜单...',
      'opening_privacy': '正在打开隐私政策...',
      'active': '活跃',

      // 详情界面
      'apply': '应用',
      'download': '下载',
      'wallpaper_btn': '壁纸',
      'icons_btn': '图标',
      'premium_btn': '高级版',
      'no_themes_found': '此分类中没有主题',
      'no_wallpapers_found': '此分类中没有壁纸',

      // 收藏界面
      'no_favorites': '将您喜欢的壁纸和主题添加到收藏',
      'wallpapers_count': '壁纸',
      'themes_count': '主题',

      // 图标映射界面
      'icon_mapping_title': '图标映射',
      'select_app': '选择应用',
      'save_mappings': '保存',
      'apps_loaded_error': '无法加载应用',
      'no_apps_found': '未找到应用！',
      'mapping_saved': '图标映射已保存',
      'select_app_for_icon': '为此图标选择一个应用',
      'icon_added_success': '图标已成功添加到主屏幕',
      'select_app_first': '请先选择一个应用！',
      'no_app_selected': '未选择应用',
      'icon_ready': '图标已准备就绪！',
      'add_to_home_screen': '添加到主屏幕',

      // 新增 - QA audit
      'no_favorite_wallpapers': '还没有收藏的壁纸',
      'no_favorite_themes': '还没有收藏的主题',
      'premium_required': '需要高级会员',
      'image_download_failed': '无法下载图片',
      'icon_download_failed': '无法下载图标',
      'unknown': '未知',
      'no_icons_in_theme': '此主题没有图标',

      // 消息
      'added_to_favorites': '已添加到收藏',
      'removed_from_favorites': '已从收藏中移除',
      'wallpaper_applied': '壁纸已应用',
      'wallpaper_downloaded': '壁纸已下载',
      'error_occurred': '发生错误',
      'permission_required': '需要权限',
      'loading': '加载中...',

      // 广告消息
      'ad_loading': '广告加载中...',
      'ad_not_ready': '广告未准备好，请重试',
      'ad_reward_not_earned': '您必须观看广告才能获得奖励',
      'ad_failed': '无法显示广告',

      // Rating dialog
      'rate_dialog_title': '评价应用',
      'rate_thanks_message': '感谢您的支持！',
      'rate_on_playstore': '在Play Store评分',
      'rate_feedback_message':
          '帮助我们改进。您希望我们添加哪些动漫？',
      'rate_feedback_hint': '写下您的反馈...',
      'rate_send': '发送',
      'rate_feedback_sent': '感谢您的反馈！',
      'rate_feedback_error': '无法发送反馈',

      // Rating reminder
      'rate_reminder_title': '给我们评分',
      'rate_reminder_message':
          '喜欢我们的应用吗？您的评分会让我们很高兴！',
      'rate_now': '现在评分',
      'rate_later': '以后再说',
      'rate_never': '不再询问',
      'rate_later_message': '我们稍后会提醒您',
    },
    'pt': {
      // Navegação principal
      'themes': 'Temas',
      'wallpapers': 'Papéis de Parede',
      'favorites': 'Favoritos',
      'settings': 'Configurações',

      // Categorias - Temas
      'all': 'Todos',
      'retro': 'Retrô',
      'minimal': 'Minimalista',
      'neon': 'Neon',
      'modern': 'Moderno',

      // Categorias - Papéis de Parede
      'anime': 'Anime',
      'nature': 'Natureza',
      'technology': 'Tecnologia',

      // Tela de configurações
      'general': 'GERAL',
      'application': 'APLICATIVO',
      'language': 'Idioma',
      'clear_cache': 'Limpar Cache',
      'share': 'Compartilhar App',
      'rate': 'Avaliar App',
      'privacy': 'Política de Privacidade',
      'version': 'Versão',
      'select_lang': 'Selecionar Idioma',
      'turkish': 'Türkçe',
      'english': 'English',
      'spanish': 'Español',
      'german': 'Deutsch',
      'french': 'Français',
      'japanese': '日本語',
      'korean': '한국어',
      'chinese': '中文',
      'portuguese': 'Português',
      'russian': 'Русский',
      'cancel': 'Cancelar',
      'clear': 'Limpar',
      'clear_cache_title': 'Limpar Cache',
      'clear_cache_message':
          'Tem certeza de que deseja limpar o cache? Esta ação não pode ser desfeita.',
      'cache_cleared': 'Cache limpo',
      'opening_store': 'Abrindo loja...',
      'share_message': 'Abrindo menu de compartilhamento...',
      'opening_privacy': 'Abrindo política de privacidade...',
      'active': 'Ativo',

      // Tela de detalhes
      'apply': 'Aplicar',
      'download': 'Baixar',
      'wallpaper_btn': 'Papel de Parede',
      'icons_btn': 'Ícones',
      'premium_btn': 'Premium',
      'no_themes_found': 'Nenhum tema encontrado nesta categoria',
      'no_wallpapers_found':
          'Nenhum papel de parede encontrado nesta categoria',

      // Tela de favoritos
      'no_favorites': 'Adicione seus papéis de parede e temas favoritos',
      'wallpapers_count': 'Papéis de Parede',
      'themes_count': 'Temas',

      // Tela de mapeamento de ícones
      'icon_mapping_title': 'Mapeamento de Ícones',
      'select_app': 'Selecionar App',
      'save_mappings': 'Salvar',
      'apps_loaded_error': 'Não foi possível carregar os apps',
      'no_apps_found': 'Nenhum app encontrado!',
      'mapping_saved': 'Mapeamentos de ícones salvos',
      'select_app_for_icon': 'Selecione um app para este ícone',
      'icon_added_success': 'Ícone adicionado com sucesso à tela inicial',
      'select_app_first': 'Por favor, selecione um app primeiro!',
      'no_app_selected': 'Nenhum app selecionado',
      'icon_ready': 'Seu ícone está pronto!',
      'add_to_home_screen': 'Adicionar à tela inicial',

      // Novas adições - QA audit
      'no_favorite_wallpapers': 'Ainda não há papéis de parede favoritos',
      'no_favorite_themes': 'Ainda não há temas favoritos',
      'premium_required': 'Assinatura premium necessária',
      'image_download_failed': 'Não foi possível baixar a imagem',
      'icon_download_failed': 'Não foi possível baixar o ícone',
      'unknown': 'Desconhecido',
      'no_icons_in_theme': 'Este tema não possui ícones',

      // Mensagens
      'added_to_favorites': 'Adicionado aos favoritos',
      'removed_from_favorites': 'Removido dos favoritos',
      'wallpaper_applied': 'Papel de parede aplicado',
      'wallpaper_downloaded': 'Papel de parede baixado',
      'error_occurred': 'Ocorreu um erro',
      'permission_required': 'Permissão necessária',
      'loading': 'Carregando...',

      // Mensagens de anúncios
      'ad_loading': 'Carregando anúncio...',
      'ad_not_ready': 'Anúncio não está pronto, tente novamente',
      'ad_reward_not_earned':
          'Você precisa assistir o anúncio para ganhar a recompensa',
      'ad_failed': 'Não foi possível exibir o anúncio',

      // Rating dialog
      'rate_dialog_title': 'Avaliar App',
      'rate_thanks_message': 'Obrigado pelo seu apoio!',
      'rate_on_playstore': 'Avaliar na Play Store',
      'rate_feedback_message':
          'Ajude-nos a melhorar. Qual anime você gostaria que adicionássemos?',
      'rate_feedback_hint': 'Escreva seu feedback...',
      'rate_send': 'Enviar',
      'rate_feedback_sent': 'Obrigado pelo seu feedback!',
      'rate_feedback_error': 'Não foi possível enviar o feedback',

      // Rating reminder
      'rate_reminder_title': 'Avalie Nosso App',
      'rate_reminder_message':
          'Gostou do nosso app? Sua avaliação nos deixaria muito felizes!',
      'rate_now': 'Avaliar Agora',
      'rate_later': 'Agora Não',
      'rate_never': 'Não Perguntar Mais',
      'rate_later_message': 'Vamos lembrar você depois',
    },
    'ru': {
      // Главная навигация
      'themes': 'Темы',
      'wallpapers': 'Обои',
      'favorites': 'Избранное',
      'settings': 'Настройки',

      // Категории - Темы
      'all': 'Все',
      'retro': 'Ретро',
      'minimal': 'Минимализм',
      'neon': 'Неон',
      'modern': 'Модерн',

      // Категории - Обои
      'anime': 'Аниме',
      'nature': 'Природа',
      'technology': 'Технологии',

      // Экран настроек
      'general': 'ОБЩИЕ',
      'application': 'ПРИЛОЖЕНИЕ',
      'language': 'Язык',
      'clear_cache': 'Очистить кэш',
      'share': 'Поделиться',
      'rate': 'Оценить',
      'privacy': 'Политика конфиденциальности',
      'version': 'Версия',
      'select_lang': 'Выберите язык',
      'turkish': 'Türkçe',
      'english': 'English',
      'spanish': 'Español',
      'german': 'Deutsch',
      'french': 'Français',
      'japanese': '日本語',
      'korean': '한국어',
      'chinese': '中文',
      'portuguese': 'Português',
      'russian': 'Русский',
      'cancel': 'Отмена',
      'clear': 'Очистить',
      'clear_cache_title': 'Очистить кэш',
      'clear_cache_message':
          'Вы уверены, что хотите очистить кэш? Это действие нельзя отменить.',
      'cache_cleared': 'Кэш очищен',
      'opening_store': 'Открываем магазин...',
      'share_message': 'Открываем меню «Поделиться»...',
      'opening_privacy': 'Открываем политику конфиденциальности...',
      'active': 'Активно',

      // Экран деталей
      'apply': 'Применить',
      'download': 'Скачать',
      'wallpaper_btn': 'Обои',
      'icons_btn': 'Иконки',
      'premium_btn': 'Премиум',
      'no_themes_found': 'В этой категории темы не найдены',
      'no_wallpapers_found': 'В этой категории обои не найдены',

      // Экран избранного
      'no_favorites': 'Добавьте любимые обои и темы в избранное',
      'wallpapers_count': 'Обои',
      'themes_count': 'Темы',

      // Экран сопоставления иконок
      'icon_mapping_title': 'Сопоставление иконок',
      'select_app': 'Выбрать приложение',
      'save_mappings': 'Сохранить',
      'apps_loaded_error': 'Не удалось загрузить приложения',
      'no_apps_found': 'Приложения не найдены!',
      'mapping_saved': 'Сопоставления иконок сохранены',
      'select_app_for_icon': 'Выберите приложение для этой иконки',
      'icon_added_success': 'Иконка успешно добавлена на главный экран',
      'select_app_first': 'Сначала выберите приложение!',
      'no_app_selected': 'Приложение не выбрано',
      'icon_ready': 'Ваша иконка готова!',
      'add_to_home_screen': 'Добавить на главный экран',

      // Новые дополнения - QA audit
      'no_favorite_wallpapers': 'Пока нет избранных обоев',
      'no_favorite_themes': 'Пока нет избранных тем',
      'premium_required': 'Требуется премиум-подписка',
      'image_download_failed': 'Не удалось скачать изображение',
      'icon_download_failed': 'Не удалось скачать иконку',
      'unknown': 'Неизвестно',
      'no_icons_in_theme': 'В этой теме нет иконок',

      // Сообщения
      'added_to_favorites': 'Добавлено в избранное',
      'removed_from_favorites': 'Удалено из избранного',
      'wallpaper_applied': 'Обои применены',
      'wallpaper_downloaded': 'Обои скачаны',
      'error_occurred': 'Произошла ошибка',
      'permission_required': 'Требуется разрешение',
      'loading': 'Загрузка...',

      // Рекламные сообщения
      'ad_loading': 'Загрузка рекламы...',
      'ad_not_ready': 'Реклама не готова, попробуйте снова',
      'ad_reward_not_earned':
          'Вы должны посмотреть рекламу, чтобы получить награду',
      'ad_failed': 'Не удалось показать рекламу',

      // Rating dialog
      'rate_dialog_title': 'Оценить приложение',
      'rate_thanks_message': 'Спасибо за вашу поддержку!',
      'rate_on_playstore': 'Оценить в Play Store',
      'rate_feedback_message':
          'Помогите нам улучшиться. Какое аниме вы хотели бы добавить?',
      'rate_feedback_hint': 'Напишите ваш отзыв...',
      'rate_send': 'Отправить',
      'rate_feedback_sent': 'Спасибо за ваш отзыв!',
      'rate_feedback_error': 'Не удалось отправить отзыв',

      // Rating reminder
      'rate_reminder_title': 'Оцените наше приложение',
      'rate_reminder_message':
          'Вам нравится наше приложение? Ваша оценка нас очень порадует!',
      'rate_now': 'Оценить сейчас',
      'rate_later': 'Не сейчас',
      'rate_never': 'Больше не спрашивать',
      'rate_later_message': 'Мы напомним вам позже',
    },
  };

  String getText(String key) =>
      _texts[_currentLocale.languageCode]?[key] ?? key;
}
