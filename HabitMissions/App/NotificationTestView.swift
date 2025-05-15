import SwiftUI
import UserNotifications

struct NotificationTestView: View {
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var notificationStatus = "Checking..."
    
    // Sample mission for testing
    let testMission = Mission(
        id: UUID().uuidString,
        userId: "davidspringean12",
        name: "Test Mission",
        category: .physicalTraining,
        type: .daily,
        startDate: Date(),
        frequency: [.monday, .wednesday, .friday],
        goalPerDay: 1,
        preferredTimeOfDay: Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()),
        isActive: true,
        reminders: [],
        currentStreak: 0,
        bestStreak: 0,
        totalCompletions: 0,
        missedDays: 0,
        lastCompleted: nil,
        completionLog: []
    )
    
    var body: some View {
        List {
            Section(header: Text("Notification Status")) {
                Text(notificationStatus)
            }
            
            Section(header: Text("Test Local Notifications")) {
                Button("Test Daily Reminder (5 seconds)") {
                    let content = UNMutableNotificationContent()
                    content.title = "Mission Control"
                    content.body = "Time for your mission: \(testMission.name)"
                    content.sound = .default
                    
                    // Create trigger for 5 seconds from now
                    let trigger = UNTimeIntervalNotificationTrigger(
                        timeInterval: 5,
                        repeats: false
                    )
                    
                    let request = UNNotificationRequest(
                        identifier: "mission-\(testMission.id)-test",
                        content: content,
                        trigger: trigger
                    )
                    
                    UNUserNotificationCenter.current().add(request) { error in
                        DispatchQueue.main.async {
                            if let error = error {
                                alertMessage = "Error scheduling notification: \(error.localizedDescription)"
                            } else {
                                alertMessage = "Notification scheduled for 5 seconds from now"
                            }
                            showingAlert = true
                        }
                    }
                }
                
                Button("Test Streak Notification") {
                    NotificationService.shared.sendStreakNotification(
                        streakCount: 7,
                        missionName: testMission.name
                    )
                    alertMessage = "Streak notification sent"
                    showingAlert = true
                }
                
                Button("List Pending Notifications") {
                    UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
                        DispatchQueue.main.async {
                            alertMessage = "Pending notifications: \(requests.count)\n"
                            for request in requests {
                                alertMessage += "\n- ID: \(request.identifier)"
                                if let trigger = request.trigger as? UNCalendarNotificationTrigger {
                                    alertMessage += "\n  Next date: \(trigger.nextTriggerDate()?.description ?? "unknown")"
                                }
                            }
                            showingAlert = true
                        }
                    }
                }
            }
            
            Section(header: Text("Notification Settings")) {
                Button("Check Authorization Status") {
                    checkNotificationStatus()
                }
                
                Button("Open Notification Settings") {
                    if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(settingsUrl)
                    }
                }
            }
        }
        .alert("Notification Test", isPresented: $showingAlert) {
            Button("OK") {}
        } message: {
            Text(alertMessage)
        }
        .onAppear {
            checkNotificationStatus()
        }
    }
    
    func checkNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                notificationStatus = """
                Authorization: \(settings.authorizationStatus.rawValue)
                Alert Setting: \(settings.alertSetting.rawValue)
                Sound Setting: \(settings.soundSetting.rawValue)
                Badge Setting: \(settings.badgeSetting.rawValue)
                Notification Center Setting: \(settings.notificationCenterSetting.rawValue)
                Alert Style: \(settings.alertStyle.rawValue)
                """
            }
        }
    }
}

#Preview {
    NotificationTestView()
}
