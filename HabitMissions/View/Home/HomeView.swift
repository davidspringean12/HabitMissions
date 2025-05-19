import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var showAstroAI = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [AppColors.spaceBlue, AppColors.spaceDark]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 16) {
                    // Header section
                    HeaderView(
                        streakCount: viewModel.currentStreak,
                        planetsCount: viewModel.planetsDiscovered,
                        fuelPercentage: viewModel.currentFuelPercentage
                    )
                    
                    // Journey progress
                    JourneyProgressView(currentFuel: viewModel.currentFuelPercentage)
                        .padding(.horizontal)
                    
                    // Today's missions
                    ScrollView {
                        VStack(spacing: 12) {
                            HStack {
                                Text("Today's Missions")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Spacer()
                                Text("\(viewModel.completedTodayCount)/\(viewModel.todaysMissions.count)")
                                    .font(.subheadline)
                                    .foregroundColor(AppColors.starYellow)
                            }
                            .padding(.horizontal, 20)
                            
                            if viewModel.todaysMissions.isEmpty {
                                emptyMissionsView
                            } else {
                                ForEach(viewModel.todaysMissions) { mission in
                                    MissionCardView(mission: mission) { mission in
                                        viewModel.toggleMissionCompletion(mission)
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }
                
                // AstroAI quick access button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            showAstroAI = true
                        }) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(AppColors.spaceBlue)
                                .padding(12)
                                .background(AppColors.starYellow)
                                .clipShape(Circle())
                                .shadow(color: AppColors.starYellow.opacity(0.4), radius: 8, x: 0, y: 4)
                        }
                        .padding(.trailing, 16)
                        .padding(.bottom, 70) // Keep this spacing for the tab bar
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showAstroAI) {
            AstroAIView()
        }
        // REMOVED THIS LINE: .overlay(TabBarView(selectedTab: $viewModel.selectedTab), alignment: .bottom)
        .onAppear {
            viewModel.loadTodaysMissions()
        }
    }
    
    private var emptyMissionsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "flag.checkered")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            
            Text("No missions scheduled for today")
                .font(.headline)
                .foregroundColor(.gray)
            
            Button(action: {
                // Navigate to mission creation
                viewModel.selectedTab = Tab.missions.rawValue
            }) {
                Text("Create New Mission")
                    .font(.headline)
                    .foregroundColor(AppColors.spaceBlue)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(AppColors.starYellow)
                    .cornerRadius(8)
            }
        }
        .padding(40)
    }
}
