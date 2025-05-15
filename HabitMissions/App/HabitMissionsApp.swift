import SwiftUI
import FirebaseCore

@main
struct HabitMissionsApp: App {
    // Register app delegate for Firebase setup and Push Notifications
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
