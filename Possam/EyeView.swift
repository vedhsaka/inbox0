//
//  EyeView.swift
//  Possam
//
//  Created by Akash Thakur on 4/26/25.
//


import SwiftUI

// MARK: - Eye View Component
struct EyeView: View {
    let characterSize: CGFloat
    let eyeState: PossamCharacterView.EyeState
    let isBlinking: Bool
    let isUserSpeaking: Bool
    let isAssistantThinking: Bool
    let moveDirection: CGFloat
    let bobAmount: CGFloat
    
    var body: some View {
        Group {
            if isBlinking || eyeState == .closed {
                // Closed eye
                Rectangle()
                    .fill(Color.black)
                    .frame(width: characterSize * 0.1, height: 2)
                    .cornerRadius(1)
            } else if eyeState == .surprised {
                // Surprised eye
                ZStack {
                    // White part
                    Circle()
                        .fill(Color.white)
                        .frame(width: characterSize * 0.12, height: characterSize * 0.12)
                        .overlay(
                            Circle()
                                .stroke(Color.black, lineWidth: 1)
                        )
                    
                    // Pupil
                    Circle()
                        .fill(Color.black)
                        .frame(width: characterSize * 0.06, height: characterSize * 0.06)
                    
                    // Highlight
                    Circle()
                        .fill(Color.white.opacity(0.8))
                        .frame(width: characterSize * 0.025, height: characterSize * 0.025)
                        .offset(x: -1, y: -1)
                }
            } else if eyeState == .happy {
                // Happy eye (upside-down U)
                Path { path in
                    path.move(to: CGPoint(x: -characterSize * 0.05, y: 0))
                    path.addQuadCurve(
                        to: CGPoint(x: characterSize * 0.05, y: 0),
                        control: CGPoint(x: 0, y: characterSize * 0.04)
                    )
                }
                .stroke(Color.black, lineWidth: 2)
            } else {
                // Normal eye
                ZStack {
                    // White part
                    Circle()
                        .fill(Color.white)
                        .frame(width: characterSize * 0.12, height: characterSize * 0.12)
                        .overlay(
                            Circle()
                                .stroke(Color.black, lineWidth: 1)
                        )
                    
                    // Pupil - moves based on state and movement
                    Circle()
                        .fill(Color.black)
                        .frame(width: characterSize * 0.05, height: characterSize * 0.05)
                        .offset(
                            x: isUserSpeaking ? 2 : (isAssistantThinking ? CGFloat(sin(Date().timeIntervalSince1970 * 2) * 2) : moveDirection * 0.05),
                            y: isUserSpeaking ? -1 : (bobAmount * 0.5)
                        )
                    
                    // Highlight
                    Circle()
                        .fill(Color.white.opacity(0.8))
                        .frame(width: characterSize * 0.02, height: characterSize * 0.02)
                        .offset(x: -1, y: -1)
                }
            }
        }
    }
}

// MARK: - Mouth View Component
struct MouthView: View {
    let characterSize: CGFloat
    let isAssistantSpeaking: Bool
    let isAssistantThinking: Bool
    let mouthOpenness: CGFloat
    
    var body: some View {
        Group {
            if isAssistantSpeaking {
                // Talking mouth
                ZStack {
                    // Outer mouth
                    Capsule()
                        .fill(Color.black)
                        .frame(width: characterSize * 0.18, height: characterSize * 0.05 + mouthOpenness * characterSize * 0.12)
                    
                    // Inner mouth
                    Capsule()
                        .fill(Color(hex: "FF6B8B"))  // Inner mouth color
                        .frame(width: characterSize * 0.12, height: characterSize * 0.03 + mouthOpenness * characterSize * 0.1)
                    
                    // Tongue visible when wide open
                    if mouthOpenness > 0.6 {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(hex: "FF4D6D"))
                            .frame(width: characterSize * 0.08, height: characterSize * 0.05)
                            .offset(y: characterSize * 0.01)
                            .opacity(mouthOpenness - 0.6)
                    }
                }
            } else if isAssistantThinking {
                // Thinking mouth (small o)
                ZStack {
                    Circle()
                        .fill(Color.black)
                        .frame(width: characterSize * 0.06, height: characterSize * 0.06)
                    
                    Circle()
                        .fill(Color(hex: "FF6B8B"))
                        .frame(width: characterSize * 0.04, height: characterSize * 0.04)
                }
            } else {
                // Normal smile
                Path { path in
                    path.move(to: CGPoint(x: -characterSize * 0.08, y: 0))
                    path.addQuadCurve(
                        to: CGPoint(x: characterSize * 0.08, y: 0),
                        control: CGPoint(x: 0, y: characterSize * 0.05)
                    )
                }
                .stroke(Color.black, lineWidth: 2)
            }
        }
    }
}

// MARK: - Whisker View Component
struct WhiskerSetView: View {
    let characterSize: CGFloat
    let footPhase: CGFloat
    
    var body: some View {
        Group {
            // Left side whiskers
            leftWhiskers
            
            // Right side whiskers
            rightWhiskers
        }
    }
    
    // Left side whiskers
    private var leftWhiskers: some View {
        ForEach(0..<3, id: \.self) { i in
            Path { path in
                path.move(to: CGPoint(x: -characterSize * 0.05, y: characterSize * 0.0 + CGFloat(i - 1) * 3))
                path.addLine(to: CGPoint(x: -characterSize * 0.15, y: characterSize * 0.0 + CGFloat(i - 1) * 5 + sin(Double(footPhase + CGFloat(i) * 0.3)) * 1.5))
            }
            .stroke(Color.gray.opacity(0.6), lineWidth: 1)
        }
    }
    
    // Right side whiskers
    private var rightWhiskers: some View {
        ForEach(0..<3, id: \.self) { i in
            Path { path in
                path.move(to: CGPoint(x: characterSize * 0.05, y: characterSize * 0.0 + CGFloat(i - 1) * 3))
                path.addLine(to: CGPoint(x: characterSize * 0.15, y: characterSize * 0.0 + CGFloat(i - 1) * 5 + sin(Double(footPhase + CGFloat(i) * 0.3)) * 1.5))
            }
            .stroke(Color.gray.opacity(0.6), lineWidth: 1)
        }
    }
}

// MARK: - Leg View Components
struct FrontLegView: View {
    let characterSize: CGFloat
    let isLeft: Bool
    let isRaised: Bool
    
    var body: some View {
        let offset: CGFloat = isRaised ? -10 : 0  // Raised amount
        
        return ZStack(alignment: .top) {
            // Upper leg
            RoundedRectangle(cornerRadius: 5)
                .fill(Color.white)
                .frame(width: 12, height: 25)
                .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 1)
            
            // Lower leg and paw
            ZStack(alignment: .bottom) {
                // Lower leg
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.white)
                    .frame(width: 10, height: 20)
                
                // Paw
                ZStack {
                    Ellipse()
                        .fill(Color.white)
                        .frame(width: 16, height: 10)
                    
                    // Paw pads
                    HStack(spacing: 3) {
                        ForEach(0..<3, id: \.self) { _ in
                            Circle()
                                .fill(Color(hex: "FFC0CB").opacity(0.8))
                                .frame(width: 3, height: 3)
                        }
                    }
                    .offset(y: -2)
                }
                .offset(y: 12)
            }
            .rotationEffect(.degrees(isRaised ? -15 : 0))
            .offset(y: 22)
        }
        .rotationEffect(.degrees(isRaised ? -10 : 0))
        .offset(y: offset)
    }
}

struct BackLegView: View {
    let characterSize: CGFloat
    let isLeft: Bool
    let isRaised: Bool
    
    var body: some View {
        let offset: CGFloat = isRaised ? -8 : 0  // Raised amount
        
        return ZStack(alignment: .top) {
            // Upper leg (thigh)
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.white)
                .frame(width: 14, height: 22)
                .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 1)
            
            // Lower leg and paw
            ZStack(alignment: .bottom) {
                // Lower leg
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.white)
                    .frame(width: 12, height: 25)
                
                // Paw
                ZStack {
                    Ellipse()
                        .fill(Color.white)
                        .frame(width: 18, height: 10)
                    
                    // Paw pads
                    HStack(spacing: 3) {
                        ForEach(0..<3, id: \.self) { _ in
                            Circle()
                                .fill(Color(hex: "FFC0CB").opacity(0.8))
                                .frame(width: 3, height: 3)
                        }
                    }
                    .offset(y: -2)
                }
                .offset(y: 14)
            }
            .rotationEffect(.degrees(isRaised ? -25 : 0))
            .offset(y: 20)
        }
        .rotationEffect(.degrees(isRaised ? -12 : 0))
        .offset(y: offset)
    }
}
