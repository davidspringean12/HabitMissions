import UIKit
import UserNotifications
import FirebaseMessaging

class NotificationService: NSObject, UNUserNotificationCenterDelegate, MessagingDelegate {
    static let shared = NotificationService()
    
    // Single notification sound for the entire app
    private let appNotificationSound: UNNotificationSound = {
        return UNNotificationSound(named: UNNotificationSoundName("notification.wav"))
    }()
    
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
                // Add debug information about the sound file
                if let soundURL = Bundle.main.url(forResource: "notification", withExtension: "wav") {
                    print("Sound file exists at path: \(soundURL)")
                } else {
                    print("Sound file not found in bundle!")
                }
            }
        }
        
        Messaging.messaging().delegate = self
    }
    
    func scheduleDailyReminder(for mission: Mission, at time: Date, completion: ((Error?) -> Void)? = nil) {
        print("Debug - Starting scheduleDailyReminder")
        let content = UNMutableNotificationContent()
        content.title = "Mission Control"
        content.body = "Time for your mission: \(mission.name)"
        content.sound = appNotificationSound // Use the app's custom sound
        
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
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling notification: \(error.localizedDescription)")
                }
                completion?(error)
            }
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
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling notification: \(error.localizedDescription)")
                }
                completion?(error)
            }
        }
    }
    
    func sendStreakNotification(streakCount: Int, missionName: String) {
        let content = UNMutableNotificationContent()
        content.title = "🔥 Streak Achievement!"
        content.body = "Amazing work keeping up with '\(missionName)' for \(streakCount) days!"
        content.sound = appNotificationSound // Use the app's custom sound
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error sending streak notification: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }
}
