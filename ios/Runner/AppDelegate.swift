import Flutter
import UIKit
import workmanager

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // This is required to make any communication available in the action isolate.
    FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
      GeneratedPluginRegistrant.register(with: registry)
    }

    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }

    WorkmanagerPlugin.registerTask(withIdentifier: "bg-noti")
    class AppDelegate:UIResponder,UIApplicationDelegate{
    func application(_ application:UIApplication,didFinishLaunchingWithOptions launchOptions:[UIApplicationLaunchOptionsKey:Any]?)->Bool{
        // Other intialization code…
        UIApplication.shared.setMinimumBackgroundFetchInterval(TimeInterval(60*2))

        return true
    }
}

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
