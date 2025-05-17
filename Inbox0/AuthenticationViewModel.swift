import SwiftUI
import Combine
import GoogleSignIn

class AuthenticationViewModel: ObservableObject {
    @Published var isLoggedIn = false
    @Published var errorMessage: String?
    @Published var isLoading = false
    @Published var userName: String?
    @Published var userEmail: String?
    @Published var hasConnectedTools: Bool = false
    
    // Add a new property to track email verification status
    @Published var needsEmailVerification = false
    @Published var verificationEmail: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Listen for auth state changes from Supabase Auth Manager
        SupabaseAuthManager.shared.$isSignedIn
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isSignedIn in
                self?.isLoggedIn = isSignedIn
            }
            .store(in: &cancellables)
        
        SupabaseAuthManager.shared.$user
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                if let user = user {
                    // Try to get name from metadata if available
                    if let metadata = user.userMetadata as? [String: Any] {
                        if let fullName = metadata["full_name"] as? String {
                            self?.userName = fullName
                        } else if let name = metadata["name"] as? String {
                            self?.userName = name
                        } else if let displayName = metadata["display_name"] as? String {
                            self?.userName = displayName
                        } else if let givenName = metadata["given_name"] as? String {
                            self?.userName = givenName
                        }
                    }
                    
                    // Get email
                    self?.userEmail = user.email
                } else {
                    self?.userName = nil
                    self?.userEmail = nil
                }
            }
            .store(in: &cancellables)
        
        SupabaseAuthManager.shared.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                if let message = message {
                    self?.errorMessage = message
                }
            }
            .store(in: &cancellables)
            
        // Add a listener for connected tools state
        NotificationCenter.default.publisher(for: Notification.Name("ToolsConnectionChanged"))
            .receive(on: DispatchQueue.main)
            .sink { [weak self] notification in
                if let hasConnected = notification.object as? Bool {
                    self?.hasConnectedTools = hasConnected
                }
            }
            .store(in: &cancellables)
        
        // Listen for email verification status changes
        SupabaseAuthManager.shared.$needsEmailVerification
            .receive(on: DispatchQueue.main)
            .sink { [weak self] needsVerification in
                self?.needsEmailVerification = needsVerification
            }
            .store(in: &cancellables)
            
        SupabaseAuthManager.shared.$verificationEmail
            .receive(on: DispatchQueue.main)
            .sink { [weak self] email in
                self?.verificationEmail = email
            }
            .store(in: &cancellables)
        
        Task {
            let isSignedIn = await SupabaseAuthManager.shared.checkSession()
            await MainActor.run {
                self.isLoggedIn = isSignedIn
            }
        }
    }
    
    // Sign up with email and password
    func signUp(email: String, password: String, fullName: String? = nil) {
        isLoading = true
        errorMessage = nil
        
        Task {
            let (success, needsVerification) = await SupabaseAuthManager.shared.signUp(
                email: email,
                password: password,
                fullName: fullName
            )
            
            await MainActor.run {
                self.isLoading = false
                
                if !success {
                    self.errorMessage = SupabaseAuthManager.shared.errorMessage ?? "Sign up failed"
                } else if needsVerification {
                    // User created but needs to verify email
                    self.needsEmailVerification = true
                    self.verificationEmail = email
                    // We don't set isLoggedIn = true here since they still need to verify
                } else {
                    // User created and no verification needed (or auto-verified)
                    self.isLoggedIn = true
                    self.hasConnectedTools = false
                    // Reset connected tools on new signup
                    UserDefaults.standard.set(false, forKey: "hasConnectedRequiredTools")
                    NotificationCenter.default.post(
                        name: Notification.Name("ToolsConnectionChanged"),
                        object: false
                    )
                }
            }
        }
    }
    
    // Login with email and password
    func login(email: String, password: String) {
        isLoading = true
        errorMessage = nil
        
        Task {
            let success = await SupabaseAuthManager.shared.signIn(
                email: email,
                password: password
            )
            
            await MainActor.run {
                self.isLoading = false
                if !success {
                    self.errorMessage = SupabaseAuthManager.shared.errorMessage ?? "Login failed"
                } else {
                    // Check if tools are connected for this user
                    self.checkToolsConnectionState()
                }
            }
        }
    }

    // Logout
    func logout() {
        isLoading = true
        
        Task {
            // Sign out from Google if needed
            GoogleAuthManager.shared.signOut()
            
            // Sign out from Supabase
            await SupabaseAuthManager.shared.signOut()
            
            await MainActor.run {
                self.isLoading = false
                self.userName = nil
                self.userEmail = nil
                self.hasConnectedTools = false
                self.isLoggedIn = false
                self.needsEmailVerification = false
                self.verificationEmail = nil
            }
        }
    }

    // Sign in with Google
    func signInWithGoogle() {
        isLoading = true
        errorMessage = nil
        
        GoogleAuthManager.shared.signIn { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let signInResult):
                // Get ID token from Google
                if let idToken = signInResult.user.idToken?.tokenString {
                    // Get access token if available
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
                            } else {
                                // Check if tools are connected for this user
                                self.checkToolsConnectionState()
                            }
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.errorMessage = "Failed to get ID token from Google"
                    }
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = "Google sign-in failed: \(error.localizedDescription)"
                }
            }
        }
    }
    
    // Reset password
    func resetPassword(email: String, completion: @escaping (Bool) -> Void) {
        isLoading = true
        errorMessage = nil
        
        Task {
            let success = await SupabaseAuthManager.shared.resetPassword(email: email)
            
            await MainActor.run {
                self.isLoading = false
                if !success {
                    self.errorMessage = SupabaseAuthManager.shared.errorMessage ?? "Failed to reset password"
                }
                completion(success)
            }
        }
    }
    
    // Check if user has connected required tools
    private func checkToolsConnectionState() {
        // Check if user has previously connected tools
        // This would ideally come from a user-specific database entry
        let hasConnected = UserDefaults.standard.bool(forKey: "hasConnectedRequiredTools")
        
        DispatchQueue.main.async {
            self.hasConnectedTools = hasConnected
            // Notify other components about the tools connection state
            NotificationCenter.default.post(
                name: Notification.Name("ToolsConnectionChanged"),
                object: hasConnected
            )
        }
    }
    
    // Mark tools as connected
    func markToolsAsConnected() {
        UserDefaults.standard.set(true, forKey: "hasConnectedRequiredTools")
        
        DispatchQueue.main.async {
            self.hasConnectedTools = true
            // Notify other components about the tools connection state
            NotificationCenter.default.post(
                name: Notification.Name("ToolsConnectionChanged"),
                object: true
            )
        }
    }
    
    // Check email verification status
    func checkEmailVerification() async -> Bool {
        return await SupabaseAuthManager.shared.checkEmailVerification(email: verificationEmail ?? "")
    }
}
