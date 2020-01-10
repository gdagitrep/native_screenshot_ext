import Flutter
import UIKit

public class SwiftNativeScreenshotPlugin: NSObject, FlutterPlugin {
    var controller :FlutterViewController!
    var messenger :FlutterBinaryMessenger
    
    init(controller: FlutterViewController, messenger: FlutterBinaryMessenger) {
        self.controller = controller
        self.messenger = messenger
        
        super.init()
    } // init()
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "native_screenshot", binaryMessenger: registrar.messenger())
        
        let app = UIApplication.shared
        let controller :FlutterViewController = app.delegate!.window!!.rootViewController as! FlutterViewController

        let instance = SwiftNativeScreenshotPlugin(
            controller: controller,
            messenger: registrar.messenger()
        ) // let instance
        
        registrar.addMethodCallDelegate(instance, channel: channel)
    } // register()

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method != "takeScreenshot" {
            result(FlutterMethodNotImplemented)
        
            return
        } // if
    
        result( takeScreenshot(view: controller.view) )
    } // handle()
    
    func takeScreenshot(view: UIView) -> String? {
        let scale :CGFloat = UIScreen.main.scale
        
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.isOpaque, scale)
        
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        
        let image :UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        guard let imageData = image?.pngData() else {
            return nil
        } // guard
        
        let paths :[URL] = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        guard let dir = paths.first else {
            return nil
        } // guard
        
        let format = DateFormatter()
        format.dateFormat = "yyyymmddHHmmss"
        
        let fname :String = "native_screenshot-\(format.string(from: Date())).png"
        let fpath = dir.appendingPathComponent(fname)
        
        guard let _ = try? imageData.write(to: fpath) else {
            return nil
        } // guard
        
        return fpath.path
    } // takeScreenshot()
} // SwiftNativeScreenshotPlugin
