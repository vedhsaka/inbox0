import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var appState: AppState
    @State private var animateCard = false
    
    var body: some View {
        ZStack {
            // Premium background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.white,
                    Color(hex: "F8F9FC")
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Subtle patterns
            ZStack {
                // Circle accent 1
                Circle()
                    .fill(Color.blue.opacity(0.03))
                    .frame(width: 300, height: 300)
                    .offset(x: 150, y: -200)
                    .blur(radius: 50)
                
                // Circle accent 2
                Circle()
                    .fill(Color(hex: "D4B978").opacity(0.05))
                    .frame(width: 300, height: 300)
                    .offset(x: -150, y: 200)
                    .blur(radius: 50)
            }
            
            // Content
            ScrollView {
                VStack(spacing: 40) {
                    // Logo and brand section
                    VStack(spacing: 16) {
                        // App Logo
                        ZStack {
                            // Gold circle border
                            Circle()
                                .strokeBorder(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(hex: "D4B978"),
                                            Color(hex: "F0E4BB"),
                                            Color(hex: "D4B978")
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2
                                )
                                .frame(width: 100, height: 100)
                            
                            // Audio waveform icon
                            VStack(spacing: 2.5) {
                                ForEach(0..<11) { i in
                                    RoundedRectangle(cornerRadius: 1.5)
                                        .fill(Color(hex: "1A2C54"))
                                        .frame(width: 3, height: getLineHeight(for: i))
                                }
                            }
                            .frame(width: 50, height: 50)
                        }
                        .padding(.top, 30)
                        
                        // Brand name and tagline
                        VStack(spacing: 8) {
                            Text("VOICE ELITE")
                                .font(.system(size: 26, weight: .semibold, design: .default))
                                .tracking(2)
                                .foregroundColor(Color(hex: "1A2C54"))
                            
                            Text("Superior Voice Intelligence")
                                .font(.system(size: 15, weight: .medium, design: .default))
                                .tracking(1)
                                .foregroundColor(Color(hex: "1A2C54").opacity(0.7))
                        }
                    }
                    .padding(.top, 40)
                    
                    // Features cards
                    VStack(spacing: 20) {
                        Text("EXCLUSIVE FEATURES")
                            .font(.system(size: 14, weight: .semibold, design: .default))
                            .tracking(3)
                            .foregroundColor(Color(hex: "1A2C54").opacity(0.7))
                            .padding(.bottom, 5)
                        
                        // Feature Cards
                        ForEach(premiumFeatures) { feature in
                            PremiumFeatureCard(feature: feature)
                                .offset(y: animateCard ? 0 : 40)
                                .opacity(animateCard ? 1 : 0)
                                .animation(
                                    .spring(response: 0.6, dampingFraction: 0.8)
                                    .delay(Double(feature.id) * 0.1 + 0.2),
                                    value: animateCard
                                )
                        }
                    }
                    
                    Spacer(minLength: 30)
                    
                    // Action Buttons
                    VStack(spacing: 16) {
                        Button(action: {
                            appState.navigateTo(.login)
                        }) {
                            Text("SIGN IN")
                                .font(.system(size: 16, weight: .semibold))
                                .tracking(1.5)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(hex: "1A2C54"),
                                            Color(hex: "0F1E3D")
                                        ]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .cornerRadius(12)
                                .shadow(color: Color(hex: "1A2C54").opacity(0.2), radius: 10, x: 0, y: 5)
                        }
                        
                        Button(action: {
                            appState.navigateTo(.signup)
                        }) {
                            Text("CREATE ACCOUNT")
                                .font(.system(size: 16, weight: .semibold))
                                .tracking(1.5)
                                .foregroundColor(Color(hex: "1A2C54"))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 4)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .strokeBorder(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    Color(hex: "D4B978"),
                                                    Color(hex: "F0E4BB"),
                                                    Color(hex: "D4B978")
                                                ]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1
                                        )
                                )
                        }
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 40)
                    .offset(y: animateCard ? 0 : 40)
                    .opacity(animateCard ? 1 : 0)
                    .animation(.easeOut(duration: 0.6).delay(0.7), value: animateCard)
                }
                .padding(.horizontal)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                animateCard = true
            }
        }
    }
    
    // Helper to generate waveform line heights
    private func getLineHeight(for index: Int) -> CGFloat {
        let middleIndex = 5
        let distance = abs(index - middleIndex)
        
        if distance == 0 {
            return 40
        } else if distance == 1 {
            return 30
        } else if distance == 2 {
            return 22
        } else if distance == 3 {
            return 16
        } else if distance == 4 {
            return 10
        } else {
            return 7
        }
    }
}

// Premium Feature Card
struct PremiumFeatureCard: View {
    let feature: PremiumFeature
    
    var body: some View {
        HStack(spacing: 20) {
            // Feature icon
            ZStack {
                Circle()
                    .fill(Color(hex: "F8F9FC"))
                    .frame(width: 60, height: 60)
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                
                Image(systemName: feature.iconName)
                    .font(.system(size: 24))
                    .foregroundColor(Color(hex: "1A2C54"))
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(feature.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(hex: "1A2C54"))
                
                Text(feature.description)
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "1A2C54").opacity(0.7))
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 15, x: 0, y: 5)
    }
}

// Premium Feature Model
struct PremiumFeature: Identifiable {
    let id: Int
    let title: String
    let description: String
    let iconName: String
}

// Sample features
let premiumFeatures = [
    PremiumFeature(
        id: 0,
        title: "Advanced Voice Recognition",
        description: "Industry-leading accuracy with multi-accent support",
        iconName: "waveform"
    ),
    PremiumFeature(
        id: 1,
        title: "Priority Processing",
        description: "Dedicated servers ensure fast response times",
        iconName: "bolt.fill"
    ),
    PremiumFeature(
        id: 2,
        title: "Personalized Assistance",
        description: "Learns your preferences for a tailored experience",
        iconName: "person.fill"
    ),
    PremiumFeature(
        id: 3,
        title: "Premium Integrations",
        description: "Connect with your exclusive services and accounts",
        iconName: "link.circle.fill"
    )
]
