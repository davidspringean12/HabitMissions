//
//  CreateMissionViewModel.swift
//  HabitMissions
//
//  Created by David Springean on 18.05.25.
//


import Foundation
import Firebase
import FirebaseFirestore
import FirebaseAuth

class CreateMissionViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var category: MissionCategory = .physicalTraining
    @Published var missionType: MissionType = .daily
    @Published var frequency: [Weekday] = [.monday, .wednesday, .friday] // Default selection
    @Published var goalPerDay: Int = 1
    @Published var startDate: Date = Date()
    @Published var hasReminder: Bool = false
    @Published var reminderTime: Date = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()
    
    @Published var errorMessage: String = ""
    @Published var showError: Bool = false
    
    private let missionService = MissionService()
    
    var isFormValid: Bool {
        !name.isEmpty && 
        (missionType != .daily || !frequency.isEmpty)
    }
    
    var frequencyText: String {
        if frequency.isEmpty {
            return "None"
        } else if frequency.count == 7 {
            return "Every day"
        } else if frequency.count == 1 {
            return weekdayName(frequency[0])
        } else {
            return "\(frequency.count) days / week"
        }
    }
    
    func createMission(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "CreateMissionViewModel", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
            return
        }
        
        // Create reminders if needed
        var reminders: [MissionReminder] = []
        if hasReminder {
            let reminder = MissionReminder(
                id: UUID().uuidString,
                time: reminderTime,
                isEnabled: true
            )
            reminders.append(reminder)
        }
        
        // Create a new mission
        let newMission = Mission(
            id: UUID().uuidString,
            userId: userId,
            name: name,
            category: category,
            type: missionType,
            startDate: startDate,
            frequency: missionType == .daily ? frequency : [.sunday], // For weekly, the day doesn't matter as much
            goalPerDay: goalPerDay,
            preferredTimeOfDay: hasReminder ? reminderTime : nil,
            isActive: true,
            reminders: reminders,
            currentStreak: 0,
            bestStreak: 0,
            totalCompletions: 0,
            missedDays: 0,
            lastCompleted: nil,
            completionLog: []
        )
        
        missionService.createMission(newMission) { result in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func weekdayName(_ weekday: Weekday) -> String {
        let names = ["", "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        return names[weekday.rawValue]
    }
}