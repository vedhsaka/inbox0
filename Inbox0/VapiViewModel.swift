import SwiftUI
import Combine
import AVFoundation
import Vapi

class VapiViewModel: ObservableObject {
    // Vapi instance
    private var vapi: Vapi?
    private var cancellables = Set<AnyCancellable>()
    private var audioLevelTimer: AnyCancellable?
    
    // UI state
    @Published var isCallActive: Bool = false
    @Published var isUserSpeaking: Bool = false
    @Published var isAssistantSpeaking: Bool = false
    @Published var userAudioLevel: Double = 0.1
    @Published var assistantAudioLevel: Double = 0.1
    @Published var isConnecting: Bool = false
    @Published var isReady: Bool = false
    
    // In VapiViewModel.swift, update the init() function
    init() {
        setupAudioLevelSimulation()
        setupVapiInstance()
        
        // Set up a timer to auto-reconnect if the connection drops
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if !self.isCallActive && !self.isConnecting && UIApplication.shared.applicationState == .active {
                print("Auto-reconnecting Vapi assistant")
                self.startAssistant()
            }
        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAppBecomeActive),
            name: Notification.Name("AppDidBecomeActive"),
            object: nil
        )
    }
    
    private func setupVapiInstance() {
        // Create Vapi instance ahead of time
        vapi = Vapi(publicKey: "Public key")
        
        // Set up event subscriptions
        setupEventPublisher()
    }
    
    private func setupAudioLevelSimulation() {
        audioLevelTimer = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                
                if self.isUserSpeaking {
                    // Smoother audio level simulation for user speaking
                    let previousLevel = self.userAudioLevel
                    let targetLevel = Double.random(in: 0.5...0.95)
                    let smoothFactor = 0.3 // Smoothing factor
                    self.userAudioLevel = previousLevel * (1 - smoothFactor) + targetLevel * smoothFactor
                } else {
                    self.userAudioLevel = 0.1
                }
                
                if self.isAssistantSpeaking {
                    // Smoother audio level simulation for assistant speaking
                    let previousLevel = self.assistantAudioLevel
                    let targetLevel = Double.random(in: 0.5...0.95)
                    let smoothFactor = 0.3 // Smoothing factor
                    self.assistantAudioLevel = previousLevel * (1 - smoothFactor) + targetLevel * smoothFactor
                } else {
                    self.assistantAudioLevel = 0.1
                }
            }
    }
    
    // Ensure audio session remains active
    private func activateAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Failed to activate audio session: \(error.localizedDescription)")
        }
    }
    
    func startAssistant() {
        isReady = false
        isConnecting = true
        
        // Prevent screen from sleeping
        UIApplication.shared.isIdleTimerDisabled = true
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            isCallActive = true
        }

        // Ensure the audio session is active
        activateAudioSession()
        
        // Add a realistic delay for premium feel
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                self.isConnecting = false
                self.isReady = true
            }
        }
        
        // Start the assistant with the existing instance
        Task {
            do {
                try await vapi?.start(
                  assistantId: "85e3d8f8-5467-48ec-a8b9-8fc401947e3d",
                  metadata: [:]
                )
            } catch {
                DispatchQueue.main.async {
                    self.isConnecting = false
                    withAnimation {
                        self.isCallActive = false
                    }
                }
            }
        }
    }

    // Make sure your setupEventPublisher method has all the event handling:
    private func setupEventPublisher() {
        vapi?.eventPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                guard let self = self else { return }
                
                switch event {
                case .transcript(let transcript):
                    // Show user speaking animation
                    withAnimation(.easeIn(duration: 0.2)) {
                        self.isUserSpeaking = true
                    }
                    
                    // Add a natural delay before ending user speaking state
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        withAnimation(.easeOut(duration: 0.5)) {
                            self.isUserSpeaking = false
                        }
                    }
                    
                case .speechUpdate(let update):
                    // Handle speech start/end for assistant
                    switch update.status {
                    case .started:
                        withAnimation(.easeIn(duration: 0.3)) {
                            self.isAssistantSpeaking = true
                        }
                    case .stopped:
                        withAnimation(.easeOut(duration: 0.5)) {
                            self.isAssistantSpeaking = false
                        }
                    @unknown default:
                        break
                    }
                    
                case .callDidStart:
                    print("Call started")
                    
                case .callDidEnd:
                    withAnimation(.easeOut(duration: 0.3)) {
                        self.isCallActive = false
                        self.isUserSpeaking = false
                        self.isAssistantSpeaking = false
                    }
                    
                default:
                    // Handle other events as needed
                    break
                }
            }
            .store(in: &cancellables)
    }
    
    func stopAssistant() {
        isConnecting = false
        isReady = false
        
        // Allow screen to sleep again
        UIApplication.shared.isIdleTimerDisabled = false
        
        Task {
            do {
                try await vapi?.stop()
                DispatchQueue.main.async {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        self.isCallActive = false
                        self.isUserSpeaking = false
                        self.isAssistantSpeaking = false
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    withAnimation {
                        self.isCallActive = false
                    }
                }
            }
        }
    }
    
    @objc private func handleAppBecomeActive() {
        if !isCallActive && !isConnecting {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.startAssistant()
            }
        }
    }
}
