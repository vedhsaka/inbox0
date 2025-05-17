//
//  EmailVerificationView.swift
//  Possam
//
//  Created by Akash Thakur on 4/29/25.
//


import SwiftUI

struct EmailVerificationView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    
    let email: String
    @State private var isCheckingVerification = false
    @State private var secondsRemaining = 60
    @State private var timer: Timer? = nil
    
    var body: some View {
        ZStack {
            // Background
            Color.appBackground.ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "envelope.badge.fill")
                        .font(.system(size: 70))
                        .foregroundColor(Color.appAccent)
                        .padding()
                    
                    Text("Check your email")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .multilineTextAlignment(.center)
                    
                    Text("We've sent a verification link to:")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Text(email)
                        .font(.system(size: 18, weight: .bold))
                        .padding(.top, 4)
                }
                .padding(.top, 30)
                
                // Instructions
                VStack(spacing: 20) {
                    instructionRow(number: "1", text: "Open the email from Possam")
                    instructionRow(number: "2", text: "Click on the verification link")
                    instructionRow(number: "3", text: "Return to this app to continue")
                }
                .padding(.vertical, 30)
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 16) {
                    Button(action: {
                        checkVerification()
                    }) {
                        ZStack {
                            Text("I've verified my email")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.appAccent)
                                .cornerRadius(12)
                                .shadow(color: Color.appAccent.opacity(0.3), radius: 8, x: 0, y: 4)
                            
                            if isCheckingVerification {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            }
                        }
                    }
                    .disabled(isCheckingVerification)
                    
                    // Resend email button (with cooldown timer)
                    Button(action: {
                        resendVerificationEmail()
                    }) {
                        Text(secondsRemaining > 0 ? "Resend email (\(secondsRemaining)s)" : "Resend email")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(secondsRemaining > 0 ? Color.gray : Color.appAccent)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                    }
                    .disabled(secondsRemaining > 0)
                    
                    // Back to login option
                    Button(action: {
                        // Go back to login
                        resetVerificationState()
                        appState.navigateTo(.login)
                    }) {
                        Text("Back to login")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                            .padding(.vertical, 8)
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            startResendTimer()
        }
        .onDisappear {
            timer?.invalidate()
            timer = nil
        }
    }
    
    private func instructionRow(number: String, text: String) -> some View {
        HStack(spacing: 16) {
            Text(number)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 36, height: 36)
                .background(Circle().fill(Color.appAccent))
            
            Text(text)
                .font(.system(size: 16))
            
            Spacer()
        }
        .padding(.horizontal, 30)
    }
    
    private func checkVerification() {
        isCheckingVerification = true
        
        Task {
            let isVerified = await authViewModel.checkEmailVerification()
            
            await MainActor.run {
                isCheckingVerification = false
                
                if isVerified {
                    // Verified successfully - proceed to main screen
                    resetVerificationState()
                    appState.isAuthenticated = true
                    appState.navigateTo(.main)
                } else {
                    // Not verified yet
                    appState.showError("Email not verified yet. Please check your inbox and click the verification link.")
                }
            }
        }
    }
    
    private func resendVerificationEmail() {
        // Reset the timer and disable the button
        secondsRemaining = 60
        startResendTimer()
        
        // Here you would resend the verification email
        // For now, we'll just show a confirmation
        appState.showError("Verification email resent to \(email)")
    }
    
    private func startResendTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if secondsRemaining > 0 {
                secondsRemaining -= 1
            } else {
                timer?.invalidate()
            }
        }
    }
    
    private func resetVerificationState() {
        timer?.invalidate()
        authViewModel.needsEmailVerification = false
        authViewModel.verificationEmail = nil
        appState.isShowingVerificationScreen = false
        appState.verificationEmail = nil
    }
}

struct EmailVerificationView_Previews: PreviewProvider {
    static var previews: some View {
        EmailVerificationView(email: "user@example.com")
            .environmentObject(AppState())
            .environmentObject(AuthenticationViewModel())
    }
}
