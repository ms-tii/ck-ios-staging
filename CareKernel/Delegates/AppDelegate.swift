//
//  AppDelegate.swift
//  CareKernel
//
//  Created by Mohit Sharma on 30/08/21.
//

import UIKit
import CoreLocation
import Firebase
import FirebaseMessaging
import FirebaseAnalytics
import SwiftyJSON

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    let gcmMessageIDKey = "gcm.message_id"
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        FirebaseConfiguration.shared.setLoggerLevel(.min)
        switch UITraitCollection.current.userInterfaceStyle {
        case .light, .unspecified:
//            UITabBar.appearance().backgroundColor = UIColor.white
            UITabBar.appearance().unselectedItemTintColor = UIColor(named: "Tab Bar Icon Active")
            UITabBar.appearance().tintColor = UIColor(named: "Tab Bar Icon Inactive")

            break
        case .dark:
//            UITabBar.appearance().backgroundColor = UIColor.black
            UITabBar.appearance().unselectedItemTintColor = UIColor(named: "Tab Bar Icon Active")
            UITabBar.appearance().tintColor = UIColor(named: "Tab Bar Icon Inactive")

            break
        default:
            fatalError()
            break
        }

          UNUserNotificationCenter.current().delegate = self

        registerForRichNotifications()

        application.registerForRemoteNotifications()
        Messaging.messaging().delegate = self
        Messaging.messaging().token { token, error in
          if let error = error {
            print("Error fetching FCM registration token: \(error)")
          } else if let token = token {
            print("FCM registration token: \(token)")
              careKernelDefaults.set(token, forKey: "FCMToken")
          }
        }
//        if launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] != nil {
//             // Move to your required viewcontroller here
//            print("from notification")
//            careKernelDefaults.set("from notification", forKey: "navigateFrom")
//        }else{
//            print("direct")
//            careKernelDefaults.set("direct", forKey: "navigateFrom")
//        }
        return true
    }

    func registerForRichNotifications() {
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.badge,.sound]) { (granted:Bool, error:Error?) in
            if error != nil {
                print("error?.localizedDescription")
            }
            var isFcmEnable = Bool()
            if granted {
                print("Permission granted")
                isFcmEnable = true
            } else {
                print("Permission not granted")
                isFcmEnable = false
            }
            careKernelDefaults.set(isFcmEnable, forKey: "isFcmEnableForLogin")
        }
        
    }
    
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print(deviceToken.hexString)
      Messaging.messaging().apnsToken = deviceToken
    }
    
}


extension AppDelegate: UNUserNotificationCenterDelegate {
  // Receive displayed notifications for iOS 10 devices.
  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification,
                              withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions)
                                -> Void) {
    let userInfo = notification.request.content.userInfo

    // With swizzling disabled you must let Messaging know about the message, for Analytics
     Messaging.messaging().appDidReceiveMessage(userInfo)

    // ...

    // Print full message.
    print(userInfo)
      NotificationCenter.default.post(name: Notification.Name.init(rawValue: "pushNotificationUpdate"), object: nil, userInfo: nil)
    // Change this to your preferred presentation option
      completionHandler([[.alert, .sound, .badge]])
  }

  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse,
                              withCompletionHandler completionHandler: @escaping () -> Void) {
    let userInfo = response.notification.request.content.userInfo

    // ...

    // With swizzling disabled you must let Messaging know about the message, for Analytics
     Messaging.messaging().appDidReceiveMessage(userInfo)

      UIApplication.shared.applicationIconBadgeNumber = 0
      let body = JSON(userInfo)["aps"]["alert"]["body"].stringValue
      let title = JSON(userInfo)["aps"]["alert"]["title"].stringValue
      let entityId = JSON(userInfo)["entityId"].stringValue
      let entityType = JSON(userInfo)["entityType"].stringValue
      let notificationId = JSON(userInfo)["notificationId"].stringValue
      
      print(body,title,entityId,entityType,notificationId)
      careKernelDefaults.set(true, forKey: "isNotification")
      // retrieve the root view controller (which is a tab bar controller)
          guard let rootViewController = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window?.rootViewController else {
              return
          }
        
          let storyboard = UIStoryboard(name: "Main", bundle: nil)

          // instantiate the view controller we want to show from storyboard
          // root view controller is tab bar controller
          // the selected tab is a navigation controller
          // then we present the new view controller to it
      switch entityType {
      case "SESSION":
          if  let sessionDetailsVC = storyboard.instantiateViewController(withIdentifier: "SessionDetailsViewController") as? SessionDetailsViewController,
              let tabBarController = rootViewController as? UITabBarController{
              sessionDetailsVC.modalPresentationStyle = .fullScreen
              sessionDetailsVC.sessionId = Int(entityId) ?? 0
              sessionDetailsVC.notificationId = Int(notificationId) ?? 0
              tabBarController.selectedViewController?.present(sessionDetailsVC, animated: true, completion: nil)
          }
          break
      case "INQUIRY":
          
          break
      case "CLIENT":
          
          break
      case "TASK":
          if  let taskDetailsVC = storyboard.instantiateViewController(withIdentifier: "TaskDetailsViewController") as? TaskDetailsViewController,
              let tabBarController = rootViewController as? UITabBarController{
              taskDetailsVC.modalPresentationStyle = .fullScreen
              taskDetailsVC.taskID = Int(entityId)!
              taskDetailsVC.notificationId = Int(notificationId)!
              tabBarController.selectedViewController?.present(taskDetailsVC, animated: true, completion: nil)
          }
          break
      default:
          break
      }
      
      
          
      completionHandler()
  }
    

    
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
      print("Firebase registration token: \(String(describing: fcmToken))")
        careKernelDefaults.set(fcmToken ?? "", forKey: "FCMToken")
      let dataDict: [String: String] = ["token": fcmToken ?? ""]
      NotificationCenter.default.post(
        name: Notification.Name("FCMToken"),
        object: nil,
        userInfo: dataDict
      )
      // TODO: If necessary send token to application server.
      // Note: This callback is fired at each app startup and whenever a new token is generated.
//    eB3oDqXJtk5CiYGjYQDh3p:APA91bFB2uAY3TLAcoF37y2u_paXY_yHXSgt-252DkIayM8KLaBldyb57aLh6iRfOv1Whcnzci9S_yzq84HBLdwu2C8KZ_xP2SOU8pOdytUVBpdy0WfouPva6nT8kDBvWVrBUXydtNyI
    }
    
    
}
extension Data {
  var hexString: String {
    let hexString = map { String(format: "%02.2hhx", $0) }.joined()
    return hexString
  }
}
