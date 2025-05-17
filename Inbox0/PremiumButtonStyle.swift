//
//  PremiumButtonStyle.swift
//  Possam
//
//  Created by Akash Thakur on 5/17/25.
//


import SwiftUI

// NOTE: Color extension has been removed from here and consolidated in SimplifiedModels.swift
// to prevent conflicts and "Ambiguous use of 'init(hex:)'" errors

// Premium UI components

// Premium Button Style
struct PremiumButtonStyle: ButtonStyle {
    let isPrimary: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold))
            .tracking(1.5)
            .foregroundColor(isPrimary ? .white : Color.premiumAccent)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                Group {
                    if isPrimary {
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.premiumAccent,
                                Color.premiumBlue
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    } else {
                        Color.white
                    }
                }
            )
            .cornerRadius(12)
            .shadow(color: isPrimary ? Color.premiumAccent.opacity(0.2) : Color.black.opacity(0.08),
                   radius: 10, x: 0, y: 5)
            .overlay(
                Group {
                    if !isPrimary {
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.premiumGold,
                                        Color.premiumGoldLight,
                                        Color.premiumGold
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    }
                }
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

// Premium TextField Style
struct PremiumTextFieldStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
    }
}

// Premium Card Style
struct PremiumCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(20)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
    }
}

// Gold Circle Border
struct GoldCircleBorder: View {
    let size: CGFloat
    
    var body: some View {
        Circle()
            .strokeBorder(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.premiumGold,
                        Color.premiumGoldLight,
                        Color.premiumGold
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 2
            )
            .frame(width: size, height: size)
    }
}

// Extension for View
extension View {
    func premiumTextField() -> some View {
        self.modifier(PremiumTextFieldStyle())
    }
    
    func premiumCard() -> some View {
        self.modifier(PremiumCardStyle())
    }
}

// Wave animation for microphone
struct PremiumWaveAnimation: View {
    @State private var animateWave = false
    
    var body: some View {
        ZStack {
            ForEach(0..<3) { index in
                Circle()
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.premiumGold.opacity(0.7),
                                Color.premiumGold.opacity(0.3)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 1.5
                    )
                    .frame(width: 120 + CGFloat(index * 30),
                           height: 120 + CGFloat(index * 30))
                    .scaleEffect(animateWave ? 1.2 : 0.8)
                    .opacity(animateWave ? 0.0 : 0.5)
                    .animation(
                        Animation.easeInOut(duration: 2)
                            .repeatForever(autoreverses: false)
                            .delay(Double(index) * 0.4),
                        value: animateWave
                    )
            }
        }
        .onAppear {
            animateWave = true
        }
    }
}
