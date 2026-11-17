# OpenCRM Mobile

An open-source Flutter CRM client for compatible SuiteCRM installations. This repository is a **community project**, not an official SuiteCRM application.

## Features in the source

- Login and session handling
- Accounts, Contacts, Leads, Opportunities, Tasks, Calls, and Meetings screens and services
- Dashboard and CRM statistics
- Expo / event lead capture mode
- Secure local credential storage via `flutter_secure_storage`

Features and behavior depend on server-side permissions and the installed API. **Not all platforms and features have been independently tested in this public package.**

## Requirements

- **Flutter SDK** compatible with **Dart 3.9 or later** (see `pubspec.yaml` and `pubspec.lock`)
- Git and a supported IDE (VS Code with Flutter/Dart extensions, or Android Studio)
- For Android: Android Studio, Android SDK, Java/JDK as required by your installed Flutter/Gradle versions, and a device or emulator
- For iOS: macOS, Xcode, CocoaPods as required by Flutter, and Apple signing for device distribution
- A running **SuiteCRM** server with HTTPS and an account authorized to use the required modules
- The **QuickCRM REST 4.1 endpoint** at `/custom/QuickCRM/rest4_1.php` on that server. **This is not included in this repository**; a stock SuiteCRM install without that endpoint will not work unchanged.

The source was developed against a SuiteCRM 7.x-style legacy API. SuiteCRM 8.x compatibility is **not established**. Review the QuickCRM endpoint's distribution/license and your server's security settings before deploying.

## Install and run

1. Install Flutter and the relevant platform SDK; verify with `flutter doctor`.
2. Clone the repository and open a terminal in its root.
3. Fetch dependencies:

   ```bash
   flutter pub get
   ```

4. Confirm your CRM server exposes `https://YOUR-SERVER/custom/QuickCRM/rest4_1.php` (adjust the base path if CRM is installed in a subdirectory).
5. Run on Android (or a supported target):

   ```bash
   flutter devices
   flutter run --dart-define=CRM_URL=https://crm.example.com
   ```

   For a CRM installed under `/crm`, use `CRM_URL=https://crm.example.com/crm`.

6. Sign in using an authorized SuiteCRM account.

### Expo mode

Expo mode uses a dedicated server-side CRM user. Configure its **username** at build/run time:

```bash
flutter run --dart-define=CRM_URL=https://crm.example.com/crm --dart-define=EXPO_USERNAME=expo
```

Create that user in your CRM with **least-privilege permissions**. The password is entered in the app, not committed to source. Avoid sharing privileged CRM accounts with public kiosks.

### Build an Android APK

```bash
flutter build apk --release --dart-define=CRM_URL=https://crm.example.com/crm --dart-define=EXPO_USERNAME=expo
```

The resulting APK is normally under `build/app/outputs/flutter-apk/`. Configure your own application ID, signing keys, icons, and store metadata before distribution.

## Configuration

| Variable | Purpose | Default |
| --- | --- | --- |
| `CRM_URL` | Base URL of your SuiteCRM deployment (no trailing slash) | `https://crm.example.com` (placeholder) |
| `EXPO_USERNAME` | Dedicated CRM username for Expo mode | `expo` |

The API endpoint path is configured in `lib/config/app_config.dart` as `/custom/QuickCRM/rest4_1.php`. If your deployment differs, change it there. Do not commit credentials, tokens, signing keys, or real customer data.

## Project structure

- `lib/config/` — application configuration
- `lib/models/` — CRM data models
- `lib/services/` — authentication, API and business logic
- `lib/screens/` — module screens and forms
- `lib/widgets/` — reusable UI components
- `docs/` — architecture and historical roadmap

## Security and compatibility notes

- Use HTTPS with a valid certificate. Never disable TLS certificate verification for production.
- The application uses a legacy REST endpoint and MD5-formatted password authentication expected by that API. This is **not modern OAuth/OIDC**. Evaluate your threat model before exposing the API publicly.
- Some legacy SuiteCRM installations restrict client-supplied API query filters. **Do not disable security restrictions solely to make this app work** without evaluating the impact and restricting API access appropriately.
- Review the security of the third-party QuickCRM endpoint independently.
- This release is source-cleaned for generic use, but has **not been fully compiled or end-to-end tested** in this environment.

## Development checks

```bash
flutter pub get
flutter analyze
flutter test
```

There may be no substantive automated tests yet; contributors are welcome to add them.

## License

This project is licensed under the **GNU General Public License v3.0 only (GPL-3.0-only)**. See [LICENSE](LICENSE) for the full terms. Before publishing, confirm that you have the rights to distribute all included code and assets under this license; third-party dependencies retain their own licenses.

## Disclaimer

Independent community project; not affiliated with or endorsed by SuiteCRM or QuickCRM. Names and trademarks belong to their respective owners.

## Publishing and release checklist

- Replace the example Android `applicationId` / `namespace` with a unique identifier you own.
- Configure your own release signing keys **outside** the repository. The sample Android release currently uses debug signing for local testing and is **not store-ready**.
- Run `flutter pub get`, `flutter analyze`, `flutter test` and `flutter build apk --release` on a supported Flutter toolchain.
- Run `dart run flutter_launcher_icons` to generate launcher icons from the generic artwork in `assets/icon/`.
- For macOS, release entitlements include outgoing network access. Test an actual sandboxed release build.
- Verify that you own the rights to publish all source code and bundled assets, and review third-party licenses, especially QuickCRM-related integration code.
- Confirm the legacy API's security posture before exposing a CRM server to the internet.

**Security note:** Kiosk credentials stored on a device should be restricted to a least-privileged CRM user and the device should be locked down.
