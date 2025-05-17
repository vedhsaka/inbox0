import SwiftUI
import Vapi
import Combine
import AVFoundation

struct ContentView: View {
    @StateObject private var vapiViewModel = VapiViewModel()
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @EnvironmentObject var appState: AppState
    
    // For status indicator
    @State private var showStatusIndicator = true
    @State private var statusMessage = "Ready"
    
    // Add this to keep track of app state
    @Environment(\.scenePhase) private var scenePhase
    
    // Side menu state
    @State private var showSideMenu = false
    
    // Animation states
    @State private var pulseAnimation = false
    @State private var waveAmplitude: CGFloat = 0.0
    
    var body: some View {
        ZStack {
            // Premium background
            LinearGradient.premiumBackground
                .ignoresSafeArea()
            
            // Subtle background patterns
            ZStack {
                // Top-right accent
                Circle()
                    .fill(Color.blue.opacity(0.05))
                    .frame(width: 300, height: 300)
                    .blur(radius: 80)
                    .offset(x: 150, y: -250)
                
                // Bottom-left accent
                Circle()
                    .fill(Color.blue.opacity(0.05))
                    .frame(width: 300, height: 300)
                    .blur(radius: 80)
                    .offset(x: -150, y: 350)
            }
            .ignoresSafeArea()
            
            // Premium Audio Wave Visualization
            ZStack {
                // Audio Waveform (inspired by Image 3)
                ZStack {
                    // Gold circle outline
                    Circle()
                        .stroke(LinearGradient.goldGradient, lineWidth: 2)
                        .frame(width: 220, height: 220)
                    
                    // Audio waveform
                    PremiumWaveformView(
                        isActive: vapiViewModel.isUserSpeaking || vapiViewModel.isAssistantSpeaking,
                        amplitude: waveAmplitude,
                        color: vapiViewModel.isUserSpeaking ? Color.premiumAccent : Color.premiumAccent.opacity(0.8)
                    )
                    .frame(width: 150, height: 100)
                    
                    // Pulse effect when active
                    Circle()
                        .stroke(
                            Color.premiumGold.opacity(vapiViewModel.isCallActive ? 0.3 : 0),
                            lineWidth: 3
                        )
                        .frame(width: pulseAnimation ? 260 : 220, height: pulseAnimation ? 260 : 220)
                        .opacity(pulseAnimation ? 0 : 0.5)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)

                VStack {
                    Spacer()
                    // Microphone Button
                    Button(action: {
                        if vapiViewModel.isCallActive {
                            updateStatus("Assistant stopped")
                            vapiViewModel.stopAssistant()
                        } else {
                            updateStatus("Listening...")
                            vapiViewModel.startAssistant()
                        }
                    }) {
                        ZStack {
                            // Button background
                            Circle()
                                .fill(
                                    vapiViewModel.isCallActive ?
                                        LinearGradient.redGradient :
                                        LinearGradient.navyGradient
                                )
                                .frame(width: 76, height: 76)
                                .shadow(color: Color.black.opacity(0.15), radius: 15, x: 0, y: 8)
                            
                            // Icon
                            if vapiViewModel.isCallActive {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.white)
                                    .frame(width: 20, height: 20)
                            } else {
                                Image(systemName: "mic.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .padding(.bottom, 60)
                }
            }
            
            // Status indicator (elegant toast)
            if showStatusIndicator {
                VStack {
                    Spacer()
                    
                    HStack(spacing: 12) {
                        if vapiViewModel.isUserSpeaking || vapiViewModel.isAssistantSpeaking {
                            // Small animated dot
                            Circle()
                                .fill(vapiViewModel.isUserSpeaking ? Color.blue : Color.premiumGold)
                                .frame(width: 8, height: 8)
                                .opacity(pulseAnimation ? 1.0 : 0.5)
                        }
                        
                        Text(statusMessage)
                            .font(.system(size: 15, weight: .medium, design: .default))
                            .foregroundColor(Color.premiumAccent)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 4)
                    )
                    .opacity(showStatusIndicator ? 1 : 0)
                    .animation(.easeInOut(duration: 0.3), value: showStatusIndicator)
                    
                    Spacer().frame(height: 160)
                }
                .transition(.opacity)
            }
            
            // Menu button (elegant hamburger)
            VStack {
                HStack {
                    Button(action: {
                        withAnimation(.spring()) {
                            showSideMenu.toggle()
                        }
                    }) {
                        HStack(spacing: 8) {
                            // Three horizontal lines
                            VStack(spacing: 5) {
                                ForEach(0..<3) { _ in
                                    Rectangle()
                                        .fill(Color.premiumAccent)
                                        .frame(width: 18, height: 2)
                                        .cornerRadius(1)
                                }
                            }
                            
                            Text("Menu")
                                .foregroundColor(Color.premiumAccent)
                                .font(.system(size: 14, weight: .medium))
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                        )
                    }
                    .padding(.leading, 20)
                    .padding(.top, 60)
                    
                    Spacer()
                }
                Spacer()
            }
            
            // Settings Side Menu
            if showSideMenu {
                Color.black.opacity(0.2)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring()) {
                            showSideMenu = false
                        }
                    }
                
                HStack {
                    ZStack {
                        Color.white
                            .edgesIgnoringSafeArea(.all)
                            .shadow(color: Color.black.opacity(0.15), radius: 15, x: 5, y: 0)
                    
                        SettingsView(showSideMenu: $showSideMenu)
                            .environmentObject(authViewModel)
                            .environmentObject(appState)
                    }
                    .frame(width: UIScreen.main.bounds.width * 0.85)
                    .transition(.move(edge: .leading))
                    .gesture(
                        DragGesture()
                            .onEnded { value in
                                if value.translation.width < -50 {
                                    withAnimation(.spring()) {
                                        showSideMenu = false
                                    }
                                }
                            }
                    )
                    
                    Spacer()
                }
            }
            
            // Loading overlay
            if vapiViewModel.isConnecting {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .transition(.opacity)
                
                VStack(spacing: 20) {
                    LuxuryLoadingIndicator()
                        .frame(width: 80, height: 80)
                    
                    Text("Connecting...")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                }
                .transition(.opacity)
            }
        }
        .edgesIgnoringSafeArea(.all)
        // Add edge swipe gesture to open menu
        .gesture(
            DragGesture()
                .onChanged { value in
                    // Only detect swipes starting from the left edge
                    if value.startLocation.x < 30 && value.translation.width > 50 && !showSideMenu {
                        withAnimation(.spring()) {
                            showSideMenu = true
                        }
                    }
                }
        )
        .onAppear {
            // Start animations
            withAnimation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                pulseAnimation = true
            }
            
            // Animate the wave amplitude
            withAnimation(Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                waveAmplitude = 1.0
            }
        }
        // Monitor app state changes
        .onChange(of: scenePhase) { newPhase in
            handleScenePhaseChange(newPhase)
        }
        .onChange(of: vapiViewModel.isUserSpeaking) { isSpeaking in
            if isSpeaking {
                updateStatus("Listening...")
            } else if vapiViewModel.isCallActive {
                updateStatus("Processing...")
            }
        }
        .onChange(of: vapiViewModel.isAssistantSpeaking) { isSpeaking in
            if isSpeaking {
                updateStatus("Speaking...")
                // Ensure the call is visibly active when assistant starts speaking
                if !vapiViewModel.isCallActive {
                    vapiViewModel.isCallActive = true
                }
            } else if vapiViewModel.isCallActive && !vapiViewModel.isUserSpeaking {
                updateStatus("Thinking...")
            }
        }
        .onChange(of: vapiViewModel.isCallActive) { isActive in
            if isActive {
                if !vapiViewModel.isConnecting && !vapiViewModel.isUserSpeaking && !vapiViewModel.isAssistantSpeaking {
                    updateStatus("Ready")
                }
            } else {
                updateStatus("Ready")
            }
        }
    }
    
    // Handle app state changes
    private func handleScenePhaseChange(_ newPhase: ScenePhase) {
        switch newPhase {
        case .active:
            // App is active (foreground)
            print("App became active")
            if vapiViewModel.isCallActive {
                // Reactivate audio session if needed
                activateAudioSession()
            }
        case .inactive:
            // App is inactive but visible
            print("App became inactive")
        case .background:
            // App is in background
            print("App went to background")
            // Ensure audio continues to run in background if call is active
            if vapiViewModel.isCallActive {
                ensureBackgroundAudio()
            }
        @unknown default:
            break
        }
    }
    
    // Activate audio session
    private func activateAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Failed to activate audio session: \(error.localizedDescription)")
        }
    }
    
    // Ensure audio keeps running in background
    private func ensureBackgroundAudio() {
        // Prevent app from suspending audio in background
        DispatchQueue.main.async {
            UIApplication.shared.beginBackgroundTask {
                // End of background task
            }
        }
    }
    
    private func updateStatus(_ message: String) {
        withAnimation {
            statusMessage = message
            showStatusIndicator = true
        }
        
        // Hide status after delay if not actively changing
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            withAnimation {
                if statusMessage == message {
                    showStatusIndicator = false
                }
            }
        }
    }
}

// MARK: - Premium Waveform View
struct PremiumWaveformView: View {
    let isActive: Bool
    let amplitude: CGFloat
    let color: Color
    
    // Generate a sophisticated waveform pattern inspired by Image 3
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<15) { index in
                WaveBar(
                    height: self.barHeight(at: index),
                    width: 5,
                    cornerRadius: 2.5,
                    color: color,
                    delay: Double(index) * 0.05
                )
            }
        }
    }
    
    private func barHeight(at index: Int) -> CGFloat {
        if !isActive {
            return 10 + (index % 3 == 0 ? 5 : 0)
        }
        
        let middleIndex = 7
        let distance = abs(index - middleIndex)
        let baseHeight: CGFloat = 10
        
        if distance == 0 {
            return 80 * amplitude
        } else if distance == 1 {
            return 70 * amplitude
        } else if distance == 2 {
            return 60 * amplitude
        } else if distance == 3 {
            return 40 * amplitude
        } else if distance == 4 {
            return 30 * amplitude
        } else if distance == 5 {
            return 20 * amplitude
        } else {
            return baseHeight
        }
    }
}

struct WaveBar: View {
    let height: CGFloat
    let width: CGFloat
    let cornerRadius: CGFloat
    let color: Color
    let delay: Double
    
    @State private var scale: CGFloat = 0.2
    
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(color)
            .frame(width: width, height: height)
            .scaleEffect(CGSize(width: 1, height: scale))
            .animation(
                Animation
                    .easeInOut(duration: 0.6)
                    .repeatForever(autoreverses: true)
                    .delay(delay),
                value: scale
            )
            .onAppear {
                self.scale = 1.0
            }
    }
}

// MARK: - Luxury Loading Indicator
struct LuxuryLoadingIndicator: View {
    @State private var rotation: Double = 0
    @State private var innerRotation: Double = 0
    
    var body: some View {
        ZStack {
            // Outer ring
            Circle()
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.white.opacity(0.2), Color.white.opacity(0.8)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 3
                )
                .frame(width: 60, height: 60)
                .rotationEffect(Angle(degrees: rotation))
                .onAppear {
                    withAnimation(Animation.linear(duration: 2).repeatForever(autoreverses: false)) {
                        rotation = 360
                    }
                }
            
            // Inner ring
            Circle()
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.white.opacity(0.8), Color.white.opacity(0.2)]),
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 2
                )
                .frame(width: 40, height: 40)
                .rotationEffect(Angle(degrees: innerRotation))
                .onAppear {
                    withAnimation(Animation.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                        innerRotation = -360
                    }
                }
            
            // Center dot
            Circle()
                .fill(Color.white)
                .frame(width: 8, height: 8)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AuthenticationViewModel())
            .environmentObject(AppState())
    }
}
