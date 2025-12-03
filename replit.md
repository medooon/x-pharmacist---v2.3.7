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
⚠️ **PARTIALLY CONFIGURED** - The Flutter environment is set up, but the app has compilation errors due to Flutter version incompatibilities.

### What's Been Completed
1. ✅ Flutter SDK (3.32.0) and Dart (3.8.0) installed via Nix packages
2. ✅ Flutter web support enabled - `web/` directory created
3. ✅ Dependencies installed with `flutter pub get`
4. ✅ Workflow configured to run Flutter web on port 5000
5. ✅ `.gitignore` updated for Flutter web builds
6. ✅ Fixed multiple code compatibility issues:
   - Removed double commas in `home_screen.dart` and `quiz_grid_card.dart`
   - Updated `Switch` widget to use `thumbColor` instead of deprecated `activeThumbColor`
   - Replaced `Matrix4.scaleByDouble()` with `Matrix4.scale()` in 3 files
   - Commented out `very_good_analysis` package (requires Dart SDK >= 3.9.0)
   - Adjusted SDK version constraint from `>=3.8.1` to `>=3.8.0`

### Remaining Issues
The app cannot currently compile due to Flutter 3.32 API changes:

1. **RadioGroup Widget** - 4 files use a `RadioGroup` widget that doesn't exist or isn't imported:
   - `lib/ui/screens/initial_language_selection_screen.dart`
   - `lib/ui/screens/menu/widgets/language_selector_sheet.dart`
   - `lib/ui/screens/menu/widgets/quiz_language_selector_sheet.dart`
   - `lib/ui/screens/menu/widgets/theme_selector_sheet.dart`

2. **RadioListTile API Changes** - Missing required `groupValue` parameter in same 4 files

3. **Dot-shorthands Syntax** - 2 files use experimental dot-shorthand syntax that needs compiler flag:
   - `lib/ui/screens/home/home_screen.dart` (lines 1247-1248)
   - `lib/ui/screens/home/widgets/quiz_grid_card.dart` (lines 78-79, 113)

## Project Structure
```
flutterquiz/
├── lib/               # Main Dart source code
│   ├── app/          # App initialization
│   ├── commons/      # Shared widgets and bottom navigation
│   ├── core/         # Core configuration, constants, theme
│   ├── features/     # Feature modules (ads, auth, badges, quiz, etc.)
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

## Next Steps to Make the App Run
1. Fix RadioGroup widget references (create custom widget or replace with standard Radio/RadioListTile)
2. Add `groupValue` parameter to all RadioListTile widgets
3. Handle dot-shorthands syntax (either remove or ensure proper compilation flags)
4. Test Firebase configuration (may need web-specific setup)
5. Verify asset loading works correctly on web platform

## Firebase Configuration
The app uses Firebase services. The following config files exist:
- `android/app/google-services.json` (Android)
- `ios/Runner/GoogleService-Info.plist` (iOS)

**Note**: Web Firebase configuration may need to be added to `web/index.html`

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

## Recent Changes
- **Dec 3, 2025**: Initial Replit setup, Flutter installed, web support enabled, multiple compatibility fixes applied

## Original Documentation
See README.md for original build instructions and rebranding guide.
