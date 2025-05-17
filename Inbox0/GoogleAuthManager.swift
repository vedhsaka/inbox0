import SwiftUI
import GoogleSignIn

class GoogleAuthManager: ObservableObject {
    static let shared = GoogleAuthManager()
    
    @Published var isSignedIn = false
    @Published var userProfile: GIDProfileData?
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    // The iOS client ID
    private let clientID = "66990524870-kdt6libhisnn0cvmfrkl8cnotiqcec5b.apps.googleusercontent.com"
    
    func configure() {
        // Configure Google Sign In with the iOS client ID
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
    
        // Check if user was previously signed in
        GIDSignIn.sharedInstance.restorePreviousSignIn { [weak self] user, error in
            guard let self = self else { return }
            
            if let user = user, error == nil {
                // Instead of directly setting isSignedIn,
                // we'll verify with Supabase first
                Task {
                    if let idToken = user.idToken?.tokenString {
                        // Get access token if available
                        let accessToken = user.accessToken.tokenString
                        
                        let success = await SupabaseAuthManager.shared.signInWithGoogle(
                            idToken: idToken,
                            accessToken: accessToken
                        )
                        
                        DispatchQueue.main.async {
                            self.isSignedIn = success
                            self.userProfile = success ? user.profile : nil
                        }
                    }
                }
            }
        }
    }
    
    func handleSignInURL(_ url: URL) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
    
    func signIn(completion: @escaping (Result<GIDSignInResult, Error>) -> Void) {
        isLoading = true
        errorMessage = nil
        
        // Get the root view controller
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let presentingViewController = windowScene.windows.first?.rootViewController else {
            completion(.failure(NSError(domain: "GoogleSignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "No root view controller found"])))
            return
        }
        
        // Start Google Sign In flow
        GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { [weak self] signInResult, error in
            guard let self = self else { return }
            
            if let error = error {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = "Google sign-in failed: \(error.localizedDescription)"
                }
                completion(.failure(error))
                return
            }
            
            guard let signInResult = signInResult else {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = "Result not found"
                }
                completion(.failure(NSError(domain: "GoogleSignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "Result not found"])))
                return
            }
            
            // Get ID token from Google
            guard let idToken = signInResult.user.idToken?.tokenString else {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = "Failed to get ID token from Google"
                }
                completion(.failure(NSError(domain: "GoogleSignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "ID Token not found"])))
                return
            }
            
            // Get access token if available - properly handle optional
            let accessToken = signInResult.user.accessToken.tokenString
            
            // Sign in to Supabase with Google token
            Task {
                let success = await SupabaseAuthManager.shared.signInWithGoogle(
                    idToken: idToken,
                    accessToken: accessToken
                )
                
                await MainActor.run {
                    self.isLoading = false
                    if !success {
                        self.errorMessage = SupabaseAuthManager.shared.errorMessage ?? "Google sign-in failed"
                        completion(.failure(NSError(domain: "SupabaseAuth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to authenticate with Supabase"])))
                    } else {
                        self.isSignedIn = true
                        self.userProfile = signInResult.user.profile
                        // Check if tools are connected for this user
                        self.checkToolsConnectionState()
                        completion(.success(signInResult))
                    }
                }
            }
        }
    }
    
    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        
        // Also sign out from Supabase
        Task {
            await SupabaseAuthManager.shared.signOut()
            
            DispatchQueue.main.async {
                self.isSignedIn = false
                self.userProfile = nil
            }
        }
    }
    
    // Check if user has connected required tools
    private func checkToolsConnectionState() {
        // Check if user has previously connected tools
        // This would ideally come from a user-specific database entry
        let hasConnected = UserDefaults.standard.bool(forKey: "hasConnectedRequiredTools")
        
        DispatchQueue.main.async {
            // Notify other components about the tools connection state
            NotificationCenter.default.post(
                name: Notification.Name("ToolsConnectionChanged"),
                object: hasConnected
            )
        }
    }
}
