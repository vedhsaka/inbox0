import SwiftUI
import Vapi
import Combine
import AVFoundation

struct ContentView: View {
    @StateObject private var vapiViewModel = VapiViewModel()
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @EnvironmentObject var appState: AppState
    
    // For small state indicator
    @State private var showStatusIndicator = true
    @State private var statusMessage = "Ready"
    
    // Add this to keep track of app state
    @Environment(\.scenePhase) private var scenePhase
    
    // Side menu state
    @State private var showSideMenu = false
    
    var body: some View {
        ZStack {
            // Full-screen visualization
            ParticleSystem(
                isUserSpeaking: vapiViewModel.isUserSpeaking,
                isAssistantSpeaking: vapiViewModel.isAssistantSpeaking,
                isAssistantThinking: !vapiViewModel.isUserSpeaking && !vapiViewModel.isAssistantSpeaking && vapiViewModel.isCallActive,
                audioLevel: vapiViewModel.isUserSpeaking ? vapiViewModel.userAudioLevel : vapiViewModel.assistantAudioLevel
            )
            
            // Added Possam Character View on top of existing UI
            PossamCharacterView(
                isUserSpeaking: vapiViewModel.isUserSpeaking,
                isAssistantSpeaking: vapiViewModel.isAssistantSpeaking,
                isAssistantThinking: !vapiViewModel.isUserSpeaking && !vapiViewModel.isAssistantSpeaking && vapiViewModel.isCallActive
            )
            
            // Optional status indicator (fades out after 3 seconds of inactivity)
            if showStatusIndicator {
                VStack {
                    Spacer()
                    
                    Text(statusMessage)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(Color.black.opacity(0.5))
                                .blur(radius: 5)
                        )
                        .foregroundColor(.white)
                    
                    Spacer().frame(height: 140)
                }
                .transition(.opacity)
            }
            
            if vapiViewModel.isConnecting {
                VStack {
                    Spacer()
                    
                    LoadingIndicatorView()
                        .frame(width: 80, height: 80)
                    
                    Text("Connecting...")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.top, 8)
                    
                    Spacer().frame(height: 140) // Same spacing as status indicator
                }
                .transition(.opacity)
            }
            
            // Microphone button
            VStack {
                Spacer()
                EnhancedActionButtonView(
                    isCallActive: vapiViewModel.isCallActive,
                    onStartTapped: {
                        HapticFeedbackManager.shared.playStartListeningFeedback()
                        updateStatus("Listening...")
                        vapiViewModel.startAssistant()
                    },
                    onStopTapped: {
                        HapticFeedbackManager.shared.playStopListeningFeedback()
                        updateStatus("Assistant stopped")
                        vapiViewModel.stopAssistant()
                    }
                )
                .padding(.bottom, 50)
            }
            
            // Hamburger menu button - FIXED POSITION
            VStack {
                HStack {
                    Button(action: {
                        withAnimation(.spring()) {
                            showSideMenu.toggle()
                        }
                    }) {
                        Image(systemName: "line.horizontal.3")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Circle().fill(Color.black.opacity(0.3)))
                    }
                    .padding(.leading, 16)
                    .padding(.top, 50) // MOVED DOWN FROM 16 TO 50
                    
                    Spacer()
                }
                Spacer()
            }
            
            // Settings Side Menu - IMPROVED
            if showSideMenu {
                Color.black.opacity(0.4)
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
                            .shadow(color: Color.black.opacity(0.3), radius: 10, x: 5, y: 0)
                    
                        SettingsView(showSideMenu: $showSideMenu) // PASS BINDING
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
            // Initialize the app state
            HapticFeedbackManager.shared.prepareGenerators()
        }
        // Monitor app state changes
        .onChange(of: scenePhase) { newPhase in
            handleScenePhaseChange(newPhase)
        }
        .onChange(of: vapiViewModel.isUserSpeaking) { isSpeaking in
            if isSpeaking {
                updateStatus("Listening...")
                HapticFeedbackManager.shared.startListeningPattern(audioLevel: vapiViewModel.userAudioLevel)
            } else if vapiViewModel.isCallActive {
                updateStatus("Processing...")
                HapticFeedbackManager.shared.stopContinuousPattern()
            }
        }
        .onChange(of: vapiViewModel.isAssistantSpeaking) { isSpeaking in
            if isSpeaking {
                updateStatus("Speaking...")
                HapticFeedbackManager.shared.startSpeakingPattern(audioLevel: vapiViewModel.assistantAudioLevel)
                // Ensure the call is visibly active when assistant starts speaking
                if !vapiViewModel.isCallActive {
                    vapiViewModel.isCallActive = true
                }
            } else if vapiViewModel.isCallActive && !vapiViewModel.isUserSpeaking {
                updateStatus("Thinking...")
                HapticFeedbackManager.shared.startThinkingPattern()
            }
        }
        .onChange(of: vapiViewModel.isCallActive) { isActive in
            if isActive {
                // Remove "Call started" message, just show Ready when appropriate
                if !vapiViewModel.isConnecting && !vapiViewModel.isUserSpeaking && !vapiViewModel.isAssistantSpeaking {
                    updateStatus("Ready")
                }
                HapticFeedbackManager.shared.playTransitionFeedback()
            } else {
                updateStatus("Ready")
                HapticFeedbackManager.shared.stopContinuousPattern()
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation {
                if statusMessage == message {
                    showStatusIndicator = false
                }
            }
        }
    }
}

// Rest of the code remains the same...
// Update the action button design for the minimal UI
struct EnhancedActionButtonView: View {
    let isCallActive: Bool
    let onStartTapped: () -> Void
    let onStopTapped: () -> Void
    
    @State private var isPressed = false
    @State private var animationScale: CGFloat = 1.0
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = false
                }
                if isCallActive {
                    onStopTapped()
                } else {
                    onStartTapped()
                }
            }
        }) {
            ZStack {
                // Outer glowing ring
                Circle()
                    .fill(isCallActive ? Color.red.opacity(0.3) : Color.blue.opacity(0.3))
                    .frame(width: 90, height: 90)
                    .blur(radius: 10)
                
                // Button background
                Circle()
                    .fill(
                        LinearGradient(
                            colors: isCallActive
                                ? [Color(hex: "FF3B30"), Color(hex: "D50000")]
                                : [Color(hex: "4F8EF7"), Color(hex: "0051D5")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 76, height: 76)
                    .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
                
                // Button icon
                if isCallActive {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white)
                        .frame(width: 24, height: 24)
                } else {
                    Image(systemName: "mic.fill")
                        .font(.system(size: 30, weight: .medium))
                        .foregroundColor(.white)
                }
                
                // Pulsing animation when active
                if isCallActive {
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 3)
                        .frame(width: 100, height: 100)
                        .scaleEffect(animationScale)
                        .opacity(2 - animationScale)
                        .onAppear {
                            withAnimation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: false)) {
                                animationScale = 1.5
                            }
                        }
                }
            }
            .scaleEffect(isPressed ? 0.92 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AuthenticationViewModel())
    }
}

struct LoadingIndicatorView: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.2), lineWidth: 5)
                .frame(width: 50, height: 50)
            
            Circle()
                .trim(from: 0, to: 0.7)
                .stroke(Color.white, lineWidth: 5)
                .frame(width: 50, height: 50)
                .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                .animation(
                    Animation.linear(duration: 1)
                        .repeatForever(autoreverses: false),
                    value: isAnimating
                )
                .onAppear {
                    isAnimating = true
                }
        }
    }
}
