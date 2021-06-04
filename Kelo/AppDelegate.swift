//
//  AppDelegate.swift
//  Kelo
//
//  Created by Raul Olmedo on 23/3/21.
//

import UIKit
import Firebase
import SwiftyBeaver

let log = SwiftyBeaver.self

protocol NotificationDelegate: AnyObject {
    func didReceivedNotification()
}

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    weak var notificationDelegate: NotificationDelegate?
    let gcmMessageIDKey = "gcm.message_id"

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // Setup Firebase
        FirebaseApp.configure()

        // Setup logging framework
        let console = ConsoleDestination()
        console.format = "$Dyyyy-MM-dd HH:mm:ss.SSSSSSZZ$d $N.$F $L $M"
        console.levelString.verbose = "🔵 VERBOSE"
        console.levelString.debug = "🟢 DEBUG"
        console.levelString.info = "🟡 INFO"
        console.levelString.warning = "🟠 WARNING"
        console.levelString.error = "🔴 ERROR"
        console.minLevel = .verbose
        log.addDestination(console)

        // Setup notifications
        Messaging.messaging().delegate = self

        UNUserNotificationCenter.current().delegate = self

        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: {_, _ in })

        UIApplication.shared.registerForRemoteNotifications()

        return true
    }

    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        /* If any sessions were discarded while the application was not running, this will be called shortly after
            application:didFinishLaunchingWithOptions. */
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

}

extension AppDelegate: MessagingDelegate {

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        log.debug("Firebase registration token: \(fcmToken ?? "nil")")

        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)

    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent
                                    notification: UNNotification,
                                withCompletionHandler
                                    completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

        completionHandler([[.banner, .sound]])

        notificationDelegate?.didReceivedNotification()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {

        completionHandler()

        notificationDelegate?.didReceivedNotification()
    }

}
