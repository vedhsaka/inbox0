//
//  for.swift
//  Possam
//
//  Created by Akash Thakur on 5/17/25.
//


import SwiftUI

/// A centralized struct for app colors
/// This follows the best practice of using a dedicated struct for color definitions
/// rather than extending Color directly to avoid conflicts
struct AppColors {
    // MARK: - Premium Colors
    static let premiumBackground = Color.white
    static let premiumAccent = Color(uiColor: UIColor(red: 26/255, green: 44/255, blue: 84/255, alpha: 1)) // #1A2C54
    static let premiumGold = Color(uiColor: UIColor(red: 212/255, green: 185/255, blue: 120/255, alpha: 1)) // #D4B978
    static let premiumGoldLight = Color(uiColor: UIColor(red: 240/255, green: 228/255, blue: 187/255, alpha: 1)) // #F0E4BB
    static let premiumRed = Color(uiColor: UIColor(red: 214/255, green: 42/255, blue: 56/255, alpha: 1)) // #D62A38
    static let premiumBlue = Color(uiColor: UIColor(red: 15/255, green: 30/255, blue: 61/255, alpha: 1)) // #0F1E3D
    static let premiumLightBlue = Color(uiColor: UIColor(red: 248/255, green: 249/255, blue: 252/255, alpha: 1)) // #F8F9FC
    static let premiumLighterBlue = Color(uiColor: UIColor(red: 238/255, green: 241/255, blue: 248/255, alpha: 1)) // #EEF1F8
    
    // MARK: - App Theme Colors
    static let appBackground = Color(hex: "F8F9FA")
    static let appAccent = Color(hex: "007AFF")
    static let appRed = Color(hex: "FF3B30")
    static let appGreen = Color(hex: "34C759")
    
    // MARK: - Bubble Colors
    static let userBubble = Color(hex: "E1F5FE")
    static let assistantBubble = Color(hex: "E8F5E9")
    static let assistantProcessingBubble = Color(hex: "F5F5F5")
    static let systemBubble = Color(hex: "EDE7F6")
    static let statusBubble = Color(hex: "FFECB3")
    static let errorBubble = Color(hex: "FFEBEE")
    
    // MARK: - Text Colors
    static let bubbleText = Color(hex: "212121")
    static let systemText = Color(hex: "673AB7")
    static let statusText = Color(hex: "FF6F00")
    static let errorText = Color(hex: "D32F2F")
    
    // MARK: - Icon Colors
    static let userIcon = Color(hex: "2196F3")
    static let assistantIcon = Color(hex: "4CAF50")
    static let assistantProcessingIcon = Color(hex: "9E9E9E")
    static let systemIcon = Color(hex: "673AB7")
    static let statusIcon = Color(hex: "FF9800")
    static let errorIcon = Color(hex: "F44336")
    
    // MARK: - Audio Visualization
    static let userAudioBar = Color(hex: "2196F3")
    static let assistantAudioBar = Color(hex: "4CAF50")
    
    // MARK: - Particle Visualization Colors
    static let particleIdle = [Color(hex: "4DA8DA"), Color(hex: "5E7CE2"), Color(hex: "7B68EE")]
    static let particleUserSpeaking = [Color(hex: "03A9F4"), Color(hex: "00BCD4"), Color(hex: "4FC3F7")]
    static let particleThinking = [Color(hex: "9C27B0"), Color(hex: "7E57C2"), Color(hex: "B39DDB")]
    static let particleSpeaking = [Color(hex: "4CAF50"), Color(hex: "8BC34A"), Color(hex: "CDDC39")]
    
    // MARK: - Background Gradients
    static let idleGradient = [Color(hex: "1A1A2E"), Color(hex: "16213E")]
    static let userSpeakingGradient = [Color(hex: "173B5E"), Color(hex: "1D566E")]
    static let thinkingGradient = [Color(hex: "322C4A"), Color(hex: "483B66")]
    static let speakingGradient = [Color(hex: "1D4437"), Color(hex: "2D6E42")]
}

// MARK: - Gradients
struct AppGradients {
    static var premiumBackground: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                .white,
                AppColors.premiumLightBlue
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    static var premiumBackgroundAnimated: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                .white,
                AppColors.premiumLightBlue,
                AppColors.premiumLighterBlue
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static var goldGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                AppColors.premiumGold,
                AppColors.premiumGoldLight,
                AppColors.premiumGold
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static var navyGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                AppColors.premiumAccent,
                AppColors.premiumBlue
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    static var redGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                AppColors.premiumRed,
                AppColors.premiumRed.opacity(0.8)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

// MARK: - Color Hex Initializer
// We only extend Color with a single method for hex initialization
// This avoids conflicts with multiple extensions
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}