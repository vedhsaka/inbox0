//
//  ParticleSystem.swift
//  Possam
//
//  Created by Akash Thakur on 4/26/25.
//
import UIKit
import SwiftUI

struct ParticleSystem: View {
    let isUserSpeaking: Bool
    let isAssistantSpeaking: Bool
    let isAssistantThinking: Bool
    let audioLevel: Double
    
    // Particle system configuration
    @State private var particles: [Particle] = []
    @State private var timer: Timer? = nil
    @State private var currentMode: VisualizationMode = .idle
    
    private let particleCount = 150
    
    enum VisualizationMode {
        case idle, userSpeaking, assistantThinking, assistantSpeaking
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background gradient based on state
                backgroundGradient
                    .animation(.easeInOut(duration: 0.8), value: currentMode)
                
                // Particle canvas
                Canvas { context, size in
                    for particle in particles {
                        // Create a circle path for each particle
                        let path = Path(ellipseIn: CGRect(
                            x: particle.position.x - particle.size/2,
                            y: particle.position.y - particle.size/2,
                            width: particle.size,
                            height: particle.size
                        ))
                        
                        // Fill the path with the particle's color
                        context.fill(
                            path,
                            with: .color(particle.color.opacity(particle.opacity)),
                            style: FillStyle(eoFill: false)
                        )
                        
                        // Add a blur effect
                        context.addFilter(.blur(radius: 2))
                    }
                }
            }
            .onAppear {
                // Initialize particles
                initializeParticles(in: geometry.size)
                startAnimation()
            }
            .onChange(of: geometry.size) { newSize in
                resetParticles(in: newSize)
            }
            .onChange(of: isUserSpeaking) { isSpeaking in
                updateVisualizationMode()
            }
            .onChange(of: isAssistantSpeaking) { isSpeaking in
                updateVisualizationMode()
            }
            .onChange(of: isAssistantThinking) { isThinking in
                updateVisualizationMode()
            }
            .onChange(of: audioLevel) { level in
                updateParticleEnergy(level)
            }
        }
    }
    
    private var backgroundGradient: LinearGradient {
        switch currentMode {
        case .idle:
            return LinearGradient(
                colors: [Color(hex: "1A1A2E"), Color(hex: "16213E")],
                startPoint: .top,
                endPoint: .bottom
            )
        case .userSpeaking:
            return LinearGradient(
                colors: [Color(hex: "173B5E"), Color(hex: "1D566E")],
                startPoint: .bottom,
                endPoint: .top
            )
        case .assistantThinking:
            return LinearGradient(
                colors: [Color(hex: "322C4A"), Color(hex: "483B66")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .assistantSpeaking:
            return LinearGradient(
                colors: [Color(hex: "1D4437"), Color(hex: "2D6E42")],
                startPoint: .center,
                endPoint: .bottomTrailing
            )
        }
    }
    
    private func updateVisualizationMode() {
        // Determine the current mode based on state
        if isUserSpeaking {
            currentMode = .userSpeaking
        } else if isAssistantThinking {
            currentMode = .assistantThinking
        } else if isAssistantSpeaking {
            currentMode = .assistantSpeaking
        } else {
            currentMode = .idle
        }
    }
    
    private func initializeParticles(in size: CGSize) {
        particles = (0..<particleCount).map { _ in
            createRandomParticle(in: size)
        }
    }
    
    private func createRandomParticle(in size: CGSize) -> Particle {
        Particle(
            position: CGPoint(
                x: CGFloat.random(in: 0...size.width),
                y: CGFloat.random(in: 0...size.height)
            ),
            velocity: CGVector(
                dx: CGFloat.random(in: -1...1),
                dy: CGFloat.random(in: -1...1)
            ),
            size: CGFloat.random(in: 5...15),
            color: particleColor(for: currentMode),
            opacity: CGFloat.random(in: 0.3...0.8),
            depth: CGFloat.random(in: 0.1...1.0)
        )
    }
    
    private func particleColor(for mode: VisualizationMode) -> Color {
        switch mode {
        case .idle:
            return [Color(hex: "4DA8DA"), Color(hex: "5E7CE2"), Color(hex: "7B68EE")].randomElement()!
        case .userSpeaking:
            return [Color(hex: "03A9F4"), Color(hex: "00BCD4"), Color(hex: "4FC3F7")].randomElement()!
        case .assistantThinking:
            return [Color(hex: "9C27B0"), Color(hex: "7E57C2"), Color(hex: "B39DDB")].randomElement()!
        case .assistantSpeaking:
            return [Color(hex: "4CAF50"), Color(hex: "8BC34A"), Color(hex: "CDDC39")].randomElement()!
        }
    }
    
    private func resetParticles(in size: CGSize) {
        particles = particles.map { particle in
            var newParticle = particle
            newParticle.position = CGPoint(
                x: min(particle.position.x, size.width),
                y: min(particle.position.y, size.height)
            )
            return newParticle
        }
    }
    
    private func updateParticleEnergy(_ level: Double) {
        let energyFactor = 0.5 + level * 3.0
        
        for i in 0..<particles.count {
            particles[i].energy = energyFactor * particles[i].depth
        }
    }
    
    private func startAnimation() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
            updateParticles()
        }
    }
    
    private func updateParticles() {
        for i in 0..<particles.count {
            var particle = particles[i]
            
            // Different movement patterns based on mode
            switch currentMode {
            case .idle:
                applyIdleAnimation(to: &particle)
            case .userSpeaking:
                applyUserSpeakingAnimation(to: &particle, index: i)
            case .assistantThinking:
                applyAssistantThinkingAnimation(to: &particle, index: i)
            case .assistantSpeaking:
                applyAssistantSpeakingAnimation(to: &particle, index: i)
            }
            
            // Apply physics
            particle.position.x += particle.velocity.dx * particle.energy
            particle.position.y += particle.velocity.dy * particle.energy
            
            // Apply boundaries with bounce
            if particle.position.x < 0 || particle.position.x > UIScreen.main.bounds.width {
                particle.velocity.dx *= -0.8
            }
            if particle.position.y < 0 || particle.position.y > UIScreen.main.bounds.height {
                particle.velocity.dy *= -0.8
            }
            
            // Dampening
            particle.velocity.dx *= 0.99
            particle.velocity.dy *= 0.99
            
            // Apply gravity (subtle)
            particle.velocity.dy += 0.01 * particle.size / 10
            
            // Randomize a bit for natural movement
            if Int.random(in: 0...100) == 0 {
                particle.velocity.dx += CGFloat.random(in: -0.2...0.2)
                particle.velocity.dy += CGFloat.random(in: -0.2...0.2)
            }
            
            particles[i] = particle
        }
    }
    
    private func applyIdleAnimation(to particle: inout Particle) {
        // Gentle floating effect
        let time = Date().timeIntervalSince1970
        let xWave = sin(time * 0.5 + Double(particle.id.hashValue) * 0.1) * 0.2
        let yWave = cos(time * 0.5 + Double(particle.id.hashValue) * 0.1) * 0.2
        
        particle.velocity.dx += CGFloat(xWave) * particle.depth
        particle.velocity.dy += CGFloat(yWave) * particle.depth
    }
    
    private func applyUserSpeakingAnimation(to particle: inout Particle, index: Int) {
        // Upward flowing wave pattern
        let time = Date().timeIntervalSince1970
        let xFactor = sin(time * 2 + Double(index) * 0.1) * 0.3
        
        particle.velocity.dx += CGFloat(xFactor) * particle.energy
        particle.velocity.dy -= (0.1 + particle.energy * 0.2) * particle.depth
        
        // Reset particles that flow off the top
        if particle.position.y < -particle.size {
            particle.position.y = UIScreen.main.bounds.height + particle.size
            particle.position.x = CGFloat.random(in: 0...UIScreen.main.bounds.width)
        }
    }
    
    private func applyAssistantThinkingAnimation(to particle: inout Particle, index: Int) {
        // Circular rotation pattern
        let time = Date().timeIntervalSince1970
        let centerX = UIScreen.main.bounds.width / 2
        let centerY = UIScreen.main.bounds.height / 2
        
        let dx = particle.position.x - centerX
        let dy = particle.position.y - centerY
        let distance = sqrt(dx*dx + dy*dy)
        
        if distance > 10 {
            // Calculate angle to create circular motion
            let angle = atan2(dy, dx)
            let rotationSpeed = 0.3 * particle.energy * (1.0 - particle.depth * 0.5)
            
            // Perpendicular vector for circular motion
            particle.velocity.dx = -sin(angle) * rotationSpeed
            particle.velocity.dy = cos(angle) * rotationSpeed
            
            // Add slight inward/outward pulsing
            let pulseRate = sin(time * 1.5 + Double(index) * 0.05) * 0.05
            particle.velocity.dx += dx / distance * CGFloat(pulseRate)
            particle.velocity.dy += dy / distance * CGFloat(pulseRate)
        }
    }
    
    private func applyAssistantSpeakingAnimation(to particle: inout Particle, index: Int) {
        // Outward pulsing pattern
        let time = Date().timeIntervalSince1970
        let centerX = UIScreen.main.bounds.width / 2
        let centerY = UIScreen.main.bounds.height / 2
        
        let dx = particle.position.x - centerX
        let dy = particle.position.y - centerY
        let distance = sqrt(dx*dx + dy*dy)
        
        // Pulsing outward effect timed with speech
        let pulseRate = sin(time * 5 * particle.energy + Double(index) * 0.1) * 0.2
        
        if distance > 5 {
            // Move outward or inward based on pulse
            particle.velocity.dx += dx / distance * CGFloat(pulseRate) * particle.energy
            particle.velocity.dy += dy / distance * CGFloat(pulseRate) * particle.energy
        }
        
        // Add some wave-like motion
        let waveFactor = sin(time * 3 + Double(particle.position.y) * 0.01) * 0.1
        particle.velocity.dx += CGFloat(waveFactor) * particle.depth
    }
}

// Particle model
struct Particle: Identifiable {
    let id = UUID()
    var position: CGPoint
    var velocity: CGVector
    var size: CGFloat
    var color: Color
    var opacity: CGFloat
    var depth: CGFloat  // 0.1-1.0 for parallax effect
    var energy: CGFloat = 1.0
}
