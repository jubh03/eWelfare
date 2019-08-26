//
//  AppDelegate.swift
//  WebEwelfare
//
//  Created by 김동석 on 19/02/2019.
//  Copyright © 2019 nam yeon hun. All rights reserved.
//

import UIKit
import UserNotifications
import Alamofire
import AlamofireObjectMapper
import SwiftyJSON
import SwiftyIamport

import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    let gcmMessageIDKey = "gcm.message_id"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        FirebaseApp.configure()
        
        // push
        registerForPushNotifications(application)
        
        // iOS6에서 세션끊어지는 상황 방지하기 위해 쿠키 설정.
        HTTPCookieStorage.shared.cookieAcceptPolicy = .always
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if let scheme = url.scheme {
            if scheme.hasPrefix(IAMPortPay.sharedInstance.appScheme ?? "") {
                return IAMPortPay.sharedInstance.application(app, open: url, options: options)
            }
        }
        return true
    }
    
    // for iOS below 9.0
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        if let scheme = url.scheme {
            if scheme.hasPrefix(IAMPortPay.sharedInstance.appScheme ?? "") {
                return IAMPortPay.sharedInstance.application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
            }
        }
        return true
    }

    // Called when APNs has assigned the device a unique token
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Convert token to string (디바이스 토큰 값을 가져옵니다.)
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        
        // Print it to console(토큰 값을 콘솔창에 보여줍니다. 이 토큰값으로 푸시를 전송할 대상을 정합니다.)
        print("APNs device token: \(deviceTokenString)")
        
        Messaging.messaging().apnsToken = deviceToken
        
        // Persist it in your backend in case it's new
    }
    
    private func registerForPushNotifications(_ application: UIApplication) {
        Messaging.messaging().delegate = self
        Messaging.messaging().shouldEstablishDirectChannel = true
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
    }

}


@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    //포그라운드 에서 노티가 왔을때 발생하는 메서드
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        // Change this to your preferred presentation option
        completionHandler([UNNotificationPresentationOptions.alert, UNNotificationPresentationOptions.sound, UNNotificationPresentationOptions.badge])
    }
    
    // 백그라운드에서 노티를 눌렀을때 반응하는 메서드
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        let body = response.notification.request.content.body
        
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        self.checkLink(userInfo, body)
        self.checkPushId(userInfo, body)
        
        // Print full message.
        print(userInfo)
        
        completionHandler()
    }
    
    private func checkLink(_ userInfo: [AnyHashable : Any], _ body: String) {
        if let link = userInfo["url"] as? String {
            if let type = userInfo["type"] as? String {
                if type == "in" || type == "out" {
                    AppManager.instance.pushUrlType = type
                    AppManager.instance.pushUrl = link
                    
                    NotificationCenter.default.post(name: Notification.Name("receivedPush"), object: nil)
                }
            }
        }
    }
    
    private func checkPushId(_ userInfo: [AnyHashable : Any], _ body: String) {
        if let pushId = userInfo["push_id"] as? String {
            // url
            let url: String = WDefine.API + "push/status"
            
            // parameter
            var parameters: Parameters = Parameters()
            parameters["push_id"] = pushId
            
            Alamofire.request(url,
                              method: .post,
                              parameters: parameters,
                              encoding: JSONEncoding.default,
                              headers: AlamofireHelper.instance.headers).responseObject { (response: DataResponse<ResLogin>) in
                                // noting
            }
        }

    }
    
}


extension AppDelegate : MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        
        AppManager.instance.fcmToken = fcmToken
        
        let dataDict:[String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
    
    // Receive data messages on iOS 10+ directly from FCM (bypassing APNs) when the app is in the foreground.
    // To enable direct data messages, you can set Messaging.messaging().shouldEstablishDirectChannel to true.
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("Received data message: \(remoteMessage.appData)")
        
    }
    
}
