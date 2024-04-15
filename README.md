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

### Setup Secrets in CI

- `FIREBASE_OPTIONS_DART`
- `GOOGLE_SERVICES_JSON`
- `KEYSTORE_FILE_BASE64`

- `KEYSTORE_PASSWORD`
- `KEYSTORE_KEY_PASSWORD`
- `KEYSTORE_KEY_ALIAS`

### Test Locally 

```
act -W .github/workflows/test.yml --secret-file .secrets
```

## Notice

### Windows Release

- This app uses [`sqflite_common_ffi`](https://pub.dev/packages/sqflite_common_ffi), so make sure `sqlite3.dll` is in the same folder as the executable.
