import Flutter
import UIKit

/// Application delegate for AI Fortune (マイフォーチューン)
/// Handles Flutter engine initialization and plugin registration
@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {

  /// Called when the application launches
  /// - Parameters:
  ///   - application: The singleton app instance
  ///   - launchOptions: Launch options dictionary
  /// - Returns: true if the app launch was handled successfully
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  /// Called when the implicit Flutter engine is initialized
  /// Registers plugins for Flutter framework
  /// - Parameter engineBridge: The Flutter engine bridge for plugin registration
  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
