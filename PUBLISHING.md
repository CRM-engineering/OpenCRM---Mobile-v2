# Public repository publishing notes

This source is provided for review and testing; a release build has not been verified here.

## Before publishing

1. Confirm ownership and GPL-3.0 compatibility of all included source files and assets. The repository includes the GPL-3.0-only LICENSE; ensure required third-party notices and source obligations are satisfied.
2. Search the source, image metadata, git history and commit authors for private names, emails, tokens, internal URLs and organization references.
3. Check the third-party QuickCRM REST endpoint and any SDK/license terms; it is not bundled here.
4. Replace the Android example application ID, configure your own release signing, and verify Android/macOS network access.
5. Run `flutter doctor`, `flutter pub get`, `flutter analyze`, `flutter test`, `dart run flutter_launcher_icons` and a release build on your development computer.
6. Test login, search, records, and Expo mode against a non-production SuiteCRM instance.
7. Verify Gradle wrapper provenance and checksums against the official Gradle distribution.

## Known constraints

The app targets a legacy QuickCRM REST 4.1 endpoint, not stock SuiteCRM 8 REST. Client-side search filtering and MD5-based legacy login are not substitutes for server-side validation and HTTPS.
