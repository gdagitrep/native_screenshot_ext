import 'dart:async';

import 'package:flutter/services.dart';

/// Class to capture screenshots with native code working on background
class NativeScreenshot {
	/// Comunication property to talk to the native background code.
	static const MethodChannel _channel =
	const MethodChannel('native_screenshot_ext');

	/// Captures everything as is shown in user's device.
	///
	/// Returns [null] if an error ocurrs.
	/// Returns a [String] with the path of the screenshot.
	static Future<String?> takeScreenshot() async {
		final String? path = await _channel.invokeMethod('takeScreenshot');

		return path;
	} // takeScreenshot()

	/// Captures everything as is shown in user's device.
	///
	/// Returns a [List<int>] with the png data for the screenshot,
	/// or [null] if an error occurs.
	static Future<List<int>?> takeScreenshotImage() async {
		final List<int>? image = await _channel.invokeMethod('takeScreenshotImage');
		return image;
	}
} // NativeScreenshot
