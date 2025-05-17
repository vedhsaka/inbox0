import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        ZStack {
            // Background
            Color.appBackground.ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                // App Logo
                Image(systemName: "waveform.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                    .foregroundColor(Color.appAccent)
                    .padding()
                    .background(
                        Circle()
                            .fill(Color.appAccent.opacity(0.1))
                            .frame(width: 120, height: 120)
                    )
                
                // Welcome Text
                VStack(spacing: 12) {
                    Text("Welcome to Possam")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .multilineTextAlignment(.center)
                    
                    Text("Your personal voice assistant to help with anything you need")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                // Features List
                VStack(spacing: 20) {
                    featureRow(icon: "waveform.path", title: "Voice Interactions", description: "Speak naturally and get intelligent responses")
                    
                    featureRow(icon: "gear", title: "Connect Your Tools", description: "Integrate with your favorite apps and services")
                    
                    featureRow(icon: "sparkles", title: "AI-powered Assistant", description: "Get help with tasks, information, and more")
                }
                .padding(.vertical, 20)
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 16) {
                    Button(action: {
                        appState.navigateTo(.login)
                    }) {
                        Text("Login")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.appAccent)
                            .cornerRadius(12)
                            .shadow(color: Color.appAccent.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    
                    Button(action: {
                        appState.navigateTo(.signup)
                    }) {
                        Text("Create Account")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color.appAccent)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.appAccent.opacity(0.5), lineWidth: 1)
                            )
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 40)
            }
        }
    }
    
    private func featureRow(icon: String, title: String, description: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(Color.appAccent)
                .frame(width: 50, height: 50)
                .background(
                    Circle()
                        .fill(Color.appAccent.opacity(0.1))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.horizontal, 30)
    }
}
