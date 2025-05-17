import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @EnvironmentObject var appState: AppState
    
    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false
    @State private var showForgotPassword = false
    @State private var resetEmail = ""
    @State private var showResetConfirmation = false
    
    var body: some View {
        ZStack {
            // Background
            Color.appBackground.ignoresSafeArea()
            
            // Content
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Text("Login to your account")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .multilineTextAlignment(.center)
                        
                        Text("Sign in to continue with Possam")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 20)
                    
                    // Email Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        TextField("Your email address", text: $email)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                    }
                    
                    // Password Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Password")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        ZStack(alignment: .trailing) {
                            if showPassword {
                                TextField("Your password", text: $password)
                                    .padding()
                                    .autocapitalization(.none)
                            } else {
                                SecureField("Your password", text: $password)
                                    .padding()
                                    .autocapitalization(.none)
                            }
                            
                            Button(action: {
                                showPassword.toggle()
                            }) {
                                Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                    .foregroundColor(.gray)
                            }
                            .padding(.trailing, 16)
                        }
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                        
                        // Forgot Password
                        HStack {
                            Spacer()
                            Button(action: {
                                showForgotPassword = true
                                resetEmail = email // Pre-fill with current email
                            }) {
                                Text("Forgot Password?")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color.appAccent)
                            }
                        }
                        .padding(.top, 4)
                    }
                    
                    // Error Message
                    if let errorMessage = authViewModel.errorMessage {
                        Text(errorMessage)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.red)
                            .padding(.top, 4)
                    }
                    
                    // Login Button
                    Button(action: {
                        login()
                    }) {
                        ZStack {
                            Text("Login")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.appAccent)
                                .cornerRadius(12)
                                .shadow(color: Color.appAccent.opacity(0.3), radius: 8, x: 0, y: 4)
                            
                            if authViewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            }
                        }
                    }
                    .disabled(authViewModel.isLoading || email.isEmpty || password.isEmpty)
                    .opacity(authViewModel.isLoading || email.isEmpty || password.isEmpty ? 0.7 : 1.0)
                    .padding(.top, 10)
                    
                    // Divider
                    HStack {
                        VStack {
                            Divider()
                        }
                        
                        Text("OR")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 16)
                        
                        VStack {
                            Divider()
                        }
                    }
                    .padding(.vertical, 20)
                    
                    // Social Login Buttons
                    VStack(spacing: 16) {
                        // Google Button
                        Button(action: {
                            authViewModel.signInWithGoogle()
                        }) {
                            HStack {
                                Image(systemName: "g.circle.fill")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(.red)
                                
                                Text("Continue with Google")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.primary)
                                
                                Spacer()
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                        }
                        .disabled(authViewModel.isLoading)
                    }
                        
                    // Sign Up Link
                    HStack {
                        Text("Don't have an account?")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                        
                        Button(action: {
                            appState.navigateTo(.signup)
                        }) {
                            Text("Sign Up")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(Color.appAccent)
                        }
                    }
                    .padding(.top, 10)
                    .padding(.bottom, 20)
                }
                .padding(.horizontal, 24)
            }
        }
        .sheet(isPresented: $showForgotPassword) {
            forgotPasswordView
        }
        .alert(isPresented: $showResetConfirmation) {
            Alert(
                title: Text("Password Reset"),
                message: Text("If an account exists for \(resetEmail), we've sent instructions to reset your password."),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    // Forgot Password Sheet
    private var forgotPasswordView: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 12) {
                Text("Reset Your Password")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Enter the email address associated with your account and we'll send you a link to reset your password.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            // Email field
            TextField("Email address", text: $resetEmail)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
                .padding(.horizontal)
            
            // Buttons
            VStack(spacing: 12) {
                Button(action: {
                    // Request password reset
                    authViewModel.resetPassword(email: resetEmail) { success in
                        showForgotPassword = false
                        showResetConfirmation = true
                    }
                }) {
                    Text("Send Reset Link")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.appAccent)
                        .cornerRadius(12)
                }
                .disabled(resetEmail.isEmpty || !isValidEmail(resetEmail))
                .opacity(resetEmail.isEmpty || !isValidEmail(resetEmail) ? 0.6 : 1)
                
                Button(action: {
                    showForgotPassword = false
                }) {
                    Text("Cancel")
                        .font(.headline)
                        .foregroundColor(.appAccent)
                }
            }
            .padding()
            
            Spacer()
        }
        .padding(.top, 40)
    }
    
    // MARK: - Helper Functions
    
    private func login() {
        // Hide keyboard
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        
        // Validate form
        guard !email.isEmpty && !password.isEmpty else {
            authViewModel.errorMessage = "Please enter your email and password"
            return
        }
        
        // Login
        authViewModel.login(email: email, password: password)
    }
    
    private func signInWithGoogle() {
        // Hide keyboard
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        
        // Sign in with Google
        authViewModel.signInWithGoogle()
    }
    
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}
