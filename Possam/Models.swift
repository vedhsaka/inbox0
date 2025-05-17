//
//  Models.swift
//  Possam
//
//  Created by Akash Thakur on 4/20/25.
//

import SwiftUI

// Message model for the chat
struct ChatMessage: Identifiable, Hashable {
    let id = UUID()
    let text: String
    let type: MessageType
    let timestamp: Date
    
    enum MessageType {
        case user
        case assistant
        case assistantProcessing
        case system
        case status
        case error
    }
    
    // Bubble color based on message type
    var bubbleColor: Color {
        switch type {
        case .user:
            return .userBubble
        case .assistant:
            return .assistantBubble
        case .assistantProcessing:
            return .assistantProcessingBubble
        case .system:
            return .systemBubble
        case .status:
            return .statusBubble
        case .error:
            return .errorBubble
        }
    }
    
    // Text color based on message type
    var textColor: Color {
        switch type {
        case .user, .assistant, .assistantProcessing:
            return .bubbleText
        case .system:
            return .systemText
        case .status:
            return .statusText
        case .error:
            return .errorText
        }
    }
    
    // Icon for the message
    var icon: String {
        switch type {
        case .user:
            return "person.circle.fill"
        case .assistant, .assistantProcessing:
            return "ellipsis.bubble.fill"
        case .system:
            return "info.circle.fill"
        case .status:
            return "arrow.triangle.2.circlepath.circle.fill"
        case .error:
            return "exclamationmark.triangle.fill"
        }
    }
    
    // Icon color based on message type
    var iconColor: Color {
        switch type {
        case .user:
            return .userIcon
        case .assistant:
            return .assistantIcon
        case .assistantProcessing:
            return .assistantProcessingIcon
        case .system:
            return .systemIcon
        case .status:
            return .statusIcon
        case .error:
            return .errorIcon
        }
    }
}

// Model for audio visualization
struct AudioBar: Identifiable {
    let id = UUID()
    var height: CGFloat
    var delay: Double
}

// Model for particle visualization
//struct Particle: Identifiable {
//    let id = UUID()
//    var position: CGPoint
//    var velocity: CGVector
//    var size: CGFloat
//    var color: Color
//    var opacity: CGFloat
//    var depth: CGFloat  // 0.1-1.0 for parallax effect
//    var energy: CGFloat = 1.0
//}

// Extension to make colors easier to use
extension Color {
    // App theme colors
    static let appBackground = Color(hex: "F8F9FA")
    static let appAccent = Color(hex: "007AFF")
    static let appRed = Color(hex: "FF3B30")
    static let appGreen = Color(hex: "34C759")
    
    // Bubble colors
    static let userBubble = Color(hex: "E1F5FE")
    static let assistantBubble = Color(hex: "E8F5E9")
    static let assistantProcessingBubble = Color(hex: "F5F5F5")
    static let systemBubble = Color(hex: "EDE7F6")
    static let statusBubble = Color(hex: "FFECB3")
    static let errorBubble = Color(hex: "FFEBEE")
    
    // Text colors
    static let bubbleText = Color(hex: "212121")
    static let systemText = Color(hex: "673AB7")
    static let statusText = Color(hex: "FF6F00")
    static let errorText = Color(hex: "D32F2F")
    
    // Icon colors
    static let userIcon = Color(hex: "2196F3")
    static let assistantIcon = Color(hex: "4CAF50")
    static let assistantProcessingIcon = Color(hex: "9E9E9E")
    static let systemIcon = Color(hex: "673AB7")
    static let statusIcon = Color(hex: "FF9800")
    static let errorIcon = Color(hex: "F44336")
    
    // Audio visualization
    static let userAudioBar = Color(hex: "2196F3")
    static let assistantAudioBar = Color(hex: "4CAF50")
    
    // Particle visualization colors - New for enhanced visualization
    static let particleIdle = [Color(hex: "4DA8DA"), Color(hex: "5E7CE2"), Color(hex: "7B68EE")]
    static let particleUserSpeaking = [Color(hex: "03A9F4"), Color(hex: "00BCD4"), Color(hex: "4FC3F7")]
    static let particleThinking = [Color(hex: "9C27B0"), Color(hex: "7E57C2"), Color(hex: "B39DDB")]
    static let particleSpeaking = [Color(hex: "4CAF50"), Color(hex: "8BC34A"), Color(hex: "CDDC39")]
    
    // Background gradients for visualization states
    static let idleGradient = [Color(hex: "1A1A2E"), Color(hex: "16213E")]
    static let userSpeakingGradient = [Color(hex: "173B5E"), Color(hex: "1D566E")]
    static let thinkingGradient = [Color(hex: "322C4A"), Color(hex: "483B66")]
    static let speakingGradient = [Color(hex: "1D4437"), Color(hex: "2D6E42")]
    
    // Initialize with hex string
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
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    // Get a random color from an array
    static func random(from colors: [Color]) -> Color {
        colors.randomElement() ?? .primary
    }
}
