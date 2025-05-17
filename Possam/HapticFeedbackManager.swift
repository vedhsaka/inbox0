//
//  HapticFeedbackManager.swift
//  Possam
//
//  Created by Akash Thakur on 4/26/25.
//
import CoreGraphics
import SwiftUI
import UIKit

class HapticFeedbackManager {
    static let shared = HapticFeedbackManager()
    
    private var impactGenerator: UIImpactFeedbackGenerator?
    private var selectionGenerator: UISelectionFeedbackGenerator?
    private var notificationGenerator: UINotificationFeedbackGenerator?
    private var continuousTimer: Timer?
    
    // User preferences
    var isHapticEnabled = true
    var hapticIntensity: CGFloat = 1.0 // 0.0-1.0
    
    init() {
        prepareGenerators()
    }
    
    func prepareGenerators() {
        impactGenerator = UIImpactFeedbackGenerator(style: .medium)
        selectionGenerator = UISelectionFeedbackGenerator()
        notificationGenerator = UINotificationFeedbackGenerator()
        
        impactGenerator?.prepare()
        selectionGenerator?.prepare()
        notificationGenerator?.prepare()
    }
    
    // MARK: - Interaction Feedback
    
    func playStartListeningFeedback() {
        guard isHapticEnabled else { return }
        impactGenerator?.impactOccurred(intensity: 0.5 * hapticIntensity)
    }
    
    func playStopListeningFeedback() {
        guard isHapticEnabled else { return }
        impactGenerator?.impactOccurred(intensity: 0.6 * hapticIntensity)
        
        // Add a slight delay for double-tap feel
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.impactGenerator?.impactOccurred(intensity: 0.3 * self.hapticIntensity)
        }
    }
    
    func playTransitionFeedback() {
        guard isHapticEnabled else { return }
        selectionGenerator?.selectionChanged()
    }
    
    func playSuccessFeedback() {
        guard isHapticEnabled else { return }
        notificationGenerator?.notificationOccurred(.success)
    }
    
    func playErrorFeedback() {
        guard isHapticEnabled else { return }
        notificationGenerator?.notificationOccurred(.error)
    }
    
    func playWarningFeedback() {
        guard isHapticEnabled else { return }
        notificationGenerator?.notificationOccurred(.warning)
    }
    
    // MARK: - Continuous Patterns
    
    func startSpeakingPattern(audioLevel: Double) {
        guard isHapticEnabled else { return }
        stopContinuousPattern()
        
        continuousTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            // Scale intensity based on audio level
            let intensity = min(1.0, max(0.3, audioLevel)) * self.hapticIntensity
            self.impactGenerator?.impactOccurred(intensity: intensity)
        }
    }
    
    func startThinkingPattern() {
        guard isHapticEnabled else { return }
        stopContinuousPattern()
        
        var counter = 0
        continuousTimer = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            // Create a gentle pulsing pattern
            if counter % 4 == 0 {
                // Every 4th pulse is stronger
                self.impactGenerator?.impactOccurred(intensity: 0.5 * self.hapticIntensity)
            } else {
                self.impactGenerator?.impactOccurred(intensity: 0.2 * self.hapticIntensity)
            }
            
            counter += 1
        }
    }
    
    func startListeningPattern(audioLevel: Double) {
        guard isHapticEnabled else { return }
        stopContinuousPattern()
        
        continuousTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            // Only trigger haptic when audio level is significant
            if audioLevel > 0.4 {
                let intensity = min(1.0, max(0.3, audioLevel)) * self.hapticIntensity
                self.impactGenerator?.impactOccurred(intensity: intensity)
            }
        }
    }
    
    func stopContinuousPattern() {
        continuousTimer?.invalidate()
        continuousTimer = nil
    }
    
    // MARK: - Contextual Patterns
    
    func playInformationalResponse() {
        guard isHapticEnabled else { return }
        
        // Subtle triple-tap pattern
        impactGenerator?.impactOccurred(intensity: 0.4 * hapticIntensity)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.impactGenerator?.impactOccurred(intensity: 0.3 * self.hapticIntensity)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.impactGenerator?.impactOccurred(intensity: 0.2 * self.hapticIntensity)
            }
        }
    }
    
    func playActionConfirmation() {
        guard isHapticEnabled else { return }
        
        // Strong-light pattern
        impactGenerator?.impactOccurred(intensity: 0.8 * hapticIntensity)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.impactGenerator?.impactOccurred(intensity: 0.3 * self.hapticIntensity)
        }
    }
}
