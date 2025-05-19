//
//  MissionListView.swift
//  HabitMissions
//
//  Created by David Springean on 18.05.25.
//


import SwiftUI
import Firebase
import FirebaseFirestore

struct MissionListView: View {
    @State private var missions: [Mission] = []
    @State private var isLoading = true
    @State private var errorMessage: String? = nil
    @State private var showCreateMission = false
    
    private let missionService = MissionService()
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    // Mission filters (can be expanded later)
                    HStack {
                        Spacer()
                        
                        Menu {
                            Button("All Missions", action: { loadAllMissions() })
                            Button("Active Missions", action: { loadActiveMissions() })
                            Button("Paused Missions", action: { loadPausedMissions() })
                        } label: {
                            HStack {
                                Text("Filter")
                                Image(systemName: "slider.horizontal.3")
                            }
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal)
                    
                    if isLoading {
                        Spacer()
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                        Spacer()
                    } else if let error = errorMessage {
                        Spacer()
                        VStack(spacing: 16) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 50))
                                .foregroundColor(.orange)
                            
                            Text(error)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.secondary)
                            
                            Button("Try Again") {
                                loadAllMissions()
                            }
                            .padding()
                            .background(AppColors.cosmicPurple)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .padding()
                        Spacer()
                    } else if missions.isEmpty {
                        Spacer()
                        VStack(spacing: 20) {
                            Image(systemName: "flag")
                                .font(.system(size: 70))
                                .foregroundColor(.gray)
                                .opacity(0.6)
                            
                            Text("No Missions Found")
                                .font(.headline)
                            
                            Text("Create your first mission to begin your journey")
                                .multilineTextAlignment(.center)
                                .foregroundColor(.secondary)
                            
                            Button(action: {
                                showCreateMission = true
                            }) {
                                Text("Create Your First Mission")
                                    .padding()
                                    .frame(maxWidth: 280)
                                    .background(AppColors.cosmicPurple)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        }
                        .padding()
                        Spacer()
                    } else {
                        List {
                            ForEach(missions) { mission in
                                NavigationLink(
                                    destination: MissionDetailView(mission: mission)
                                ) {
                                    MissionRow(mission: mission)
                                }
                            }
                        }
                        .listStyle(InsetGroupedListStyle())
                        .refreshable {
                            loadAllMissions()
                        }
                    }
                }
            }
            .navigationTitle("Missions")
            .sheet(isPresented: $showCreateMission) {
                CreateMissionView()
                    .onDisappear {
                        loadAllMissions()
                    }
            }
            .onAppear {
                loadAllMissions()
            }
        }
    }
    
    // MARK: - Data Loading Methods
    
    private func loadAllMissions() {
        isLoading = true
        errorMessage = nil
        
        missionService.getMissions { result in
            isLoading = false
            switch result {
            case .success(let loadedMissions):
                missions = loadedMissions.sorted(by: { $0.name < $1.name })
            case .failure(let error):
                errorMessage = "Could not load missions: \(error.localizedDescription)"
            }
        }
    }
    
    private func loadActiveMissions() {
        isLoading = true
        errorMessage = nil
        
        missionService.getMissions { result in
            isLoading = false
            switch result {
            case .success(let loadedMissions):
                missions = loadedMissions
                    .filter { $0.isActive }
                    .sorted(by: { $0.name < $1.name })
            case .failure(let error):
                errorMessage = "Could not load missions: \(error.localizedDescription)"
            }
        }
    }
    
    private func loadPausedMissions() {
        isLoading = true
        errorMessage = nil
        
        missionService.getMissions { result in
            isLoading = false
            switch result {
            case .success(let loadedMissions):
                missions = loadedMissions
                    .filter { !$0.isActive }
                    .sorted(by: { $0.name < $1.name })
            case .failure(let error):
                errorMessage = "Could not load missions: \(error.localizedDescription)"
            }
        }
    }
}
