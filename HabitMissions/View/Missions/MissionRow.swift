//
//  MissionRow.swift
//  HabitMissions
//
//  Created by David Springean on 18.05.25.
//


import SwiftUI

struct MissionRow: View {
    let mission: Mission
    
    private var isCompletedToday: Bool {
        guard let lastCompleted = mission.lastCompleted else { return false }
        return Calendar.current.isDateInToday(lastCompleted)
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Category icon
            ZStack {
                Circle()
                    .fill(mission.isActive ? AppColors.cosmicPurple : Color.gray.opacity(0.5))
                    .frame(width: 40, height: 40)
                
                Image(systemName: iconForCategory(mission.category))
                    .font(.system(size: 16))
                    .foregroundColor(.white)
            }
            
            // Mission details
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(mission.name)
                        .font(.headline)
                    
                    if isCompletedToday {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                }
                
                HStack {
                    // Streak
                    if mission.currentStreak > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "flame.fill")
                                .font(.system(size: 10))
                                .foregroundColor(AppColors.sunsetOrange)
                            
                            Text("\(mission.currentStreak)")
                                .font(.caption)
                                .foregroundColor(AppColors.sunsetOrange)
                        }
                    }
                    
                    // Type & frequency
                    Text(missionFrequencyText)
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    if !mission.isActive {
                        Text("PAUSED")
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.orange.opacity(0.2))
                            .foregroundColor(.orange)
                            .cornerRadius(4)
                    }
                }
            }
            
            Spacer()
            
            // Current streak as a metric
            if mission.currentStreak > 0 {
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
        }
    }
    
    // Helper properties and methods
    
    private var missionFrequencyText: String {
        if mission.type == .weekly {
            return "Weekly"
        } else if mission.frequency.count == 7 {
            return "Daily"
        } else if mission.frequency.count == 1 {
            return weekdayName(mission.frequency[0])
        } else {
            return "\(mission.frequency.count)x/week"
        }
    }
    
    private func iconForCategory(_ category: MissionCategory) -> String {
        switch category {
        case .physicalTraining:
            return "figure.walk"
        case .mentalPreparation:
            return "brain.head.profile"
        case .skillDevelopment:
            return "pencil.and.ruler"
        case .equipmentMaintenance:
            return "wrench.and.screwdriver"
        }
    }
    
    private func weekdayName(_ weekday: Weekday) -> String {
        let names = ["", "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        return names[weekday.rawValue]
    }
}