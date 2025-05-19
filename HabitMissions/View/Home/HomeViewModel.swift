import SwiftUI
import Combine
import Firebase
import FirebaseFirestore
import FirebaseAuth

class HomeViewModel: ObservableObject {
    @Published var todaysMissions: [Mission] = []
    @Published var selectedTab: Int = 0
    @Published var currentStreak: Int = 0
    @Published var planetsDiscovered: Int = 0
    @Published var currentFuelPercentage: Double = 0
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""
    
    private let missionService = MissionService()
    
    var completedTodayCount: Int {
        todaysMissions.filter { isMissionCompletedToday($0) }.count
    }
    
    func loadTodaysMissions() {
        isLoading = true
        
        // Fix: Changed getUserMissions to getMissions with proper type annotation
        missionService.getMissions { [weak self] (result: Result<[Mission], Error>) in
            guard let self = self else { return }
            
            self.isLoading = false
            
            switch result {
            case .success(let missions):
                // Filter for today's missions based on frequency
                let today = Calendar.current.component(.weekday, from: Date())
                let weekday = Weekday(rawValue: today) ?? .monday
                
                self.todaysMissions = missions.filter { mission in
                    guard mission.isActive else { return false }
                    
                    if mission.type == .daily {
                        return mission.frequency.contains(weekday)
                    } else {
                        // For weekly missions, check if it's been completed this week
                        let startOfWeek = Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
                        let endOfWeek = Calendar.current.date(byAdding: .day, value: 7, to: startOfWeek)!
                        
                        let hasCompletionThisWeek = mission.completionLog.contains { entry in
                            entry.wasCompleted &&
                            entry.date >= startOfWeek &&
                            entry.date < endOfWeek
                        }
                        
                        return !hasCompletionThisWeek
                    }
                }
                
                // Calculate stats
                self.calculateUserStats(allMissions: missions)
                
            case .failure(let error):
                self.errorMessage = "Failed to load missions: \(error.localizedDescription)"
                print("Error loading missions: \(error)")
                // Show error or retry logic could be added here
            }
        }
    }
    
    // Fixed implementation for toggleMissionCompletion
    func toggleMissionCompletion(_ mission: Mission) {
        // First, get the current version of the mission
        missionService.getMissions { [weak self] (result: Result<[Mission], Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let missions):
                // Find the mission to update
                if let currentMission = missions.first(where: { $0.id == mission.id }) {
                    // Create an updated version of the mission
                    var updatedMission = currentMission
                    
                    // Create today's completion entry
                    let today = Date()
                    let todayString = self.formatDateForComparison(today)
                    
                    // Check if there's already an entry for today
                    if let existingEntryIndex = updatedMission.completionLog.firstIndex(where: {
                        self.formatDateForComparison($0.date) == todayString
                    }) {
                        // FIX: Create a new CompletionEntry instead of modifying the existing one
                        let existingEntry = updatedMission.completionLog[existingEntryIndex]
                        let newEntry = CompletionEntry(
                            id: existingEntry.id,
                            date: existingEntry.date,
                            wasCompleted: !existingEntry.wasCompleted  // Toggle the value
                        )
                        
                        // Replace the old entry with the new one
                        updatedMission.completionLog[existingEntryIndex] = newEntry
                    } else {
                        // Create new entry for today
                        let newEntry = CompletionEntry(
                            id: UUID().uuidString,
                            date: today,
                            wasCompleted: true
                        )
                        updatedMission.completionLog.append(newEntry)
                    }
                    
                    // Update lastCompleted if marking as completed
                    let isCompletedToday = updatedMission.completionLog.contains {
                        Calendar.current.isDateInToday($0.date) && $0.wasCompleted
                    }
                    
                    if isCompletedToday {
                        updatedMission.lastCompleted = today
                    }
                    
                    // Update streak information
                    self.updateStreakInformation(for: &updatedMission)
                    
                    // Save the updated mission
                    self.missionService.updateMission(updatedMission) { updateResult in
                        DispatchQueue.main.async {
                            switch updateResult {
                            case .success:
                                // Reload missions to reflect the changes
                                self.loadTodaysMissions()
                            case .failure(let error):
                                self.errorMessage = "Failed to update mission: \(error.localizedDescription)"
                                print("Error updating mission: \(error)")
                            }
                        }
                    }
                } else {
                    self.errorMessage = "Could not find mission to update"
                }
                
            case .failure(let error):
                self.errorMessage = "Failed to get mission: \(error.localizedDescription)"
                print("Error getting mission to toggle: \(error)")
            }
        }
    }
    
    // Helper function to format dates for comparison
    private func formatDateForComparison(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    // Helper function to update streak information
    private func updateStreakInformation(for mission: inout Mission) {
        // Calculate current streak
        var currentStreak = 0
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Sort completion log by date (newest first)
        let sortedLog = mission.completionLog
            .sorted { $0.date > $1.date }
            .filter { $0.wasCompleted }
        
        if let latest = sortedLog.first, calendar.isDateInToday(latest.date) {
            currentStreak = 1
            
            // Check consecutive days before today
            var checkDate = calendar.date(byAdding: .day, value: -1, to: today)!
            var dayIndex = 1
            
            while dayIndex < sortedLog.count {
                // See if we have a completion on this date
                let hasCompletion = sortedLog[dayIndex...].contains {
                    calendar.isDate($0.date, inSameDayAs: checkDate)
                }
                
                if hasCompletion {
                    currentStreak += 1
                    checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
                    dayIndex += 1
                } else {
                    // Break streak when we find a gap
                    break
                }
            }
        }
        
        mission.currentStreak = currentStreak
        
        // Update best streak if current streak is better
        if currentStreak > mission.bestStreak {
            mission.bestStreak = currentStreak
        }
        
        // Update total completions
        mission.totalCompletions = sortedLog.count
    }
    
    private func isMissionCompletedToday(_ mission: Mission) -> Bool {
        guard let lastCompleted = mission.lastCompleted else { return false }
        return Calendar.current.isDateInToday(lastCompleted)
    }
    
    private func calculateUserStats(allMissions: [Mission]) {
        // Calculate overall streak
        let streaks = allMissions.map { $0.currentStreak }
        currentStreak = streaks.max() ?? 0
        
        // Simple calculation for planets - 1 planet per 5 total completions
        let totalCompletions = allMissions.reduce(0) { $0 + $1.totalCompletions }
        planetsDiscovered = max(1, totalCompletions / 5) // At least 1 planet
        
        // Calculate fuel percentage - simplified version
        // Assume fuel is based on completion rate for today's missions
        if todaysMissions.isEmpty {
            currentFuelPercentage = 0
        } else {
            currentFuelPercentage = Double(completedTodayCount) / Double(todaysMissions.count) * 100
        }
    }
}
