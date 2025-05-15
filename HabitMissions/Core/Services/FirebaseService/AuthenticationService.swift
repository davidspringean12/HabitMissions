import Firebase
import FirebaseAuth
import AuthenticationServices

class AuthenticationService: ObservableObject {
    @Published var user: User?
    private var handle: AuthStateDidChangeListenerHandle?
    
    init() {
        registerAuthStateHandler()
    }
    
    private func registerAuthStateHandler() {
        if handle == nil {
            handle = Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
                guard let self = self else { return }
                
                if let user = user {
                    // User is signed in
                    self.user = user
                } else {
                    // User is signed out
                    self.user = nil
                }
            }
        }
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
}
