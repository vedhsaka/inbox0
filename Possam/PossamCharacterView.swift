//
//  PossamCharacterView.swift
//  Possam
//
//  Created by Akash Thakur on 4/26/25.
//

import SwiftUI
import Combine

struct PossamCharacterView: View {
    let isUserSpeaking: Bool
    let isAssistantSpeaking: Bool
    let isAssistantThinking: Bool
    
    // Animation state
    @State private var eyeState: EyeState = .normal
    @State private var earAngle: Double = 0
    @State private var mouthOpenness: CGFloat = 0
    @State private var headRotation: Double = 0
    @State private var isBlinking: Bool = false
    @State private var thinkingEmojis: [ThinkingEmoji] = []
    @State private var characterOffset: CGSize = .zero
    @State private var animationScale: CGFloat = 1.0
    
    // Timers for animations
    @State private var blinkTimer: Timer? = nil
    @State private var idleTimer: Timer? = nil
    @State private var talkTimer: Timer? = nil
    @State private var thinkingTimer: Timer? = nil
    
    // Character constants
    private let characterSize: CGFloat = 180
    private let characterBaseYOffset: CGFloat = -80 // Position above the mic button
    
    enum EyeState {
        case normal, closed, surprised, happy
    }
    
    struct ThinkingEmoji: Identifiable {
        let id = UUID()
        var emoji: String
        var position: CGPoint
        var rotation: Double
        var scale: CGFloat
        var opacity: CGFloat
    }
    
    var body: some View {
        ZStack {
            // Character body
            character
                .offset(characterOffset)
                .offset(y: characterBaseYOffset)
                .shadow(color: Color.black.opacity(0.2), radius: 15, x: 0, y: 10)
            
            // Thinking emoji bubbles
            if isAssistantThinking {
                ForEach(thinkingEmojis) { emoji in
                    Text(emoji.emoji)
                        .font(.system(size: 20 * emoji.scale))
                        .rotationEffect(.degrees(emoji.rotation))
                        .position(emoji.position)
                        .opacity(emoji.opacity)
                        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 2)
                }
            }
            
            // Optional: Add listening waves when user is speaking
            if isUserSpeaking {
                ZStack {
                    ForEach(0..<3) { i in
                        Circle()
                            .stroke(Color.userIcon.opacity(0.2), lineWidth: 3)
                            .frame(width: 200 + CGFloat(i * 30), height: 200 + CGFloat(i * 30))
                            .scaleEffect(animationScale)
                            .opacity(2 - animationScale)
                    }
                }
                .offset(y: characterBaseYOffset)
            }
        }
        .onAppear {
            startBlinkTimer()
            startIdleTimer()
            
            // Add continuous wave animation
            withAnimation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: false)) {
                animationScale = 1.5
            }
        }
        .onChange(of: isUserSpeaking) { isSpeaking in
            updateAnimation()
        }
        .onChange(of: isAssistantSpeaking) { isSpeaking in
            updateAnimation()
        }
        .onChange(of: isAssistantThinking) { isThinking in
            updateAnimation()
        }
    }
    
    // Character composite view
    private var character: some View {
        ZStack {
            // Glow effect
            Circle()
                .fill(
                    isAssistantSpeaking ? Color.appAccent.opacity(0.3) :
                    isUserSpeaking ? Color.userIcon.opacity(0.3) :
                    isAssistantThinking ? Color.purple.opacity(0.2) :
                    Color.clear
                )
                .frame(width: characterSize * 1.4, height: characterSize * 1.4)
                .blur(radius: 20)
                .scaleEffect(isAssistantSpeaking || isUserSpeaking ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isAssistantSpeaking)
            
            // Head/body
            ZStack {
                // Base body
                Circle()
                    .fill(LinearGradient(
                        colors: [Color.appAccent.opacity(0.8), Color.appAccent],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                
                // Highlight
                Circle()
                    .fill(RadialGradient(
                        gradient: Gradient(colors: [Color.white.opacity(0.5), Color.clear]),
                        center: .topLeading,
                        startRadius: 5,
                        endRadius: characterSize * 0.8
                    ))
                    .mask(
                        Circle()
                            .frame(width: characterSize, height: characterSize)
                    )
            }
            .frame(width: characterSize, height: characterSize)
            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
            .rotationEffect(.degrees(headRotation))
            
            // Ears
            Group {
                // Left ear
                ZStack {
                    // Base ear
                    Capsule()
                        .fill(Color.appAccent)
                        .frame(width: 30, height: 60)
                    
                    // Inner ear
                    Capsule()
                        .fill(Color.appAccent.opacity(0.7))
                        .frame(width: 15, height: 40)
                        .offset(x: 2, y: -3)
                }
                .offset(x: -50, y: -40)
                .rotationEffect(.degrees(-15 + earAngle), anchor: .bottom)
                
                // Right ear
                ZStack {
                    // Base ear
                    Capsule()
                        .fill(Color.appAccent)
                        .frame(width: 30, height: 60)
                    
                    // Inner ear
                    Capsule()
                        .fill(Color.appAccent.opacity(0.7))
                        .frame(width: 15, height: 40)
                        .offset(x: -2, y: -3)
                }
                .offset(x: 50, y: -40)
                .rotationEffect(.degrees(15 - earAngle), anchor: .bottom)
            }
            .rotationEffect(.degrees(headRotation))
            
            // Face
            Group {
                // Eyes
                HStack(spacing: 50) {
                    eye
                    eye
                }
                .offset(y: -20)
                
                // Mouth
                mouth
                    .offset(y: 30)
            }
            .rotationEffect(.degrees(headRotation))
        }
    }
    
    // Eye view based on current state
    private var eye: some View {
        Group {
            if isBlinking || eyeState == .closed {
                // Closed eye
                Rectangle()
                    .fill(Color.white)
                    .frame(width: 30, height: 4)
                    .cornerRadius(2)
            } else if eyeState == .surprised {
                // Surprised eye
                ZStack {
                    // White part
                    Circle()
                        .fill(Color.white)
                        .frame(width: 30, height: 30)
                    
                    // Pupil
                    Circle()
                        .fill(Color.black)
                        .frame(width: 12, height: 12)
                    
                    // Highlight
                    Circle()
                        .fill(Color.white.opacity(0.7))
                        .frame(width: 6, height: 6)
                        .offset(x: -2, y: -2)
                }
            } else if eyeState == .happy {
                // Happy eye (upside-down U)
                ZStack {
                    Circle()
                        .trim(from: 0, to: 0.5)
                        .stroke(Color.white, lineWidth: 4)
                        .frame(width: 30, height: 30)
                        .rotationEffect(.degrees(180))
                }
            } else {
                // Normal eye
                ZStack {
                    // White part
                    Circle()
                        .fill(Color.white)
                        .frame(width: 30, height: 30)
                    
                    // Pupil
                    Circle()
                        .fill(Color.black)
                        .frame(width: 15, height: 15)
                        .offset(
                            x: isUserSpeaking ? 3 : (isAssistantThinking ? sin(Date().timeIntervalSince1970 * 2) * 5 : 0),
                            y: isUserSpeaking ? -3 : 0
                        )
                    
                    // Highlight
                    Circle()
                        .fill(Color.white.opacity(0.7))
                        .frame(width: 6, height: 6)
                        .offset(x: -2, y: -2)
                }
            }
        }
    }
    
    // Mouth view based on the talking state
    private var mouth: some View {
        Group {
            if isAssistantSpeaking {
                // Talking mouth
                ZStack {
                    // Outer mouth
                    Capsule()
                        .fill(Color.white)
                        .frame(width: 60, height: 20 + mouthOpenness * 20)
                    
                    // Inner mouth details
                    Capsule()
                        .fill(Color.black.opacity(0.6))
                        .frame(width: 40, height: 10 + mouthOpenness * 15)
                    
                    // Tongue visible when wide open
                    if mouthOpenness > 0.6 {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.red.opacity(0.8))
                            .frame(width: 20, height: 10)
                            .offset(y: 5)
                            .opacity(mouthOpenness - 0.6)
                    }
                }
            } else if isAssistantThinking {
                // Thinking mouth (small o)
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 20, height: 20)
                    
                    Circle()
                        .fill(Color.black.opacity(0.5))
                        .frame(width: 12, height: 12)
                }
            } else {
                // Normal smile
                ZStack {
                    Circle()
                        .trim(from: 0, to: 0.5)
                        .stroke(Color.white, lineWidth: 4)
                        .frame(width: 60, height: 60)
                    
                    // Little shine on the smile
                    Circle()
                        .trim(from: 0.1, to: 0.4)
                        .stroke(Color.white.opacity(0.7), lineWidth: 2)
                        .frame(width: 50, height: 50)
                }
            }
        }
    }
                
    
    // Start animation timers based on current state
    private func updateAnimation() {
        // Clear existing timers
        talkTimer?.invalidate()
        thinkingTimer?.invalidate()
        
        if isUserSpeaking {
            // Listening animation
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                earAngle = 30  // Ears perk up
                eyeState = .normal
                headRotation = 0
            }
        } else if isAssistantSpeaking {
            // Talking animation
            startTalkingAnimation()
            
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                earAngle = 10
                eyeState = .happy
                headRotation = 0
            }
        } else if isAssistantThinking {
            // Thinking animation
            startThinkingAnimation()
            
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                earAngle = 15
                eyeState = .normal
                headRotation = 5 * sin(Date().timeIntervalSince1970)
            }
        } else {
            // Idle animation
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                earAngle = 0
                eyeState = .normal
                mouthOpenness = 0
                headRotation = 0
            }
        }
    }
    
    // Blinking animation
    private func startBlinkTimer() {
        blinkTimer?.invalidate()
        blinkTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            if !isAssistantThinking && !isAssistantSpeaking && !isUserSpeaking {
                // Only blink during idle
                withAnimation(.easeInOut(duration: 0.15)) {
                    isBlinking = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        isBlinking = false
                    }
                }
            }
        }
    }
    
    // Idle movement animation
    private func startIdleTimer() {
        idleTimer?.invalidate()
        idleTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            if !isAssistantThinking && !isAssistantSpeaking && !isUserSpeaking {
                // Random idle movements
                withAnimation(.easeInOut(duration: 1.5)) {
                    characterOffset = CGSize(
                        width: CGFloat.random(in: -10...10),
                        height: CGFloat.random(in: -5...5)
                    )
                    headRotation = Double.random(in: -5...5)
                }
            }
        }
    }
    
    // Talking animation
    private func startTalkingAnimation() {
        talkTimer?.invalidate()
        talkTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.2)) {
                mouthOpenness = CGFloat.random(in: 0.2...1.0)
                headRotation = Double.random(in: -3...3)
            }
        }
    }
    
    // Thinking animation with emoji bubbles
    private func startThinkingAnimation() {
        // Clear existing thinking emojis
        thinkingEmojis = []
        
        // Set up timer to create new thinking emojis
        thinkingTimer?.invalidate()
        thinkingTimer = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: true) { _ in
            if thinkingEmojis.count >= 5 {
                // Remove oldest emoji
                thinkingEmojis.removeFirst()
            }
            
            // Add new emoji - position it to create a spiral path above character's head
            let emojiIndex = thinkingEmojis.count
            let angle = Double(emojiIndex) * .pi * 0.5
            let distance = 50.0 + Double(emojiIndex) * 15.0
            
            // Calculate position based on spiral pattern
            let xPos = sin(angle) * distance
            let yPos = -cos(angle) * distance - 60.0 // Offset up from character's center
            
            let newEmoji = ThinkingEmoji(
                emoji: ["💭", "🤔", "⚙️", "✨", "💡", "🔍", "🧠"].randomElement()!,
                position: CGPoint(
                    x: xPos,
                    y: characterBaseYOffset + yPos
                ),
                rotation: Double.random(in: -30...30),
                scale: CGFloat.random(in: 0.8...1.2),
                opacity: 0
            )
            
            thinkingEmojis.append(newEmoji)
            
            // Animate the emoji rising and fading
            let currentEmojiIndex = thinkingEmojis.count - 1
            
            withAnimation(.easeIn(duration: 0.5)) {
                thinkingEmojis[currentEmojiIndex].opacity = 1.0
            }
            
            withAnimation(.easeInOut(duration: 2.0)) {
                // Move along the spiral path
                let finalAngle = angle + .pi * 0.3
                let finalDistance = distance + 30.0
                
                let finalX = sin(finalAngle) * finalDistance
                let finalY = -cos(finalAngle) * finalDistance - 70.0
                
                thinkingEmojis[currentEmojiIndex].position = CGPoint(
                    x: finalX,
                    y: characterBaseYOffset + finalY
                )
                
                // Also add some rotation
                thinkingEmojis[currentEmojiIndex].rotation += Double.random(in: -45...45)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                if currentEmojiIndex < thinkingEmojis.count {
                    withAnimation(.easeOut(duration: 0.5)) {
                        thinkingEmojis[currentEmojiIndex].opacity = 0
                    }
                }
            }
        }
    }
}
