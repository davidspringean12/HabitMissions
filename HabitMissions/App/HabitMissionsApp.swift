import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore

@main
struct HabitMissionsApp: App {
    @StateObject private var appViewModel = AppViewModel()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            if appViewModel.isUserLoggedIn {
                MainTabView()
                    .environmentObject(appViewModel)
            } else {
                LoginView()
                    .environmentObject(appViewModel)
            }
        }
    }
}

class AppViewModel: ObservableObject {
    @Published var isUserLoggedIn: Bool = false
    private var authStateHandle: AuthStateDidChangeListenerHandle?
    
    init() {
        // Store the listener handle
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            withAnimation {
                self?.isUserLoggedIn = user != nil
            }
        }
    }
    
    // When the view model is deinitialized, remove the listener
    deinit {
        if let handle = authStateHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
}

struct MainTabView: View {
    @StateObject private var homeViewModel = HomeViewModel()
    @State private var selectedTab: Int = 0
    @State private var showCreateMission = false
    @State private var showAstroAI = false
    
    var body: some View {
        // ONLY use ONE tab view system - the built-in SwiftUI one
        TabView(selection: $selectedTab) {
            HomeView()
                .environmentObject(homeViewModel)
                .tag(0)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Today")
                }
            
            Text("AstroAI Assistant")
                .tag(1)
                .tabItem {
                    Image(systemName: "sparkles")
                    Text("AstroAI")
                }
            
            Text("Journey Coming Soon")
                .tag(2)
                .tabItem {
                    Image(systemName: "globe")
                    Text("Journey")
                }
            
            MissionListView()
                .tag(3)
                .tabItem {
                    Image(systemName: "checklist")
                    Text("Missions")
                }
            
            ProfileView()
                .tag(4)
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
        }
        .overlay(
            // Position buttons on the left and right
            VStack {
                Spacer()
                HStack {
                    // AI button on the LEFT
                    Button(action: {
                        showAstroAI = true
                    }) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color.black)
                            .padding(16)
                            .background(Color(UIColor.systemYellow))
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 3)
                    }
                    .padding(.leading, 16)
                    .padding(.bottom, 70) // Space for tab bar
                    
                    Spacer()
                    
                    // ONLY show Create Mission button on relevant tabs
                    if selectedTab == 0 || selectedTab == 3 {
                        Button(action: {
                            showCreateMission = true
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(Color.white)
                                .padding(16)
                                .background(AppColors.cosmicPurple)
                                .clipShape(Circle())
                                .shadow(color: AppColors.cosmicPurple.opacity(0.4), radius: 8, x: 0, y: 4)
                        }
                        .padding(.trailing, 16)
                        .padding(.bottom, 70) // Space for tab bar
                    }
                }
            }
        )
        .sheet(isPresented: $showCreateMission) {
            CreateMissionView()
                .onDisappear {
                    homeViewModel.loadTodaysMissions()
                }
        }
        .sheet(isPresented: $showAstroAI) {
            // Your AstroAI view here
            Text("AstroAI Assistant")
                .presentationDetents([.medium, .large])
        }
        .onAppear {
            homeViewModel.loadTodaysMissions()
        }
    }
}

struct ProfileView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Account")) {
                    // Account info here
                    Text("User: \(Auth.auth().currentUser?.email ?? "Unknown")")
                }
                
                Section {
                    Button("Sign Out") {
                        do {
                            try Auth.auth().signOut()
                        } catch {
                            print("Error signing out: \(error)")
                        }
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Profile")
        }
    }
}
