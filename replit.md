# Elite Quiz App - Replit Setup

## Project Overview
This is a Flutter mobile quiz application (Elite Quiz App) that has been imported from GitHub and adapted for the Replit environment. The app is a comprehensive quiz platform with features including:
- Multiple quiz modes (battle, group play, daily quiz, exam mode)
- Firebase integration (Auth, Firestore, Analytics, Messaging)
- In-app purchases
- Leaderboards and statistics
- Coin system and rewards
- Multi-language support

## Current Status
✅ **WORKING** - The Flutter app compiles and runs successfully on port 5000.

### What's Been Completed
1. ✅ Flutter SDK (3.32.0) and Dart (3.8.0) installed via Nix packages
2. ✅ Flutter web support enabled - `web/` directory created
3. ✅ Dependencies installed with `flutter pub get`
4. ✅ Workflow configured to run Flutter web on port 5000
5. ✅ `.gitignore` updated for Flutter web builds
6. ✅ Fixed all code compatibility issues:
   - Removed double commas in `home_screen.dart` and `quiz_grid_card.dart`
   - Updated `Switch` widget to use `thumbColor` instead of deprecated `activeThumbColor`
   - Replaced `Matrix4.scaleByDouble()` with `Matrix4.scale()` in 3 files
   - Commented out `very_good_analysis` package (requires Dart SDK >= 3.9.0)
   - Adjusted SDK version constraint from `>=3.8.1` to `>=3.8.0`
   - Created `RadioGroup` and `RadioGroupScope` widgets (`lib/ui/widgets/radio_group.dart`)
   - Fixed all 4 files using RadioGroup with proper groupValue wiring
   - Replaced dot-shorthand syntax with explicit enum values in 4 files

## Project Structure
```
flutterquiz/
├── lib/               # Main Dart source code
│   ├── app/          # App initialization
│   ├── commons/      # Shared widgets and bottom navigation
│   ├── core/         # Core configuration, constants, theme
│   ├── features/     # Feature modules (ads, auth, badges, quiz, etc.)
│   ├── ui/           # UI components and screens
│   │   ├── widgets/  # Reusable widgets (including RadioGroup)
│   │   └── screens/  # App screens
│   └── main.dart     # Application entry point
├── assets/           # Images, animations, sounds, icons
├── web/              # Flutter web configuration
├── android/          # Android native code
├── ios/              # iOS native code
└── pubspec.yaml      # Dependencies and configuration
```

## Technology Stack
- **Framework**: Flutter 3.32.0
- **Language**: Dart 3.8.0
- **Backend**: Firebase (Auth, Firestore, Analytics, Messaging)
- **State Management**: flutter_bloc
- **Local Storage**: Hive
- **Ads**: Google Mobile Ads, Unity Ads, IronSource
- **UI**: Material Design with custom theming

## Configuration Files
- `pubspec.yaml` - Flutter dependencies (adjusted for Dart 3.8.0)
- `analysis_options.yaml` - Linting rules (very_good_analysis commented out)
- `web/index.html` - Web app entry point
- `web/manifest.json` - PWA manifest

## Development Workflow
The project is configured with a workflow named "Flutter Web Server" that runs:
```bash
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 5000
```

## Firebase Configuration
The app uses Firebase services. The following config files exist:
- `android/app/google-services.json` (Android)
- `ios/Runner/GoogleService-Info.plist` (iOS)

**Note**: Web Firebase configuration may need to be added to `web/index.html` for full functionality.

## Known Limitations
- This app was originally designed for mobile (Android/iOS)
- Some mobile-specific plugins may not work on web:
  - `screen_protector`
  - `app_tracking_transparency`
  - Some ad providers may have limited web support
- Firebase Auth providers (Apple Sign In) may need web configuration

## Useful Commands
```bash
# Get dependencies
flutter pub get

# Run on web
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 5000

# Build for web
flutter build web

# Analyze code
flutter analyze

# Check for outdated packages
flutter pub outdated
```

## Key Fixes Applied (Dec 3, 2025)

### RadioGroup Widget
Created `lib/ui/widgets/radio_group.dart` to provide `RadioGroup<T>` and `RadioGroupScope<T>` widgets. These work with Flutter's RadioListTile by providing groupValue through an InheritedWidget pattern.

### Dot-Shorthand Syntax
Replaced experimental dot-shorthand syntax (e.g., `.center`) with explicit enum values (e.g., `MainAxisAlignment.center`) in:
- `lib/ui/screens/home/home_screen.dart`
- `lib/ui/screens/home/widgets/quiz_grid_card.dart`
- `lib/features/quiz/models/comprehension.dart`
- `lib/features/auth/models/auth_providers_enum.dart`

## Recent Changes
- **Dec 3, 2025**: All compilation errors fixed, app now builds and runs successfully on Flutter 3.32.0

## Original Documentation
See README.md for original build instructions and rebranding guide.
