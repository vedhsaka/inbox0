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

// NOTE: Color extension is now defined only in SimplifiedModels.swift
// The old Color extension was removed from here to prevent conflicts
