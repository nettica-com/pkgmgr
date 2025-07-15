
# pkgmgr

Flutter plugin to list all installed apps on Android using the Package Manager API (with QUERY_ALL_PACKAGES permission). Returns app name, package id, and icon (base64 PNG). iOS returns an empty list.

## Android Setup

- The plugin requests `QUERY_ALL_PACKAGES` in `AndroidManifest.xml` for full package visibility.
- No additional setup is required.

## iOS Setup

- The plugin returns an empty list on iOS.

## Usage

```dart
import 'package:pkgmgr/pkgmgr.dart';

void main() async {
  final pkgmgr = Pkgmgr();
  final apps = await pkgmgr.getInstalledApps();
  for (final app in apps) {
    print('Name: \\${app.name}, Package: \\${app.packageId}');
    // app.iconBase64 is a base64-encoded PNG
  }
}
```

## Building from Command Line

Run:

```sh
flutter build apk # or flutter build ios
```

## License

MIT

