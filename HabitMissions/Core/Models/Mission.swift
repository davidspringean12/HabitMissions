//
//  Mission.swift
//  HabitMissions
//
//  Created by David Springean on 15.05.25.
//


import Foundation

struct Mission: Codable, Identifiable {
    let id: String
    var userId: String
    var name: String
    var category: MissionCategory
    var type: MissionType // daily or weekly
    var startDate: Date
    var frequency: [Weekday]
    var goalPerDay: Int
    var preferredTimeOfDay: Date?
    var isActive: Bool
    var reminders: [MissionReminder]
    
    // Progress Metrics
    var currentStreak: Int
    var bestStreak: Int
    var totalCompletions: Int
    var missedDays: Int
    var lastCompleted: Date?
    
    // Completion History
    var completionLog: [CompletionEntry]
}

// Supporting types
enum MissionCategory: String, Codable {
    case physicalTraining = "Physical Training"
    case mentalPreparation = "Mental Preparation"
    case skillDevelopment = "Skill Development"
    case equipmentMaintenance = "Equipment Maintenance"
    
    var iconName: String {
        switch self {
        case .physicalTraining:
            return "physical-training-icon"
        case .mentalPreparation:
            return "mental-prep-icon"
        case .skillDevelopment:
            return "skill-dev-icon"
        case .equipmentMaintenance:
            return "equipment-icon"
        }
    }
}

enum MissionType: String, Codable {
    case daily
    case weekly
}

enum Weekday: Int, Codable, CaseIterable {
    case sunday = 1
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7
}

struct MissionReminder: Codable, Identifiable {
    let id: String
    var time: Date
    var isEnabled: Bool
}

struct CompletionEntry: Codable, Identifiable {
    let id: String
    let date: Date
    let wasCompleted: Bool
}
