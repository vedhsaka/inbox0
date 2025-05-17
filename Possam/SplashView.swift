import SwiftUI

struct SplashView: View {
    // Animation states
    @State private var logoScale: CGFloat = 0.8
    @State private var opacity: Double = 0
    
    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                gradient: Gradient(colors: [Color.appAccent, Color(hex: "4169E1")]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                // App Logo
                Image(systemName: "waveform.circle.fill") // Replace with your actual logo
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 120, height: 120)
                    .foregroundColor(.white)
                    .padding()
                    .background(
                        Circle()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 160, height: 160)
                    )
                
                // App Name
                Text("Possam")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                // Loading indicator
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
                    .padding(.top, 30)
            }
            .scaleEffect(logoScale)
            .opacity(opacity)
            .onAppear {
                // Animate the logo when view appears
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.3)) {
                    logoScale = 1.0
                    opacity = 1.0
                }
            }
        }
    }
}
