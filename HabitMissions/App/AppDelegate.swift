//
//  AppDelegate.swift
//  HabitMissions
//
//  Created by David Springean on 15.05.25.
//


import UIKit
import FirebaseCore
import FirebaseMessaging

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Configure Firebase
        FirebaseApp.configure()
        
        // Configure Notifications
        NotificationService.shared.configure()
        
        return true
    }
    
    // Handle receiving notification data when app is in background
    func application(_ application: UIApplication,
                    didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                    fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        #if DEBUG
        print("Received remote notification: \(userInfo)")
        #endif
        
        completionHandler(.newData)
    }
    
    // Handle APNs token
    func application(_ application: UIApplication,
                    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
}