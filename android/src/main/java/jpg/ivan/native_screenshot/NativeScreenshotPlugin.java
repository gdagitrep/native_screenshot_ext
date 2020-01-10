package jpg.ivan.native_screenshot;

import android.Manifest;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.Rect;
import android.net.Uri;
import android.os.Build;
import android.os.Environment;
import android.os.Handler;
import android.util.Log;
import android.view.PixelCopy;
import android.view.View;
import android.view.Window;

import androidx.annotation.NonNull;

import java.io.File;
import java.io.FileOutputStream;
import java.util.Date;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.embedding.engine.renderer.FlutterRenderer;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** NativeScreenshotPlugin */
public class NativeScreenshotPlugin implements MethodCallHandler, FlutterPlugin, ActivityAware {
  private static final String TAG = "NativeScreenshotPlugin";

  private MethodChannel channel;
  private ActivityPluginBinding activityBinding;
  private FlutterRenderer renderer;
  private Context context;

  private boolean ssError = false;
  private String ssPath;

  public NativeScreenshotPlugin() {}

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    this.channel = new MethodChannel(
            flutterPluginBinding.getFlutterEngine().getDartExecutor(),
            "native_screenshot"
    ); // MethodChannel()

    this.channel.setMethodCallHandler(this);

    this.renderer = flutterPluginBinding.getFlutterEngine().getRenderer();
    this.context = flutterPluginBinding.getApplicationContext();
  } // onAttachedToEngine()

  public static void registerWith(Registrar registrar) {
    NativeScreenshotPlugin instance = new NativeScreenshotPlugin();

    instance.channel = new MethodChannel(registrar.messenger(), "native_screenshot");
    instance.channel.setMethodCallHandler(instance);
  } // registerWith()

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if( !permissionToWrite() ) {
      result.success(null);

      return;
    } // if cannot write

    if( !call.method.equals("takeScreenshot") ) {
      result.notImplemented();

      return;
    } // if not implemented


    // Need to fix takeScreenshot()
    // it produces just a black image
    if( Build.VERSION.SDK_INT >= Build.VERSION_CODES.O ) {
      // takeScreenshot();
      takeScreenshotOld();
    } else {
      takeScreenshotOld();
    } // if

    if( this.ssError || this.ssPath == null || this.ssPath.isEmpty() ) {
      result.success(null);

      return;
    } // if error

    result.success(this.ssPath);
  } // onMethodCall()

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    this.channel.setMethodCallHandler(null);
    this.channel = null;
    this.context = null;
  } // onDetachedFromEngine()

  private String getScreenshotName() {
    java.text.SimpleDateFormat sf = new java.text.SimpleDateFormat("yyyyMMddHHmmss");
    String sdate = sf.format( new Date() );

    return "native_screenshot-" + sdate + ".png";
  } // getScreenshotName()

  private String getScreenshotPath() {
    return Environment.getExternalStorageDirectory().toString() + "/" + getScreenshotName();
  } // getScreenshotPath()

  private String writeBitmap(Bitmap bitmap) {
    try {
      String path = getScreenshotPath();
      File imageFile = new File(path);
      FileOutputStream ostream = new FileOutputStream(imageFile);

      bitmap.compress(Bitmap.CompressFormat.PNG, 100, ostream);
      ostream.flush();
      ostream.close();

      return path;
    } catch(Exception ex) {
      Log.println(Log.INFO, TAG, "Error writing bitmap: " + ex.getMessage());
    }

    return null;
  } // writeBitmap()

  private void reloadMedia() {
    try {
      Intent intent = new Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE);
      File file = new File(this.ssPath);
      Uri uri = Uri.fromFile(file);

      intent.setData(uri);
      this.activityBinding.getActivity().sendBroadcast(intent);
    } catch(Exception ex) {
      Log.println(Log.INFO, TAG, "Error reloading media lib: " + ex.getMessage());
    }
  } // reloadMedia()

  private void takeScreenshot() {
    Log.println(Log.INFO, TAG, "Trying to take screenshot [new way]");

    if(Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
      this.ssPath = null;
      this.ssError = true;

      return;
    }

    try {
      Window window = this.activityBinding.getActivity().getWindow();
      View view = window.getDecorView().getRootView();

      Bitmap bitmap = Bitmap.createBitmap(
              view.getWidth(),
              view.getHeight(),
              Bitmap.Config.ARGB_8888
      ); // Bitmap()

      int[] windowLocation = new int[2];
      view.getLocationInWindow(windowLocation);

      PixelListener listener = new PixelListener();

      PixelCopy.request(
              window,
//              new Rect(
//                      windowLocation[0],
//                      windowLocation[1],
//                      windowLocation[0] + view.getWidth(),
//                      windowLocation[1] + view.getHeight()
//              ),
              bitmap,
              listener,
              new Handler()
      ); // PixelCopy.request()

      if( listener.hasError() ) {
        this.ssError = true;
        this.ssPath = null;

        return;
      } // if error

      String path = writeBitmap(bitmap);
      if( path == null || path.isEmpty() ) {
        this.ssPath = null;
        this.ssError = true;
      } // if no path

      this.ssError = false;
      this.ssPath = path;

      reloadMedia();
    } catch(Exception ex) {
      Log.println(Log.INFO, TAG, "Error taking screenshot: " + ex.getMessage());
    }
  } // takeScreenshot()

  private void takeScreenshotOld() {
    Log.println(Log.INFO, TAG, "Trying to take screenshot [old way]");

    try {
      View view = this.activityBinding.getActivity().getWindow().getDecorView().getRootView();

//      view.measure(
//              View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED),
//              View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED)
//      ); // measure()
//
//      view.layout(
//              0,
//              0,
//              view.getMeasuredWidth(),
//              view.getMeasuredHeight()
//      ); // layout()

      view.setDrawingCacheEnabled(true);
      Bitmap bitmap = this.renderer.getBitmap();
      view.setDrawingCacheEnabled(false);

      String path = writeBitmap(bitmap);
      if( path == null || path.isEmpty() ) {
        this.ssError = true;
        this.ssPath = null;

        return;
      } // if

      this.ssError = false;
      this.ssPath = path;

      reloadMedia();
    } catch(Exception ex) {
      Log.println(Log.INFO, TAG, "Error taking screenshot: " + ex.getMessage());
    }
  } // takeScreenshot()

  private boolean permissionToWrite() {
    if(Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
      return false;
    }

    Activity activity = this.activityBinding.getActivity();

    int perm = activity.checkSelfPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE);

    if(perm == PackageManager.PERMISSION_GRANTED) {
      return true;
    } // if

    activity.requestPermissions(
            new String[] {
                    Manifest.permission.WRITE_EXTERNAL_STORAGE
            },
            11
    ); // requestPermissions()

    return false;
  } // permissionToWrite()

  private void attachAct(ActivityPluginBinding binding) {
    this.activityBinding = binding;
  } // attachAct()

  private void detachAct() {
    this.activityBinding = null;
  } // attachAct()

  @Override
  public void onAttachedToActivity(ActivityPluginBinding binding) {
    attachAct(binding);
  } // onAttachedToActivity()

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    detachAct();
  } // onDetachedFromActivityForConfigChanges()

  @Override
  public void onReattachedToActivityForConfigChanges(ActivityPluginBinding binding) {
    attachAct(binding);
  } // onReattachedToActivityForConfigChanges()

  @Override
  public void onDetachedFromActivity() {
    detachAct();
  } // onDetachedFromActivity()
} // NativeScreenshotPlugin
