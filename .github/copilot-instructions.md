# Wallpaper Theme App - AI Agent Guide

## Project Overview
Turkish-language Flutter app for managing wallpapers and icon themes. Supports Android primarily (iOS/Web/Desktop present but not fully tested). Features include browsing wallpapers/themes, favorites management, wallpaper setting, and custom icon theme application via home screen widgets.

## Architecture & Data Flow

### App Structure (3-Tab Navigation)
[main.dart](lib/main.dart): `MainScreen` with `BottomNavigationBar` switching between:
1. **ThemesTab** (`screens/themes_tab.dart`) - Browse icon themes, filter by category (Retro/Minimal/Neon/Modern)
2. **WallpaperScreen** (`screens/wallpaper_screen.dart`) - Browse wallpapers, filter by category (Anime/Doğa/Teknoloji/Minimal)
3. **FavoritesTab** (`screens/favorites_tab.dart`) - View favorited themes/wallpapers with sub-tabs

### Data Layer Pattern
- **Singleton for data**: `WallpaperData` ([data/wallpaper_data.dart](lib/data/wallpaper_data.dart)) uses factory constructor returning `_instance`
  - Centralizes all wallpaper models, filtering by category/ID
  - Example: `final data = WallpaperData(); // Always returns same instance`
- **Themes**: Hardcoded in `ThemesTab._allThemes` list (NOT centralized - duplicated in `FavoritesTab._getAllThemes()`)
  - **Tech debt**: Theme data should be extracted to `data/theme_data.dart` singleton like wallpapers

### Models (Simple PODOs)
- `WallpaperModel`: `id`, `imageUrl`, `category`, `title` (no methods)
- `ThemeModel`: `id`, `title`, `previewImageUrl`, `iconCount`, `isPremium`, `icons` (list of `ThemeIcon`)
  - Auto-generates default icons via `_generateDefaultIcons()` if none provided

### Services Architecture
All services are **stateless classes** (instantiate per-use, no singleton):
- `FavoriteService` ([services/favorite_service.dart](lib/services/favorite_service.dart)): Manages favorites via `SharedPreferences`
  - Two separate keys: `favorite_wallpapers` (wallpaper IDs), `favorite_themes` (theme IDs)
  - Toggle pattern: `toggleFavorite(id)` returns new boolean state
- `DownloadService` ([services/download_service.dart](lib/services/download_service.dart)): Downloads images to gallery via `gal` package
  - Handles Android 13+ vs older permission differences (`Permission.photos` vs `Permission.storage`)
  - Uses `http` package to get raw bytes (avoiding `cached_network_image` cache), saves to temp file
- `ShortcutService` ([services/shortcut_service.dart](lib/services/shortcut_service.dart)): Creates home screen shortcuts/widgets
  - Uses `MethodChannel('com.example.app/shortcuts')` to call native Android code
  - Two methods: `createAppWidget()` (no badge) vs `createAppShortcut()` (with badge) - prefer widget

## Critical Android Integration

### Native Platform Channel
[android/app/src/main/kotlin/.../MainActivity.kt](android/app/src/main/kotlin/com/example/wallpaper_theme_app/MainActivity.kt) implements two MethodChannels:
1. **`com.example.app/shortcuts`**: Handles `createAppShortcut` and `createAppWidget` methods
   - Downloads theme icon from URL, creates bitmap, uses `ShortcutManagerCompat` or `AppWidgetManager`
2. **`com.example.app/wallpaper`**: Handles `setWallpaper` method (sets home/lock screen wallpaper)

When adding new platform features:
- Add method handler in `configureFlutterEngine()` in MainActivity.kt
- Match channel name exactly between Dart and Kotlin
- Return success/failure via `result.success()` or `result.error()`

### Permission Flow
`permission_handler` package used extensively:
- **Storage**: Android 13+ uses `Permission.photos`, older uses `Permission.storage`
- **Shortcuts**: Uses `ShortcutManagerCompat.isRequestPinShortcutSupported()` check
- Pattern: Always call `request()` before assuming permission, handle gracefully if denied

## Key Implementation Patterns

### Image Handling
- **Browsing**: Use `CachedNetworkImage` with `CircularProgressIndicator` placeholder
- **Downloading**: Use `http.get()` raw bytes to avoid cache corruption (see `DownloadService`)
- **Wallpaper URLs**: Currently placeholder images from `picsum.photos` (real API integration pending)

### State Management (Simple setState)
- All screens use `StatefulWidget` + `setState()` - no Provider/Riverpod/Bloc
- Async operations pattern: Set `_isLoading = true`, await operation, update state, `_isLoading = false`
- Example in [wallpaper_detail_screen.dart](lib/screens/wallpaper_detail_screen.dart): `_loadFavoriteStatus()` in `initState()`

### Navigation & Detail Screens
- Detail screens receive full model objects (not IDs): `WallpaperDetailScreen(wallpaper: wallpaper, index: index)`
- `Navigator.push()` with `MaterialPageRoute` - no named routes
- **Icon mapping flow**: ThemeDetailScreen → IconMappingScreen (if not premium)
  - [icon_mapping_screen.dart](lib/screens/icon_mapping_screen.dart): Complex screen using `installed_apps` package to get system apps
  - Saves mappings to SharedPreferences with key pattern `icon_map_{themeId}_{iconId}`

### Global Snackbar Pattern
[main.dart](lib/main.dart) line 6: `final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey`
- Used in `MaterialApp(scaffoldMessengerKey: scaffoldMessengerKey)`
- Allows showing snackbars from anywhere: `scaffoldMessengerKey.currentState?.showSnackBar(...)`

### Turkish Language Strings
UI text is hardcoded in Turkish (no localization system):
- 'Temalar' = Themes, 'Duvar Kağıtları' = Wallpapers, 'Favoriler' = Favorites
- 'İndiriliyor...' = Downloading, 'Favorilere eklendi' = Added to favorites
- When adding new features, maintain Turkish naming consistency

## Development Workflows

### Running & Testing (PowerShell)
```powershell
flutter run                          # Launch on connected device
flutter build apk                    # Build Android APK
dart format .                        # Format before committing
flutter pub get                      # Fetch dependencies after pubspec changes
```

### Debugging Platform Channels
- Add `print()` statements in both Dart and Kotlin
- Kotlin logs: Use `android.util.Log.d("TAG", "message")`
- View logs: `flutter logs` or Android Studio Logcat filtered by package name

### Adding New Dependencies
1. Add to [pubspec.yaml](pubspec.yaml) under `dependencies:`
2. Run `flutter pub get`
3. For platform-specific packages (like `permission_handler`), check if Android/iOS config needed in docs
4. Restart app (`flutter run` again) if native code involved

## Key Files Reference
- [lib/main.dart](lib/main.dart) - Entry point, Material 3 dark theme, 3-tab structure
- [lib/data/wallpaper_data.dart](lib/data/wallpaper_data.dart) - Singleton wallpaper data source
- [lib/services/favorite_service.dart](lib/services/favorite_service.dart) - SharedPreferences-based favorites
- [lib/screens/icon_mapping_screen.dart](lib/screens/icon_mapping_screen.dart) - Complex: maps theme icons to installed apps
- [android/app/src/main/kotlin/.../MainActivity.kt](android/app/src/main/kotlin/com/example/wallpaper_theme_app/MainActivity.kt) - Native shortcuts & wallpaper setting

## Gotchas & Known Issues
- **Theme data duplication**: Themes hardcoded in both `ThemesTab` and `FavoritesTab._getAllThemes()` - keep in sync or centralize
- **No error handling on network failures**: `picsum.photos` URLs fail silently - add try/catch in production
- **SharedPreferences not reactive**: Changes don't auto-update other screens - manually call `_loadFavorites()` in `didChangeDependencies()`
- **Android-only testing**: iOS/Web/Desktop builds exist but shortcuts/wallpaper features won't work
