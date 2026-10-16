import Flutter
import UIKit
import GoogleMaps
@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
  Bool {
    GMSServices.provideAPIKey("AIzaSyCXdA8wvGxoj0dAsOzdlESUl8CFMLyfTAE")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(didFinishLaunchingWithOptions: launchOptions)
  }
}
