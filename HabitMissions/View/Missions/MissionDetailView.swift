//
//  MissionDetailView.swift
//  HabitMissions
//
//  Created by David Springean on 18.05.25.
//


import SwiftUI
import Firebase
import FirebaseFirestore

struct MissionDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @State var mission: Mission
    @State private var isEditing = false
    @State private var showingConfirmation = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    private let missionService = MissionService()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Mission header
                HStack {
                    categoryIcon
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(mission.name)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text(mission.category.rawValue)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    // Status indicator
                    Text(mission.isActive ? "Active" : "Paused")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(mission.isActive ? Color.green.opacity(0.2) : Color.orange.opacity(0.2))
                        .foregroundColor(mission.isActive ? .green : .orange)
                        .cornerRadius(4)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                
                // Mission stats
                HStack {
                    statBox(value: "\(mission.currentStreak)", title: "Current Streak", icon: "flame.fill", color: AppColors.sunsetOrange)
                    statBox(value: "\(mission.bestStreak)", title: "Best Streak", icon: "star.fill", color: AppColors.starYellow)
                    statBox(value: "\(mission.totalCompletions)", title: "Completed", icon: "checkmark.circle.fill", color: AppColors.cosmicPurple)
                }
                
                // Mission details
                VStack(alignment: .leading, spacing: 15) {
                    detailRow(title: "Type", value: mission.type.rawValue.capitalized)
                    detailRow(title: "Start Date", value: formatDate(mission.startDate))
                    
                    if mission.type == .daily {
                        detailRow(title: "Frequency", value: formatFrequency(mission.frequency))
                    }
                    
                    detailRow(title: "Goal per Day", value: "\(mission.goalPerDay)")
                    
                    if let preferredTime = mission.preferredTimeOfDay {
                        detailRow(title: "Preferred Time", value: formatTime(preferredTime))
                    }
                    
                    if !mission.reminders.isEmpty {
                        detailRow(title: "Reminders", value: "\(mission.reminders.count) reminder(s)")
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                
                // Action buttons
                HStack {
                    Button(action: {
                        toggleActivation()
                    }) {
                        Text(mission.isActive ? "Pause Mission" : "Activate Mission")
                            .fontWeight(.medium)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(mission.isActive ? Color.orange.opacity(0.2) : Color.green.opacity(0.2))
                            .foregroundColor(mission.isActive ? .orange : .green)
                            .cornerRadius(8)
                    }
                    
                    Button(action: {
                        showingConfirmation = true
                    }) {
                        Text("Delete")
                            .fontWeight(.medium)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red.opacity(0.2))
                            .foregroundColor(.red)
                            .cornerRadius(8)
                    }
                }
            }
            .padding()
        }
        .navigationBarTitle("Mission Details", displayMode: .inline)
        .navigationBarItems(trailing: Button("Edit") {
            isEditing = true
        })
        .confirmationDialog("Are you sure?", isPresented: $showingConfirmation) {
            Button("Delete Mission", role: .destructive) {
                deleteMission()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently delete this mission and all its data.")
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Mission Update"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .sheet(isPresented: $isEditing) {
            // In a real app, you'd have an EditMissionView here
            Text("Edit Mission View would go here")
                .presentationDetents([.medium, .large])
        }
    }
    
    private var categoryIcon: some View {
        ZStack {
            Circle()
                .fill(AppColors.cosmicPurple)
                .frame(width: 50, height: 50)
            
            Image(systemName: iconForCategory(mission.category))
                .font(.system(size: 22))
                .foregroundColor(.white)
        }
    }
    
    private func statBox(value: String, title: String, icon: String, color: Color) -> some View {
        VStack {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(value)
                    .font(.system(size: 18, weight: .bold))
            }
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
    }
    
    private func detailRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
        }
    }
    
    // Helper functions
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
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func formatFrequency(_ days: [Weekday]) -> String {
        if days.count == 7 {
            return "Every day"
        } else if days.count == 0 {
            return "None"
        } else {
            let dayNames = days.map { weekdayName($0) }
            return dayNames.joined(separator: ", ")
        }
    }
    
    private func weekdayName(_ weekday: Weekday) -> String {
        let names = ["", "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        return names[weekday.rawValue]
    }
    
    // Action functions
    private func toggleActivation() {
        var updatedMission = mission
        updatedMission.isActive.toggle()
        
        missionService.updateMission(updatedMission) { result in
            switch result {
            case .success:
                mission = updatedMission
                alertMessage = mission.isActive ? "Mission activated successfully." : "Mission paused successfully."
                showingAlert = true
            case .failure(let error):
                alertMessage = "Error updating mission: \(error.localizedDescription)"
                showingAlert = true
            }
        }
    }
    
    private func deleteMission() {
        missionService.deleteMission(missionId: mission.id) { result in
            switch result {
            case .success:
                presentationMode.wrappedValue.dismiss()
            case .failure(let error):
                alertMessage = "Error deleting mission: \(error.localizedDescription)"
                showingAlert = true
            }
        }
    }
}