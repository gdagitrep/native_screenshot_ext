import Flutter
import UIKit

public class SwiftNativeScreenshotPlugin: NSObject, FlutterPlugin {
    var controller :FlutterViewController!
    var messenger :FlutterBinaryMessenger
    var result :FlutterResult!
    var screenshotPath :String!

    init(controller: FlutterViewController, messenger: FlutterBinaryMessenger) {
        self.controller = controller
        self.messenger = messenger

        super.init()
    } // init()

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "native_screenshot_ext", binaryMessenger: registrar.messenger())

        let app = UIApplication.shared
        let controller :FlutterViewController = app.delegate!.window!!.rootViewController as! FlutterViewController

        let instance = SwiftNativeScreenshotPlugin(
            controller: controller,
            messenger: registrar.messenger()
        ) // let instance

        registrar.addMethodCallDelegate(instance, channel: channel)
    } // register()

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "takeScreenshot" {
            handleTakeScreenshot(result: result)
        } else if call.method == "takeScreenshotImage" {
            if(call.arguments.count > 0 )
                handleTakeScreenshotImage(result: result, quality: Int(call.arguments[0]))
        }
        result(FlutterMethodNotImplemented)

        return
    }

    func handleTakeScreenshot(result: @escaping FlutterResult) {

        self.result = result

        // FIX: add posibility to choose if gallery or some path
        takeScreenshot(view: controller.view)
    } // handleTakeScreenshot()

    func getScreenshotName() -> String {
        let format = DateFormatter()
        format.dateFormat = "yyyymmddHHmmss"

        let fname :String = "native_screenshot_ext-\(format.string(from: Date())).png"

        return fname
    } // getScreenshotName()

    func getScreenshotPath() -> URL? {
        let paths :[URL] = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

        guard let dir = paths.first else {
            return nil
        } // guard

        return dir.appendingPathComponent( getScreenshotName() )
    } // getScreenshotPath()

    func writeImageToDefaultPath(image: UIImage) -> String? {
        guard let imageData = image.pngData() else {
            return nil
        } // guard

        guard let path = getScreenshotPath() else {
            return nil
        } // guard

        guard let _ = try? imageData.write(to: path) else {
            return nil
        } // guard

        return path.path
    } // writeImageToDefaultPath()

    @objc
    func savedToGalleryDone(image: UIImage, error: NSError?, contextInfo: UnsafeMutableRawPointer?) {
        if error == nil && self.screenshotPath != nil && !self.screenshotPath.isEmpty {
            result(self.screenshotPath)
        } else {
            result(nil)
        }
    } // savedToGalleryDone()

    func writeImageToGallery(image :UIImage) {
        UIImageWriteToSavedPhotosAlbum(
            image,
            self,
            #selector(savedToGalleryDone),
            nil
        ); // UIImageWriteToSavedPhotosAlbum()
    } // writeImageToGallery()

    func captureImage(view: UIView) -> UIImage? {
        let scale :CGFloat = UIScreen.main.scale

        UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.isOpaque, scale)

        view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        let optionalImage :UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return optionalImage
    }

    func takeScreenshot(view: UIView, toImageGallery :Bool = true) {
        let optionalImage :UIImage? = captureImage(view: view)

        guard let image = optionalImage else {
            result(nil)

            return
        } // guard no image

        guard let path = writeImageToDefaultPath(image: image) else {
            result(nil)

            return
        } // guard cannot write image

        self.screenshotPath = path

        writeImageToGallery(image: image)
    } // takeScreenshot()

    func handleTakeScreenshotImage(result: @escaping FlutterResult, quality: Int) {
        let optionalImage :UIImage? = captureImage(view: controller.view)
        guard let image = optionalImage else {
            result(nil)
            return
        }
        guard let imageData = image.pngData() else {
            result(nil)
            return
        }
        result(imageData)
    } // handleTakeScreenshotImage()

} // SwiftNativeScreenshotPlugin
