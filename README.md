# Flutter Client

This folder contains the Flutter mobile client code for the attendance platform.

Because the Flutter SDK was not installed in this environment, native folders such as `android/` and `ios/` were not generated automatically.

## Finish setup locally

```bash
cd flutter
flutter create .
flutter pub get
flutter run --dart-define=API_BASE_URL=http://localhost:4000/api
```

When your Railway backend is live, replace the local URL with your deployed API URL.
"# source-flutter" 
