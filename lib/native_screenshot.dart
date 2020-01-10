import 'dart:async';

import 'package:flutter/services.dart';

class NativeScreenshot {
  static const MethodChannel _channel =
      const MethodChannel('native_screenshot');

  static Future<String> takeScreenshot() async {
    final String path = await _channel.invokeMethod('takeScreenshot');
    
    return path;
  } // takeScreenshot() 
} // NativeScreenshot