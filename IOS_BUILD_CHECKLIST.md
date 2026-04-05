# iOS Build Checklist

This Flutter app is prepared locally for iOS, but the actual build must be done on a Mac with Xcode.

## Current App Details

- App name: `BSZone`
- Bundle identifier: `com.bszone.coconuterp`
- Minimum iOS version: `13.0`

## Before Opening Xcode

1. Install the latest stable Flutter SDK on the Mac.
2. Install Xcode from the App Store.
3. Install CocoaPods if needed:

```bash
sudo gem install cocoapods
```

4. Clone or copy this Flutter project to the Mac.

## Build Preparation

Run these commands:

```bash
cd /path/to/flutter
flutter clean
flutter pub get
cd ios
pod install
cd ..
open ios/Runner.xcworkspace
```

## Xcode Setup

1. Select the `Runner` target.
2. Open `Signing & Capabilities`.
3. Choose your Apple Developer Team.
4. Confirm the bundle identifier:
   `com.bszone.coconuterp`
5. If this bundle id is already used in your Apple account, change it to your own unique id.
6. Set the deployment target to `iOS 13.0` or higher.
7. Choose a real iPhone or `Any iOS Device (arm64)` as the target.

## Build Commands

Debug / device build:

```bash
flutter build ios
```

Release archive for App Store / TestFlight:

```bash
flutter build ipa
```

## What Was Already Prepared

- Branded iOS app icon set
- Branded launch screen artwork
- App display name updated to `BSZone`
- Bundle id updated from the default example id
- CocoaPods `Podfile` added for plugin-based builds

## Recommended Final Checks

1. Confirm the app opens and the login screen appears.
2. Verify the live backend URL is correct in your Flutter config.
3. Test login with a real user.
4. Test dashboard load.
5. Test work log creation.
6. Test offline queue behavior if the device goes offline.
7. Archive once more after signing is stable.

## Optional Follow-Up

- Replace the bundle id with your company-specific identifier.
- Add Apple app privacy strings if camera, photos, or location are enabled later.
- Add a production app icon variant if you want a stronger App Store presence.
