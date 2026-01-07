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
      final supportedLangs = ['tr', 'en', 'es', 'de', 'fr'];

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
    final supportedLangs = ['tr', 'en', 'es', 'de', 'fr'];

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
    },
  };

  String getText(String key) =>
      _texts[_currentLocale.languageCode]?[key] ?? key;
}
