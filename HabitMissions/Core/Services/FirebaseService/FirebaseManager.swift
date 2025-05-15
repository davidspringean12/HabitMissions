import Firebase
import FirebaseAuth
import FirebaseFirestore

class FirebaseManager: ObservableObject {
    static let shared = FirebaseManager()
    
    let auth: Auth
    let firestore: Firestore
    
    @Published var currentUser: User?
    
    private init() {
        FirebaseApp.configure()
        
        auth = Auth.auth()
        firestore = Firestore.firestore()
        
        // Enable offline persistence
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        settings.cacheSizeBytes = FirestoreCacheSizeUnlimited
        firestore.settings = settings
    }
}
