# GitHub iOS Build Secrets

Add these repository secrets in GitHub before running the `Build iOS IPA` workflow.

Repository path:
- `source-flutter`

GitHub path:
- `Settings -> Secrets and variables -> Actions -> New repository secret`

## Required Secrets

### `IOS_BUILD_CERTIFICATE_BASE64`

Base64 value of your Apple distribution certificate `.p12` file.

Example on Mac:

```bash
base64 -i ios_distribution.p12 | pbcopy
```

### `IOS_P12_PASSWORD`

Password used when exporting the `.p12` certificate.

### `IOS_MOBILEPROVISION_BASE64`

Base64 value of the iOS provisioning profile `.mobileprovision`.

Example on Mac:

```bash
base64 -i AppStore.mobileprovision | pbcopy
```

### `IOS_KEYCHAIN_PASSWORD`

Any strong temporary password for the GitHub Actions temporary keychain.

Example:

```text
TempKeychainPassword123!
```

## How To Run

1. Push this repo to GitHub.
2. Add the secrets above.
3. Open GitHub Actions.
4. Choose `Build iOS IPA`.
5. Click `Run workflow`.
6. Download the generated `bszone-ios-ipa` artifact after success.

## Notes

- The workflow expects the app bundle id to be:
  `com.bszone.coconuterp`
- If you change the bundle id later, update:
  - `ios/Runner.xcodeproj/project.pbxproj`
  - `.github/workflows/ios-build.yml`
- The provisioning profile must match the same bundle id.
