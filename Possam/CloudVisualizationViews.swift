//
//  CloudVisualizationViews.swift
//  Possam
//
//  Created by Akash Thakur on 4/20/25.
//

import SwiftUI

// Cloud-shaped bubble with wavelength animation
struct CloudBubbleView: View {
    let isUserSpeaking: Bool
    let isAssistantSpeaking: Bool
    let audioLevel: Double
    let isUser: Bool
    
    @State private var phase: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Cloud-like bubble
            Path { path in
                let width: CGFloat = 140
                let height: CGFloat = 70
                
                // Base oval
                path.addEllipse(in: CGRect(x: 0, y: 10, width: width, height: height - 20))
                
                // Top curves for cloud effect
                path.move(to: CGPoint(x: width * 0.2, y: 10))
                path.addQuadCurve(
                    to: CGPoint(x: width * 0.4, y: 0),
                    control: CGPoint(x: width * 0.3, y: 0)
                )
                path.addQuadCurve(
                    to: CGPoint(x: width * 0.6, y: 5),
                    control: CGPoint(x: width * 0.5, y: -5)
                )
                path.addQuadCurve(
                    to: CGPoint(x: width * 0.8, y: 10),
                    control: CGPoint(x: width * 0.7, y: 0)
                )
                
                // Bottom curve for pointer
                if isUser {
                    path.move(to: CGPoint(x: width * 0.8, y: height - 10))
                    path.addQuadCurve(
                        to: CGPoint(x: width + 10, y: height),
                        control: CGPoint(x: width, y: height - 15)
                    )
                    path.addQuadCurve(
                        to: CGPoint(x: width * 0.9, y: height - 5),
                        control: CGPoint(x: width, y: height - 5)
                    )
                } else {
                    path.move(to: CGPoint(x: width * 0.2, y: height - 10))
                    path.addQuadCurve(
                        to: CGPoint(x: -10, y: height),
                        control: CGPoint(x: 0, y: height - 15)
                    )
                    path.addQuadCurve(
                        to: CGPoint(x: width * 0.1, y: height - 5),
                        control: CGPoint(x: 0, y: height - 5)
                    )
                }
            }
            .fill(isUser ? Color.userBubble.opacity(0.8) : Color.assistantBubble.opacity(0.8))
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            
            // Wavelength animation
            ZStack {
                ForEach(0..<5) { i in
                    WaveShape(phase: phase, amplitude: 5 + CGFloat(i) * 2)
                        .stroke(
                            isUser ? Color.userIcon.opacity(0.5) : Color.assistantIcon.opacity(0.5),
                            lineWidth: 2
                        )
                        .frame(height: 20)
                        .opacity(isUser ? (isUserSpeaking ? 1 : 0.3) : (isAssistantSpeaking ? 1 : 0.3))
                        .animation(.easeInOut(duration: 0.3), value: isUserSpeaking || isAssistantSpeaking)
                }
            }
            .frame(width: 100, height: 30)
            .mask(Capsule())
        }
        .frame(width: 140, height: 70)
        .onAppear {
            withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                phase = .pi * 2
            }
        }
    }
}

// Wave shape for the audio visualization
struct WaveShape: Shape {
    var phase: CGFloat
    var amplitude: CGFloat
    
    var animatableData: CGFloat {
        get { phase }
        set { phase = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        let midHeight = height / 2
        
        path.move(to: CGPoint(x: 0, y: midHeight))
        
        for x in stride(from: 0, to: width, by: 1) {
            let relativeX = x / width
            let sine = sin(relativeX * .pi * 4 + phase)
            let y = midHeight + sine * amplitude
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        return path
    }
}

// Updated Audio Visualization View
struct AudioVisualizationView: View {
    let isUserSpeaking: Bool
    let isAssistantSpeaking: Bool
    let userAudioLevel: Double
    let assistantAudioLevel: Double
    
    var body: some View {
        HStack(spacing: 20) {
            // User audio visualization with cloud bubble
            VStack(spacing: 6) {
                Text("You")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                
                CloudBubbleView(
                    isUserSpeaking: isUserSpeaking,
                    isAssistantSpeaking: isAssistantSpeaking,
                    audioLevel: userAudioLevel,
                    isUser: true
                )
            }
            
            // Assistant audio visualization with cloud bubble
            VStack(spacing: 6) {
                Text("Assistant")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                
                CloudBubbleView(
                    isUserSpeaking: isUserSpeaking,
                    isAssistantSpeaking: isAssistantSpeaking,
                    audioLevel: assistantAudioLevel,
                    isUser: false
                )
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white.opacity(0.9))
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
}
