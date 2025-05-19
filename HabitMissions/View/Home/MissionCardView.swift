import SwiftUI

struct MissionCardView: View {
    let mission: Mission
    let onToggleCompletion: (Mission) -> Void
    
    // Computed properties to work with your Mission model
    private var isTodayCompleted: Bool {
        guard let lastCompleted = mission.lastCompleted else { return false }
        return Calendar.current.isDateInToday(lastCompleted)
    }
    
    private var iconName: String {
        // Map your category to a system icon
        switch mission.category {
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
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(LinearGradient(
                    gradient: Gradient(colors: [
                        isTodayCompleted ? AppColors.spaceGray.opacity(0.7) : AppColors.spaceGray,
                        isTodayCompleted ? AppColors.spaceDark.opacity(0.7) : AppColors.spaceDark
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(
                            LinearGradient(
                                gradient: Gradient(colors: [AppColors.cosmicPurple.opacity(0.6), AppColors.cosmicPurple.opacity(0.2)]),
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 1
                        )
                )
            
            HStack(spacing: 16) {
                // Mission icon
                ZStack {
                    Circle()
                        .fill(isTodayCompleted ? AppColors.cosmicPurple.opacity(0.3) : AppColors.cosmicPurple)
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: iconName)
                        .font(.system(size: 22))
                        .foregroundColor(isTodayCompleted ? .white.opacity(0.7) : .white)
                }
                
                // Mission details
                VStack(alignment: .leading, spacing: 4) {
                    Text(mission.name)
                        .font(.headline)
                        .foregroundColor(isTodayCompleted ? .white.opacity(0.7) : .white)
                        .strikethrough(isTodayCompleted)
                    
                    HStack {
                        // Streak
                        HStack(spacing: 4) {
                            Image(systemName: "flame.fill")
                                .font(.system(size: 12))
                                .foregroundColor(AppColors.sunsetOrange)
                            
                            Text("×\(mission.currentStreak)")
                                .font(.subheadline)
                                .foregroundColor(AppColors.sunsetOrange)
                        }
                        
                        Spacer()
                        
                        // Display mission frequency/type
                        HStack(spacing: 4) {
                            if mission.type == .daily {
                                Text(frequencyText)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            } else {
                                Text("Weekly")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                
                Spacer()
                
                // Completion button
                Button(action: {
                    withAnimation(.spring()) {
                        onToggleCompletion(mission)
                    }
                }) {
                    ZStack {
                        Circle()
                            .strokeBorder(
                                isTodayCompleted ? AppColors.starYellow : Color.white.opacity(0.3),
                                lineWidth: 2
                            )
                            .frame(width: 30, height: 30)
                        
                        if isTodayCompleted {
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(AppColors.starYellow)
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(16)
        }
        .frame(height: 90)
        .padding(.horizontal, 16)
        .opacity(isTodayCompleted ? 0.8 : 1.0)
    }
    
    // Helper to show frequency in human-readable format
    private var frequencyText: String {
        if mission.frequency.count == 7 {
            return "Daily"
        } else if mission.frequency.count == 1 {
            return "\(weekdayName(mission.frequency[0]))"
        } else {
            // Simplified - in a real app you might want a more elegant solution
            return "\(mission.frequency.count)x Week"
        }
    }
    
    private func weekdayName(_ weekday: Weekday) -> String {
        let days = ["", "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        return days[weekday.rawValue]
    }
    
    // Helper to format reminder time if present
    private func formattedTime(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}
