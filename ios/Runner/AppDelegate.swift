import Flutter
import UIKit
import GoogleMaps
import FirebaseMessaging

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("AIzaSyCjn7a1DvwWkzUHC4eAzZo4zSVEZJ9F5Ao")

    // Explicitly kick off APNs device token registration at launch. Relying
    // solely on Firebase's automatic swizzling / the Dart-side
    // requestPermission() call has proven unreliable for getting
    // didRegisterForRemoteNotificationsWithDeviceToken to fire, leaving
    // getAPNSToken() stuck at null.
    application.registerForRemoteNotifications()

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }

  // Firebase's automatic AppDelegate swizzling can fail to wire up the APNs
  // device token in some configurations (e.g. with FlutterImplicitEngineDelegate),
  // which leaves getAPNSToken() returning null forever and FCM registration
  // throwing apns-token-not-set. Explicitly forward the token to Firebase
  // Messaging here as a reliable fallback.
  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    Messaging.messaging().apnsToken = deviceToken
    debugPrint("APNs device token received and forwarded to FirebaseMessaging")
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }

  override func application(
    _ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
    debugPrint("Failed to register for remote notifications: \(error)")
    super.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
  }
}
