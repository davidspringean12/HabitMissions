import Foundation
import UserNotifications
import FirebaseMessaging
import UIKit

class NotificationService: NSObject, UNUserNotificationCenterDelegate, MessagingDelegate {
    static let shared = NotificationService()
    
    func configure() {
        UNUserNotificationCenter.current().delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
            
            if let error = error {
                print("Error requesting notification authorization: \(error.localizedDescription)")
            }
        }
        
        Messaging.messaging().delegate = self
    }
    
    // Schedule Daily Reminder
    func scheduleDailyReminder(for mission: Mission, at time: Date, completion: ((Error?) -> Void)? = nil) {
            let content = UNMutableNotificationContent()
            content.title = "Mission Control"
            content.body = "Time for your mission: \(mission.name)"
            content.sound = .default
        
        // For testing, if the time is within 30 seconds of now, use a time interval trigger
                let now = Date()
                if abs(time.timeIntervalSince(now)) < 30 {
                    let trigger = UNTimeIntervalNotificationTrigger(
                        timeInterval: 5, // 5 seconds for testing
                        repeats: false
                    )
                    
                    let request = UNNotificationRequest(
                        identifier: "mission-\(mission.id)-\(Date().timeIntervalSince1970)",
                        content: content,
                        trigger: trigger
                    )
                    
                    UNUserNotificationCenter.current().add(request, withCompletionHandler: completion)
                } else {
                    // Normal daily reminder
                    let calendar = Calendar.current
                    let components = calendar.dateComponents([.hour, .minute], from: time)
                    let trigger = UNCalendarNotificationTrigger(
                        dateMatching: components,
                        repeats: true
                    )
                    
                    let request = UNNotificationRequest(
                        identifier: "mission-\(mission.id)-daily",
                        content: content,
                        trigger: trigger
                    )
                    
                    UNUserNotificationCenter.current().add(request, withCompletionHandler: completion)
                }
            }
    
    // Streak Notification
    func sendStreakNotification(streakCount: Int, missionName: String) {
        let content = UNMutableNotificationContent()
        content.title = "🔥 Streak Alert!"
        content.body = "Amazing! You've maintained a \(streakCount) day streak for \(missionName)!"
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([[.banner, .sound]])
    }
    
    // MARK: - MessagingDelegate
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        // Since you mentioned you don't need to handle token refresh,
        // we'll just implement the required delegate method
        #if DEBUG
        if let token = fcmToken {
            print("Firebase registration token: \(token)")
        }
        #endif
    }
}
