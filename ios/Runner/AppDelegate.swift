import UIKit
import Flutter
import Firebase
import NaverThirdPartyLogin

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
  override func application(_ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    if #available(iOS 10.0, *) {
        //For iOS 10 display notification (sent via APNS)
        UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in})
    } else {
        let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
        application.registerUserNotificationSettings(settings)
    }
    
    application.registerForRemoteNotifications()
    FirebaseApp.configure()
    
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    

  override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    var applicationResult = false
    if (!applicationResult) {
       applicationResult = NaverThirdPartyLoginConnection.getSharedInstance().application(app, open: url, options: options)
    }
    if (!applicationResult) {
       applicationResult = super.application(app, open: url, options: options)
    }
    return applicationResult
  }



    override func application(_ application: UIApplication, continue userActivity: NSUserActivity,
        restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
             guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
                 let incomingURL = userActivity.webpageURL
             
                 else {
                     return false
                 }

             let iosLinkMethodChannel = FlutterMethodChannel(name: "thinkpool.flutter.dev/channel_method_link_ios",
             binaryMessenger: (window?.rootViewController as! FlutterViewController).binaryMessenger)
             iosLinkMethodChannel.invokeMethod("\(incomingURL)", arguments: nil)
             print("DEEPLINK :: UniversialLink was clicked !! incomingURL - \(incomingURL)")
             NSLog("UNIVERSAL LINK OPEN!!!!!!!!!!!!!!!!!")

             if(incomingURL.absoluteString.hasPrefix("http")) {
                return false
             }
             
             return true
         }
    
   
}
