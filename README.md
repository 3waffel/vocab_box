# vocab_box

A card memorizing tool, simple and clean to use

## Development

### Generating Icons

Set icon at `assets/icon.png`, then:

```
dart run flutter_launcher_icons
```

### Firebase Integration

```
dart run flutterfire_cli:flutterfire configure
```

### Setup Secrets in GitHub CI

- base64 encoded files:
  - `FIREBASE_OPTIONS_DART` -> `lib/firebase_options.dart`
  - `GOOGLE_SERVICES_JSON` -> `android/app/google-services.json`
  - `KEYSTORE_FILE_BASE64` -> `android/app/upload-keystore.jks`
- keystore properties in `android/key.properties`
  - `KEYSTORE_PASSWORD` -> `storePassword`
  - `KEYSTORE_KEY_PASSWORD` -> `keyPassword`
  - `KEYSTORE_KEY_ALIAS` -> `keyAlias`

### Test Locally 

```
act -W .github/workflows/test.yml --secret-file .secrets -P windows-latest=-self-hosted
```

## Notice

### Windows Release

- This app uses [`sqflite_common_ffi`](https://pub.dev/packages/sqflite_common_ffi), so make sure `sqlite3.dll` is in the same folder as the executable.
