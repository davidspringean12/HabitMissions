//
//  MissionViewModel.swift
//  HabitMissions
//
//  Created by David Springean on 15.05.25.
//


import Foundation
import FirebaseFirestore

class MissionViewModel: ObservableObject {
    @Published var missions: [Mission] = []
    @Published var isLoading = false
    @Published var error: String?
    
    private let db = Firestore.firestore()
    private let userId: String
    
    init(userId: String = "davidspringean12") {
        self.userId = userId
        fetchMissions()
    }
    
    func fetchMissions() {
        isLoading = true
        
        db.collection("missions")
            .whereField("userId", isEqualTo: userId)
            .addSnapshotListener { [weak self] querySnapshot, error in
                guard let self = self else { return }
                self.isLoading = false
                
                if let error = error {
                    self.error = error.localizedDescription
                    return
                }
                
                self.missions = querySnapshot?.documents.compactMap { document in
                    try? document.data(as: Mission.self)
                } ?? []
            }
    }
}