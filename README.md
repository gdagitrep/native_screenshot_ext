# native_screenshot

This plugin aims to be a simple one that implements taking screenshot natively to capture scenes like camera preview or AR views. This cannot be done easily in plain Flutter, at least I cannot make it work using `RenderRepaintBoundary` and similar techniques.

This is based on [screenshot_share_image](https://pub.dev/packages/screenshot_share_image) and [capture_and_share](https://pub.dev/packages/capture_and_share) packages. Thanks to [@toonztudio](https://github.com/toonztudio) for pointing me out replying in Github.

The main difference is that those packages shows a share dialog. This plugin saves the image and returns the path to it. On **Android** also launch an updating request to reload the media library.

## Instalation

Add

> `native_screenshot: ^0.0.1`

to your `pubspec.yaml` file.

### Android
You must add

> `<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />`

to your `AndroidManifest.xml` inside `android/src/main/` directory.

## Use

Import the library:

> `import 'package:native_screenshot/native_screenshot.dart';`

and take a screenshot:

> `String path = NativeScreenshot.takeScreenshot()`

In error case the function returns `null` and the screenshot path if success.