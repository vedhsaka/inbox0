//
//  VapiViewModel.swift
//  Possam
//
//  Created by Akash Thakur on 4/20/25.
//

import SwiftUI
import Vapi
import Combine
import AVFoundation

class VapiViewModel: ObservableObject {
    // Vapi instance
    private var vapi: Vapi?
    private var cancellables = Set<AnyCancellable>()
    private var audioLevelTimer: AnyCancellable?
    private var feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    
    // UI state
    @Published var isCallActive: Bool = false
    @Published var isUserSpeaking: Bool = false
    @Published var isAssistantSpeaking: Bool = false
    @Published var userAudioLevel: Double = 0.1
    @Published var assistantAudioLevel: Double = 0.1
    @Published var messages: [ChatMessage] = []
    @Published var isConnecting: Bool = false
    @Published var isReady: Bool = false
    
    init() {
        setupAudioLevelSimulation()
        
        // Add welcome message
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.addSystemMessage("Welcome to Voice Assistant. Tap the microphone to start a conversation.")
        }
        
        setupVapiInstance()
    }
    
    private func setupVapiInstance() {
        // Create Vapi instance ahead of time
        vapi = Vapi(publicKey: "59748f0c-7adf-48fc-a160-3e98c308426b")
        
        // Set up event subscriptions
        setupEventPublisher()
    }
    

    private func setupAudioLevelSimulation() {
        audioLevelTimer = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                
                if self.isUserSpeaking {
                    self.userAudioLevel = Double.random(in: 0.3...0.9)
                } else {
                    self.userAudioLevel = 0.1
                }
                
                if self.isAssistantSpeaking {
                    self.assistantAudioLevel = Double.random(in: 0.3...0.9)
                } else {
                    self.assistantAudioLevel = 0.1
                }
            }
    }
    
    // Prevent screen from sleeping while the assistant is active
    private func preventScreenSleep() {
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    // Allow screen to sleep when assistant is inactive
    private func allowScreenSleep() {
        UIApplication.shared.isIdleTimerDisabled = false
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
        
        feedbackGenerator.prepare()
        feedbackGenerator.impactOccurred()
        
        // Prevent screen from sleeping
        preventScreenSleep()
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            isCallActive = true
        }

        // Ensure the audio session is active
        activateAudioSession()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            // After 3 seconds, transition from "Connecting" to "Ready"
            withAnimation {
                self.isConnecting = false
                self.isReady = true
                self.isCallActive = true // Now turn the mic red
            }
            
            // Add the ready message
            self.addSystemMessage("Ready")
        }
        
        // Start the assistant with the existing instance
        Task {
            do {
                try await vapi?.start(
                  assistantId: "33c3ecd4-7808-45be-9935-fc23876a1ac8",
                  metadata: [:] // Empty metadata since we don't need the tokens
                )
            } catch {
                DispatchQueue.main.async {
                    self.addErrorMessage("Error: \(error.localizedDescription)")
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
                    self.addUserMessage(transcript.transcript)
                    self.triggerHapticFeedback(.light)
                    
                    // Show user speaking animation
                    withAnimation(.easeInOut(duration: 0.2)) {
                        self.isUserSpeaking = true
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            self.isUserSpeaking = false
                        }
                    }
                    
                case .voiceInput(let voiceInput):
                    // Intermediate assistant response
                    self.addAssistantProcessingMessage(voiceInput.input)
                    
                case .modelOutput(let output):
                    // Final assistant response
                    self.addAssistantMessage(output.output)
                    self.triggerHapticFeedback(.medium)
                    
                case .statusUpdate(let status):
                    self.addStatusMessage(status.status)
                    
                case .speechUpdate(let update):
                    // Handle speech start/end for assistant
                    switch update.status {
                    case .started:
                        withAnimation(.easeInOut(duration: 0.2)) {
                            self.isAssistantSpeaking = true
                        }
                        HapticFeedbackManager.shared.startSpeakingPattern(audioLevel: self.assistantAudioLevel)
                    case .stopped:
                        withAnimation(.easeInOut(duration: 0.2)) {
                            self.isAssistantSpeaking = false
                        }
                        HapticFeedbackManager.shared.stopContinuousPattern()
                    @unknown default:
                        break
                    }
                    
                case .callDidStart:
                    self.addSystemMessage("Call started")
                    
                case .callDidEnd:
                    withAnimation {
                        self.isCallActive = false
                        self.isUserSpeaking = false
                        self.isAssistantSpeaking = false
                    }
                    self.addSystemMessage("Call ended")
                    
                default:
                    // Handle other events as needed
                    break
                }
            }
            .store(in: &cancellables)
    }
    
    func stopAssistant() {
        feedbackGenerator.impactOccurred(intensity: 0.7)
        isConnecting = false
        isReady = false
        
        // Allow screen to sleep again
        allowScreenSleep()
        
        Task {
            do {
                try await vapi?.stop()
                DispatchQueue.main.async {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        self.isCallActive = false
                        self.isUserSpeaking = false
                        self.isAssistantSpeaking = false
                    }
                    self.addSystemMessage("Assistant stopped")
                }
            } catch {
                DispatchQueue.main.async {
                    self.addErrorMessage("Error stopping assistant: \(error.localizedDescription)")
                }
            }
        }
        
        // Clear subscriptions
        cancellables.removeAll()
    }
    
    // MARK: - Message Handling
    
    private func addUserMessage(_ text: String) {
        let message = ChatMessage(text: text, type: .user, timestamp: Date())
        withAnimation {
            messages.append(message)
        }
    }
    
    private func addAssistantMessage(_ text: String) {
        // Find and remove any processing message
        if let index = messages.firstIndex(where: { $0.type == .assistantProcessing }) {
            withAnimation {
                messages.remove(at: index)
            }
        }
        
        let message = ChatMessage(text: text, type: .assistant, timestamp: Date())
        withAnimation {
            messages.append(message)
        }
    }
    
    private func addAssistantProcessingMessage(_ text: String) {
        // Only add if there isn't already a processing message
        if !messages.contains(where: { $0.type == .assistantProcessing }) {
            let message = ChatMessage(text: text, type: .assistantProcessing, timestamp: Date())
            withAnimation {
                messages.append(message)
            }
        }
    }
    
    private func addStatusMessage(_ text: String) {
        let message = ChatMessage(text: text, type: .status, timestamp: Date())
        withAnimation {
            messages.append(message)
        }
    }
    
    private func addSystemMessage(_ text: String) {
        let message = ChatMessage(text: text, type: .system, timestamp: Date())
        withAnimation {
            messages.append(message)
        }
    }
    
    private func addErrorMessage(_ text: String) {
        let message = ChatMessage(text: text, type: .error, timestamp: Date())
        withAnimation {
            messages.append(message)
        }
    }
    
    // MARK: - Haptic Feedback
    
    private func triggerHapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
}
