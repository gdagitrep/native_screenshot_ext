#import "NativeScreenshotPlugin.h"
#if __has_include(<native_screenshot_ext/native_screenshot_ext-Swift.h>)
#import <native_screenshot_ext/native_screenshot_ext-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "native_screenshot_ext-Swift.h"
#endif

@implementation NativeScreenshotPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftNativeScreenshotPlugin registerWithRegistrar:registrar];
}
@end
