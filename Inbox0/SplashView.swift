import SwiftUI

struct SplashView: View {
    @State private var animateGradient = false
    @State private var showLogo = false
    @State private var showText = false
    
    var body: some View {
        ZStack {
            // Premium background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.white,
                    Color.premiumLightBlue,
                    Color.premiumLighterBlue
                ]),
                startPoint: animateGradient ? .topLeading : .bottomLeading,
                endPoint: animateGradient ? .bottomTrailing : .topTrailing
            )
            .ignoresSafeArea()
            .animation(Animation.easeInOut(duration: 3).repeatForever(autoreverses: true), value: animateGradient)
            
            // Subtle decorative elements
            ZStack {
                // Circle accent 1
                Circle()
                    .fill(Color.blue.opacity(0.03))
                    .frame(width: 300, height: 300)
                    .offset(x: 150, y: -200)
                    .blur(radius: 50)
                
                // Circle accent 2
                Circle()
                    .fill(Color.premiumGold.opacity(0.05))
                    .frame(width: 300, height: 300)
                    .offset(x: -150, y: 200)
                    .blur(radius: 50)
            }
            
            VStack(spacing: 40) {
                // Logo
                ZStack {
                    // Gold circle border
                    Circle()
                        .strokeBorder(
                            LinearGradient.goldGradient,
                            lineWidth: 2
                        )
                        .frame(width: 120, height: 120)
                        .opacity(showLogo ? 1 : 0)
                        .scaleEffect(showLogo ? 1 : 0.8)
                    
                    // Audio waveform icon (inspired by Image 3)
                    VStack(spacing: 3) {
                        ForEach(0..<11) { i in
                            RoundedRectangle(cornerRadius: 1.5)
                                .fill(Color.premiumAccent)
                                .frame(width: 3, height: getLineHeight(for: i))
                        }
                    }
                    .frame(width: 60, height: 60)
                    .opacity(showLogo ? 1 : 0)
                    .scaleEffect(showLogo ? 1 : 0.5)
                }
                .animation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0).delay(0.3), value: showLogo)
                
                VStack(spacing: 16) {
                    // App Name
                    Text("VOICE ELITE")
                        .font(.system(size: 28, weight: .semibold, design: .default))
                        .tracking(2)
                        .foregroundColor(Color.premiumAccent)
                    
                    // Tagline
                    Text("Superior Voice Intelligence")
                        .font(.system(size: 16, weight: .medium, design: .default))
                        .tracking(1)
                        .foregroundColor(Color.premiumAccent.opacity(0.7))
                }
                .opacity(showText ? 1 : 0)
                .offset(y: showText ? 0 : 20)
                .animation(.easeOut(duration: 0.6).delay(0.6), value: showText)
                
                // Loading indicator
                LuxuryLoader()
                    .frame(width: 120, height: 30)
                    .padding(.top, 30)
                    .opacity(showText ? 1 : 0)
                    .animation(.easeOut(duration: 0.4).delay(0.9), value: showText)
            }
        }
        .onAppear {
            // Start animations
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                animateGradient = true
                showLogo = true
                showText = true
            }
        }
    }
    
    // Helper to generate waveform line heights
    private func getLineHeight(for index: Int) -> CGFloat {
        let middleIndex = 5
        let distance = abs(index - middleIndex)
        
        if distance == 0 {
            return 45
        } else if distance == 1 {
            return 35
        } else if distance == 2 {
            return 28
        } else if distance == 3 {
            return 20
        } else if distance == 4 {
            return 15
        } else {
            return 10
        }
    }
}

// Luxury Loading Animation
struct LuxuryLoader: View {
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.premiumGold,
                                Color.premiumGoldLight
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 8, height: 8)
                    .opacity(isAnimating ? 1 : 0.3)
                    .animation(
                        Animation
                            .easeInOut(duration: 0.7)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.2),
                        value: isAnimating
                    )
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}
