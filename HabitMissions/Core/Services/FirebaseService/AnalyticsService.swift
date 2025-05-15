//
//  AnalyticsService.swift
//  HabitMissions
//
//  Created by David Springean on 15.05.25.
//

import FirebaseAnalytics

class AnalyticsService {
    static let shared = AnalyticsService()
    
    // Habit Completion Analytics
    func logHabitCompletion(habitId: String, habitName: String, category: String) {
        Analytics.logEvent("habit_completed", parameters: [
            AnalyticsParameterItemID: habitId,
            "habit_name": habitName,
            "category": category,
            "completion_time": Int(Date().timeIntervalSince1970)  // Convert to Int timestamp
        ])
    }
    
    // Session Tracking
    private var sessionStartTime: Date?
    
    func startSession() {
        sessionStartTime = Date()
        Analytics.logEvent("session_started", parameters: nil)
    }
    
    func endSession() {
        guard let startTime = sessionStartTime else { return }
        let timeSpent = Int(Date().timeIntervalSince(startTime))  // Convert to Int seconds
        
        Analytics.logEvent("session_ended", parameters: [
            "duration_seconds": timeSpent
        ])
    }
    
    // Custom Events
    func logStreak(habitId: String, streakCount: Int) {
        Analytics.logEvent("streak_achieved", parameters: [
            AnalyticsParameterItemID: habitId,
            "streak_count": streakCount
        ])
    }
    
    // Screen View Tracking
    func logScreenView(screenName: String, screenClass: String) {
        Analytics.logEvent(AnalyticsEventScreenView,
                         parameters: [
                            AnalyticsParameterScreenName: screenName,
                            AnalyticsParameterScreenClass: screenClass
                         ])
    }
}
