# Flutter Client

This folder contains the Flutter mobile client code for the attendance platform.

Because the Flutter SDK was not installed in this environment, native folders such as `android/` and `ios/` were not generated automatically.

## Finish setup locally

```bash
cd flutter
flutter create .
flutter pub get
flutter run --dart-define=API_BASE_URL=https://source-backend-django-production.up.railway.app/api
```

Build an Android APK after native folders are generated:

```bash
flutter build apk --release --dart-define=API_BASE_URL=https://source-backend-django-production.up.railway.app/api
```

Expected APK output path:

```text
flutter/build/app/outputs/flutter-apk/app-release.apk
```
"# source-flutter" 
