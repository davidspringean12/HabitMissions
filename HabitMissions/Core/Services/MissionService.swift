    //
//  MissionService.swift
//  HabitMissions
//
//  Created by David Springean on 18.05.25.
//


import Foundation
import Firebase
import FirebaseFirestore
import FirebaseAuth

class MissionService {
    private let db = Firestore.firestore()
    
    // Get all missions for the current user
    func getMissions(completion: @escaping (Result<[Mission], Error>) -> Void) {
            guard let userId = Auth.auth().currentUser?.uid else {
                completion(.failure(NSError(domain: "MissionService", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
                return
            }
            
            db.collection("missions")
                .whereField("userId", isEqualTo: userId)
                .getDocuments { snapshot, error in
                    if let error = error {
                        print("Error fetching missions: \(error.localizedDescription)")
                        completion(.failure(error))
                        return
                    }
                    
                    guard let documents = snapshot?.documents else {
                        completion(.success([]))
                        return
                    }
                    
                    // Parse documents into Mission objects
                    let missions = documents.compactMap { document -> Mission? in
                        do {
                            // Decode Firestore document to Mission
                            var mission = try document.data(as: Mission.self)
                            return mission
                        } catch {
                            print("Error decoding mission document: \(error.localizedDescription)")
                            return nil
                        }
                    }
                    
                    completion(.success(missions))
                }
        }
        
        // For backward compatibility, if getUserMissions is used elsewhere
        func getUserMissions(completion: @escaping (Result<[Mission], Error>) -> Void) {
            getMissions(completion: completion)
        }
        
        // Your existing getTodaysMissions function remains the same
        func getTodaysMissions(completion: @escaping (Result<[Mission], Error>) -> Void) {
            self.getMissions { result in
                switch result {
                case .success(let allMissions):
                    // Filter missions that should be active today
                    let calendar = Calendar.current
                    let weekday = calendar.component(.weekday, from: Date())
                    
                    let todaysMissions = allMissions.filter { mission in
                        guard mission.isActive else { return false }
                        
                        if mission.type == .weekly {
                            return true // Weekly missions are always shown
                        } else {
                            // For daily missions, check if today is in the frequency
                            return mission.frequency.contains(Weekday(rawValue: weekday) ?? .sunday)
                        }
                    }
                    
                    completion(.success(todaysMissions))
                    
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }

    
    // Create a new mission
    func createMission(_ mission: Mission, completion: @escaping (Result<String, Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "MissionService", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
            return
        }
        
        // Create a document reference with a new ID
        let docRef = db.collection("missions").document()
        
        // Create a copy of the mission with the document ID and current user ID
        var missionToSave = mission
        // No need to set mission.id as it's already in the model
        
        // Make sure userId is set
        if missionToSave.userId.isEmpty {
            missionToSave.userId = userId
        }
        
        do {
            try docRef.setData(from: missionToSave)
            completion(.success(docRef.documentID))
        } catch {
            completion(.failure(error))
        }
    }
    
    // Update an existing mission
    func updateMission(_ mission: Mission, completion: @escaping (Result<Void, Error>) -> Void) {
        let missionId = mission.id
        
        do {
            try db.collection("missions").document(missionId).setData(from: mission)
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
    
    // Delete a mission
    // Delete a mission with improved error handling and permission check
    func deleteMission(missionId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        // Verify authentication
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "MissionService", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
            return
        }
        
        // First, get the mission to verify ownership
        db.collection("missions").document(missionId).getDocument { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = snapshot?.data(),
                  let missionUserId = data["userId"] as? String else {
                completion(.failure(NSError(domain: "MissionService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Mission not found"])))
                return
            }
            
            // Verify ownership
            guard missionUserId == userId else {
                completion(.failure(NSError(domain: "MissionService", code: 403, userInfo: [NSLocalizedDescriptionKey: "You don't have permission to delete this mission"])))
                return
            }
            
            // Proceed with deletion
            self.db.collection("missions").document(missionId).delete { error in
                if let error = error {
                    print("Error deleting mission: \(error.localizedDescription)")
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }
    }
}
