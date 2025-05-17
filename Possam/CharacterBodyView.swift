//
//  CharacterBodyView.swift
//  Possam
//
//  Created by Akash Thakur on 4/26/25.
//


import SwiftUI

// MARK: - Character Body View
struct CharacterBodyView: View {
    let characterSize: CGFloat
    let isUserSpeaking: Bool
    let isAssistantSpeaking: Bool
    let isAssistantThinking: Bool
    let eyeState: PossamCharacterView.EyeState
    let isBlinking: Bool
    let earAngle: Double
    let mouthOpenness: CGFloat
    let headBob: Double
    let frontLeftLegRaised: Bool
    let frontRightLegRaised: Bool
    let backLeftLegRaised: Bool
    let backRightLegRaised: Bool
    let tailWag: CGFloat
    let bobAmount: CGFloat
    let moveDirection: CGFloat
    let footPhase: CGFloat
    
    var body: some View {
        ZStack {
            // Glow effect
            glowEffect
            
            // Main character structure
            characterStructure
                .scaleEffect(1.0 + bobAmount * 0.02)  // Slight scale with bobbing
                .rotationEffect(.degrees(moveDirection > 0 ? 0 : 180))  // Flip based on movement direction
                .offset(y: bobAmount)  // Vertical bounce
        }
    }
    
    // Glow effect based on state
    private var glowEffect: some View {
        Circle()
            .fill(
                isAssistantSpeaking ? Color.appAccent.opacity(0.3) :
                isUserSpeaking ? Color.userIcon.opacity(0.3) :
                isAssistantThinking ? Color.purple.opacity(0.2) :
                Color.clear
            )
            .frame(width: characterSize * 1.3, height: characterSize * 1.3)
            .blur(radius: 15)
            .scaleEffect(isAssistantSpeaking || isUserSpeaking ? 1.1 : 1.0)
            .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isAssistantSpeaking)
    }
    
    // Main character structure split into components
    private var characterStructure: some View {
        ZStack {
            // Main body components
            bodyComponents
                
            // Head components
            headComponents
                
            // Leg components
            legComponents
        }
    }
    
    // Body components including main body and tail
    private var bodyComponents: some View {
        ZStack {
            // Main body oval and fur
            bodyShape
            
            // Tail (behind body)
            tailShape
        }
    }
    
    // Main body shape
    private var bodyShape: some View {
        ZStack {
            // Main body oval
            Ellipse()
                .fill(Color.white)
                .frame(width: characterSize, height: characterSize * 0.6)
                .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
            
            // Back fur tuft
            Ellipse()
                .fill(Color.white)
                .frame(width: characterSize * 0.3, height: characterSize * 0.2)
                .offset(x: -characterSize * 0.38, y: -characterSize * 0.05)
                .rotationEffect(.degrees(-20))
            
            // Shadow underneath
            Ellipse()
                .fill(Color.black.opacity(0.1))
                .frame(width: characterSize * 0.9, height: characterSize * 0.2)
                .blur(radius: 5)
                .offset(y: characterSize * 0.35)
        }
    }
    
    // Tail shape
    private var tailShape: some View {
        Path { path in
            let startX = -characterSize * 0.4
            let startY: CGFloat = 0
            
            path.move(to: CGPoint(x: startX, y: startY))
            
            // Create a curved tail with wag effect
            path.addCurve(
                to: CGPoint(x: startX - characterSize * 0.45, y: startY - characterSize * 0.25 + tailWag),
                control1: CGPoint(x: startX - characterSize * 0.2, y: startY),
                control2: CGPoint(x: startX - characterSize * 0.32, y: startY - characterSize * 0.1 + tailWag * 0.3)
            )
        }
        .stroke(Color.white, lineWidth: 12)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    // Head components including face, ears, eyes, muzzle
    private var headComponents: some View {
        ZStack {
            // Head shape
            headShape
            
            // Muzzle and face features
            muzzleComponents
            
            // Ears
            earComponents
        }
    }
    
    // Basic head shape
    private var headShape: some View {
        Circle()
            .fill(Color.white)
            .frame(width: characterSize * 0.7, height: characterSize * 0.7)
            .offset(x: characterSize * 0.4, y: -characterSize * 0.12 + sin(headBob) * 2)
    }
    
    // Muzzle, eyes, nose, whiskers, mouth
    private var muzzleComponents: some View {
        ZStack {
            // Muzzle base
            Ellipse()
                .fill(Color.white)
                .frame(width: characterSize * 0.4, height: characterSize * 0.3)
            
            // Nose
            RoundedRectangle(cornerRadius: 5)
                .fill(Color(hex: "FF9CAB"))  // Pink nose
                .frame(width: characterSize * 0.12, height: characterSize * 0.08)
                .offset(y: -characterSize * 0.02)
            
            // Whiskers
            whiskerComponents
            
            // Eyes
            HStack(spacing: characterSize * 0.14) {
                EyeView(characterSize: characterSize, eyeState: eyeState, isBlinking: isBlinking,
                        isUserSpeaking: isUserSpeaking, isAssistantThinking: isAssistantThinking,
                        moveDirection: moveDirection, bobAmount: bobAmount)
                EyeView(characterSize: characterSize, eyeState: eyeState, isBlinking: isBlinking,
                        isUserSpeaking: isUserSpeaking, isAssistantThinking: isAssistantThinking,
                        moveDirection: moveDirection, bobAmount: bobAmount)
            }
            .offset(y: -characterSize * 0.08)
            
            // Mouth
            MouthView(characterSize: characterSize, isAssistantSpeaking: isAssistantSpeaking,
                      isAssistantThinking: isAssistantThinking, mouthOpenness: mouthOpenness)
                .offset(y: characterSize * 0.08)
        }
        .offset(x: characterSize * 0.4, y: -characterSize * 0.07 + sin(headBob) * 2)
    }
    
    // Whisker components
    private var whiskerComponents: some View {
        WhiskerSetView(characterSize: characterSize, footPhase: footPhase)
    }
    
    // Ear components
    private var earComponents: some View {
        Group {
            // Left ear
            ZStack {
                // Outer ear
                Triangle()
                    .fill(Color(hex: "333333"))  // Dark ear color
                    .frame(width: characterSize * 0.15, height: characterSize * 0.20)
                
                // Inner ear
                Triangle()
                    .fill(Color(hex: "FFC0CB").opacity(0.7))  // Inner ear pink
                    .frame(width: characterSize * 0.10, height: characterSize * 0.14)
                    .offset(y: -characterSize * 0.01)
            }
            .offset(x: characterSize * 0.25, y: -characterSize * 0.25 + sin(headBob) * 1.5)
            .rotationEffect(.degrees(-15 + earAngle), anchor: .bottom)
            
            // Right ear
            ZStack {
                // Outer ear
                Triangle()
                    .fill(Color(hex: "333333"))  // Dark ear color
                    .frame(width: characterSize * 0.15, height: characterSize * 0.20)
                
                // Inner ear
                Triangle()
                    .fill(Color(hex: "FFC0CB").opacity(0.7))  // Inner ear pink
                    .frame(width: characterSize * 0.10, height: characterSize * 0.14)
                    .offset(y: -characterSize * 0.01)
            }
            .offset(x: characterSize * 0.55, y: -characterSize * 0.25 + sin(headBob) * 1.5)
            .rotationEffect(.degrees(15 - earAngle), anchor: .bottom)
        }
    }
    
    // Leg components
    private var legComponents: some View {
        Group {
            // Front Legs
            FrontLegView(characterSize: characterSize, isLeft: true, isRaised: frontLeftLegRaised)
                .offset(x: characterSize * 0.25, y: characterSize * 0.2)
            
            FrontLegView(characterSize: characterSize, isLeft: false, isRaised: frontRightLegRaised)
                .offset(x: characterSize * 0.55, y: characterSize * 0.2)
            
            // Back Legs
            BackLegView(characterSize: characterSize, isLeft: true, isRaised: backLeftLegRaised)
                .offset(x: -characterSize * 0.2, y: characterSize * 0.22)
            
            BackLegView(characterSize: characterSize, isLeft: false, isRaised: backRightLegRaised)
                .offset(x: characterSize * 0.1, y: characterSize * 0.22)
        }
    }
}
