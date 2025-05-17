import SwiftUI
import Supabase
import GoogleSignIn
import AuthenticationServices
import Foundation

class SupabaseAuthManager: ObservableObject {
    static let shared = SupabaseAuthManager()
    
    private lazy var supabase = SupabaseClient(
        supabaseURL: URL(string: "https://gqixkhauxqhinuuqbuld.supabase.co")!,
        supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdxaXhraGF1eHFoaW51dXFidWxkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDUyOTM4MTcsImV4cCI6MjA2MDg2OTgxN30.U5Ww0oJibAJawaLK7tnvtDggHoPH3gXY78emZ5yRD0w"
    )
    
    @Published var isSignedIn = false
    @Published var user: User? = nil
    @Published var errorMessage: String?
    @Published var userMetadata: [String: Any]? = nil
    
    // Add properties for email verification
    @Published var needsEmailVerification = false
    @Published var verificationEmail: String?
    
    init() {
        // No need to check session here, the AppCoordinator will call checkSession
    }
    
    // Check if user has a valid session
    func checkSession() async -> Bool {
        do {
            let session = try await supabase.auth.session
            let user = session.user
            
            await MainActor.run {
                self.user = user
                self.userMetadata = user.userMetadata as? [String: Any]
                self.isSignedIn = true
                self.errorMessage = nil
                self.needsEmailVerification = false
            }
            return true
        } catch {
            print("No existing session or session expired: \(error.localizedDescription)")
            await MainActor.run {
                self.isSignedIn = false
                self.user = nil
                self.userMetadata = nil
            }
            return false
        }
    }
    
    // Email sign up - modified to return verification status
    func signUp(email: String, password: String, fullName: String? = nil) async -> (Bool, Bool) {
        do {
            let metadata: [String: AnyJSON]? = fullName.map { ["full_name": .string($0)] }
            // Sign up the user with Supabase
            let authResponse = try await supabase.auth.signUp(
                email: email,
                password: password,
                data: metadata
            )
            
            let newUser = authResponse.user
            
            // Check if email confirmation is required
            // In Supabase, if email confirmation is enabled, user will have "confirmed_at" field as nil
            let requiresEmailConfirmation = newUser.emailConfirmedAt == nil
            
            await MainActor.run {
                if requiresEmailConfirmation {
                    self.needsEmailVerification = true
                    self.verificationEmail = email
                    self.isSignedIn = false // Not signed in until verified
                } else {
                    self.user = newUser
                    self.userMetadata = newUser.userMetadata as? [String: Any]
                    self.isSignedIn = true
                    self.needsEmailVerification = false
                }
                self.errorMessage = nil
            }
            
            return (true, requiresEmailConfirmation)
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to sign up: \(error.localizedDescription)"
                self.isSignedIn = false
                self.needsEmailVerification = false
            }
            return (false, false)
        }
    }
    
    // Email login
    func signIn(email: String, password: String) async -> Bool {
        do {
            // Sign in with email and password
            let authResponse = try await supabase.auth.signIn(
                email: email,
                password: password
            )
            let signedInUser = authResponse.user
            
            // Check if the email has been confirmed
            if signedInUser.emailConfirmedAt == nil {
                await MainActor.run {
                    self.errorMessage = "Please verify your email before logging in"
                    self.needsEmailVerification = true
                    self.verificationEmail = email
                    self.isSignedIn = false
                }
                return false
            }
            
            await MainActor.run {
                self.user = authResponse.user
                self.userMetadata = signedInUser.userMetadata as? [String: Any]
                self.isSignedIn = true
                self.errorMessage = nil
                self.needsEmailVerification = false
            }
            
            return true
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to sign in: \(error.localizedDescription)"
                self.isSignedIn = false
            }
            return false
        }
    }
    
    func signInWithGoogle(idToken: String, accessToken: String? = nil) async -> Bool {
        do {
            // Create the credentials object for OpenID Connect
            let credentials = OpenIDConnectCredentials(
                provider: .google,
                idToken: idToken,
                accessToken: accessToken
            )
            
            // Call the Supabase signInWithIdToken method with the credentials
            let authResponse = try await supabase.auth.signInWithIdToken(
                credentials: credentials
            )
            
            // Handle the successful authentication
            await MainActor.run {
                self.user = authResponse.user
                self.userMetadata = authResponse.user.userMetadata as? [String: Any]
                self.isSignedIn = true
                self.errorMessage = nil
                self.needsEmailVerification = false // Google accounts are pre-verified
            }
            
            return true
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to sign in with Google: \(error.localizedDescription)"
                self.isSignedIn = false
            }
            return false
        }
    }

    // Helper method to update user state
    private func updateUserState(with user: User) async {
        await MainActor.run {
            self.user = user
            self.userMetadata = user.userMetadata as? [String: Any]
            self.isSignedIn = true
            self.errorMessage = nil
            self.needsEmailVerification = false // Google accounts are pre-verified
        }
    }
    
    // Sign out
    func signOut() async {
        do {
            try await supabase.auth.signOut()
            await MainActor.run {
                self.isSignedIn = false
                self.user = nil
                self.userMetadata = nil
                self.needsEmailVerification = false
                self.verificationEmail = nil
            }
        } catch {
            print("Error signing out: \(error.localizedDescription)")
            // Even if there's an error, we still want to sign out locally
            await MainActor.run {
                self.isSignedIn = false
                self.user = nil
                self.userMetadata = nil
                self.needsEmailVerification = false
                self.verificationEmail = nil
            }
        }
    }
    
    // Reset password
    func resetPassword(email: String) async -> Bool {
        do {
            try await supabase.auth.resetPasswordForEmail(email)
            return true
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to send password reset: \(error.localizedDescription)"
            }
            return false
        }
    }
    
    // Check if email has been verified
    func checkEmailVerification(email: String) async -> Bool {
        do {
            // First try to get user by email - in real app, you might need a server API for this
            // This is a simplified version - in production, you'd need a secure backend endpoint
            
            // For demo purposes, we'll try to sign in with a temporary token
            // and check if emailConfirmedAt is set
            let result = try await supabase.auth.verifyOTP(
                email: email,
                token: "temporary",
                type: .emailChange
            )
            
            if result.user.emailConfirmedAt != nil {
                await MainActor.run {
                    self.needsEmailVerification = false
                    self.verificationEmail = nil
                }
                return true
            } else {
                return false
            }
        } catch {
            // Alternative approach: try to retrieve the user's session
            // and check if their email is confirmed
            do {
                let session = try await supabase.auth.session
                if session.user.email == email && session.user.emailConfirmedAt != nil {
                    await MainActor.run {
                        self.needsEmailVerification = false
                        self.verificationEmail = nil
                        self.isSignedIn = true
                        self.user = session.user
                    }
                    return true
                }
            } catch {
                // Session not available or not matching email
            }
            
            return false
        }
    }
    
    // Update user profile
    func updateUserMetadata(metadata: [String: Any]) async -> Bool {
        do {
            // Convert metadata to dictionary compatible with Supabase
            var metadataDict: [String: AnyJSON] = [:]
            for (key, value) in metadata {
                switch value {
                case let str as String:  metadataDict[key] = .string(str)
                case let num as Int:     metadataDict[key] = .integer(num)
                case let dbl as Double:  metadataDict[key] = .double(dbl)
                case let bool as Bool:   metadataDict[key] = .bool(bool)
                default:                 metadataDict[key] = .string(String(describing: value))
                }
            }
            
            let updatedUser = try await supabase.auth.update(
                user: UserAttributes(data: metadataDict)
            )
            
            await MainActor.run {
                self.user = updatedUser
                self.userMetadata = updatedUser.userMetadata as? [String: Any]
            }
            
            return true
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to update profile: \(error.localizedDescription)"
            }
            return false
        }
    }
}
