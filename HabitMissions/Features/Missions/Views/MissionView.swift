import SwiftUI
import FirebasePerformance

struct MissionView: View {
    @StateObject private var viewModel = MissionViewModel()
    private let performanceTrace: Trace?
    
    init() {
        performanceTrace = Performance.startTrace(name: "screen_load_mission_view")
    }
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Loading missions...")
            } else if let error = viewModel.error {
                ErrorView(message: error, retryAction: viewModel.fetchMissions)
            } else if viewModel.missions.isEmpty {
                EmptyStateView()
            } else {
                MissionList(missions: viewModel.missions)
            }
        }
        .onAppear {
            performanceTrace?.stop()
            AnalyticsService.shared.logScreenView(
                screenName: "Mission List",
                screenClass: "MissionView"
            )
        }
        .onDisappear {
            AnalyticsService.shared.endSession()
        }
    }
}

// MARK: - Supporting Views
private struct ErrorView: View {
    let message: String
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Oops!")
                .font(.title)
            Text(message)
                .multilineTextAlignment(.center)
            Button("Try Again") {
                retryAction()
            }
        }
        .padding()
    }
}

private struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "star.circle")
                .font(.system(size: 64))
            Text("No Missions Yet")
                .font(.title2)
            Text("Start your space journey by creating your first mission!")
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

private struct MissionList: View {
    let missions: [Mission]
    
    var body: some View {
        List(missions) { mission in
            MissionRow(mission: mission)
        }
    }
}

private struct MissionRow: View {
    let mission: Mission
    
    var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Text(mission.name)
                    .font(.headline)
                Text(mission.category.rawValue)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                if mission.currentStreak > 0 {  // Changed from if let to simple if
                    Text("🔥 \(mission.currentStreak) day streak")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
            .padding(.vertical, 8)
        }
    }

#Preview {
    MissionView()
}
