import SwiftUI

// AppState to manage global application state
class AppState: ObservableObject {
    @Published var currentRoute: AppRoute = .splash
    @Published var isAuthenticated: Bool = false
    @Published var hasCompletedOnboarding: Bool = false
    
    // Loading state
    @Published var isLoading: Bool = false
    @Published var loadingMessage: String = ""
    
    // Global error handling
    @Published var errorMessage: String? = nil
    @Published var showErrorAlert: Bool = false
    
    // Add verification state
    @Published var isShowingVerificationScreen: Bool = false
    @Published var verificationEmail: String?
    
    // Check if user is authenticated on app launch
    func checkAuthState() {
        self.isLoading = true
        self.loadingMessage = "Checking authentication..."
        
        // Check if user is logged in with Supabase
        Task {
            do {
                let isSignedIn = await SupabaseAuthManager.shared.checkSession()
                
                await MainActor.run {
                    self.isAuthenticated = isSignedIn
                    if isSignedIn {
                        self.currentRoute = .main
                    } else {
                        // Check if we're in verification state
                        if SupabaseAuthManager.shared.needsEmailVerification {
                            self.isShowingVerificationScreen = true
                            self.verificationEmail = SupabaseAuthManager.shared.verificationEmail
                            self.currentRoute = .verification
                        } else {
                            self.currentRoute = .welcome
                        }
                    }
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to verify authentication: \(error.localizedDescription)"
                    self.showErrorAlert = true
                    self.isAuthenticated = false
                    self.currentRoute = .welcome
                    self.isLoading = false
                }
            }
        }
    }
    
    // Show error alert
    func showError(_ message: String) {
        self.errorMessage = message
        self.showErrorAlert = true
    }
    
    // Clear error
    func clearError() {
        self.errorMessage = nil
        self.showErrorAlert = false
    }
    
    // Navigate to a specific route
    func navigateTo(_ route: AppRoute) {
        withAnimation {
            self.currentRoute = route
        }
    }
    
    // Handle successful authentication
    func handleSuccessfulAuth() {
        self.isAuthenticated = true
        // Skip tools for now and go directly to main
        self.navigateTo(.main)
    }
    
    // Handle sign out
    func handleSignOut() {
        self.isAuthenticated = false
        self.navigateTo(.welcome)
    }
    
    // Handle email verification required
    func handleVerificationRequired(email: String) {
        self.isShowingVerificationScreen = true
        self.verificationEmail = email
        self.navigateTo(.verification)
    }
}

// Define all possible routes in the app
enum AppRoute {
    case splash
    case welcome
    case login
    case signup
    case verification
    case main
    case settings
}

// Main coordinator view that controls navigation flow
struct AppCoordinator: View {
    @StateObject private var appState = AppState()
    @StateObject private var authViewModel = AuthenticationViewModel()
    
    var body: some View {
        ZStack {
            // Main route switcher
            Group {
                switch appState.currentRoute {
                case .splash:
                    SplashView()
                        .onAppear {
                            // Simulate splash screen delay then check auth
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                appState.checkAuthState()
                            }
                        }
                case .welcome:
                    WelcomeView()
                        .environmentObject(appState)
                case .login:
                    LoginView()
                        .environmentObject(authViewModel)
                        .environmentObject(appState)
                case .signup:
                    SignupView()
                        .environmentObject(authViewModel)
                        .environmentObject(appState)
                case .verification:
                    EmailVerificationView(email: appState.verificationEmail ?? "")
                        .environmentObject(authViewModel)
                        .environmentObject(appState)
                case .main:
                    ContentView()
                        .environmentObject(authViewModel)
                        .environmentObject(appState)
                case .settings:
                    SettingsView(showSideMenu: .constant(false))
                        .environmentObject(authViewModel)
                        .environmentObject(appState)
                }
            }
            
            // Global loading overlay
            if appState.isLoading {
                ZStack {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                    
                    VStack(spacing: 20) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.5)
                        
                        Text(appState.loadingMessage)
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .padding(30)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.gray.opacity(0.7))
                    )
                }
                .transition(.opacity)
            }
        }
        .alert(isPresented: $appState.showErrorAlert) {
            Alert(
                title: Text("Error"),
                message: Text(appState.errorMessage ?? "An unknown error occurred"),
                dismissButton: .default(Text("OK"), action: {
                    appState.clearError()
                })
            )
        }
        // Observe auth state changes from AuthViewModel
        .onChange(of: authViewModel.isLoggedIn) { isLoggedIn in
            if isLoggedIn {
                appState.handleSuccessfulAuth()
            } else if appState.isAuthenticated {
                // Only update if we thought we were authenticated but now we're not
                appState.handleSignOut()
            }
        }
        // Observe verification state from AuthViewModel
        .onChange(of: authViewModel.needsEmailVerification) { needsVerification in
            if needsVerification && authViewModel.verificationEmail != nil {
                appState.handleVerificationRequired(email: authViewModel.verificationEmail!)
            }
        }
        // Observe app active state
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            // Refresh auth state when app becomes active
            if appState.currentRoute != .splash {
                // Check verification status if waiting for verification
                if appState.currentRoute == .verification {
                    Task {
                        let isVerified = await authViewModel.checkEmailVerification()
                        if isVerified {
                            await MainActor.run {
                                // User has verified their email, proceed to main screen
                                appState.isShowingVerificationScreen = false
                                appState.isAuthenticated = true
                                appState.navigateTo(.main)
                            }
                        }
                    }
                } else {
                    appState.checkAuthState()
                }
            }
        }
    }
}
