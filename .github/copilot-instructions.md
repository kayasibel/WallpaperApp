# Wallpaper Theme App - AI Agent Guide

## Project Overview
Flutter mobile application for wallpapers and themes. Uses standard Flutter project structure with multi-platform support (Android, iOS, Web, Windows, Linux, macOS).

## Architecture & Structure
- **Entry point**: `lib/main.dart` - MaterialApp with default counter demo
- **Single file app**: Currently all code in `main.dart` (MyApp → MyHomePage → _MyHomePageState)
- **Platform configs**: 
  - Android: Kotlin-based Gradle (`.kts`), namespace `com.example.wallpaper_theme_app`, minSdk from Flutter defaults
  - Build output: Custom `build/` directory structure (see `android/build.gradle.kts` lines 7-11)

## Development Workflows

### Running & Testing
```powershell
# Run app (uses PowerShell syntax)
flutter run

# Hot reload: Press 'r' in terminal or save files
# Hot restart: Press 'R' in terminal

# Run tests
flutter test

# Run specific test
flutter test test/widget_test.dart
```

### Building
```powershell
# Android APK
flutter build apk

# iOS (requires macOS)
flutter build ios

# Web
flutter build web
```

## Key Conventions

### Code Style
- **Linting**: Uses `flutter_lints ^6.0.0` (strict recommended set)
- **Analysis**: See `analysis_options.yaml` - includes `package:flutter_lints/flutter.yaml`
- **Formatting**: Run `dart format .` before committing

### State Management
- Currently uses `StatefulWidget` with `setState()` (see `_MyHomePageState` in `main.dart`)
- Counter pattern example: `_incrementCounter()` method demonstrates state updates

### Widget Structure
- Root widget: `MyApp` (StatelessWidget)
- Theme: Material 3 with `ColorScheme.fromSeed(seedColor: Colors.deepPurple)`
- Navigation: None yet - single-page app

## Dependencies
- **Production**: `cupertino_icons ^1.0.8` only
- **Dev**: `flutter_test`, `flutter_lints ^6.0.0`
- **SDK**: Dart `^3.10.3`

## Platform-Specific Notes

### Android
- Gradle: Kotlin DSL (`.gradle.kts` files)
- NDK: v29.0.14206865
- Java: Target/Source compatibility = Java 17
- Build directory: Custom location at `../../build` (root level)

### Testing
- Widget tests in `test/widget_test.dart` follow Flutter testing conventions
- Uses `WidgetTester` for interaction testing
- Example: Counter increment test with `tester.pumpWidget()` and `tester.tap()`

## Common Patterns to Follow
1. **Widget naming**: Prefix private state classes with `_` (e.g., `_MyHomePageState`)
2. **Const constructors**: Use `const` for widgets when possible (`const MyApp()`)
3. **Key parameters**: Include `super.key` in constructors for widget identity
4. **Material Design**: Leverage `Theme.of(context)` for consistent styling

## Next Steps for Expansion
When adding features to this wallpaper app, consider:
- Image caching/loading (may need packages like `cached_network_image`)
- Theme persistence (may need `shared_preferences` or similar)
- Asset organization in `assets/` directory (update `pubspec.yaml` flutter section)
- State management scaling (consider Provider, Riverpod, or Bloc if complexity grows)
