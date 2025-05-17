//
//  to.swift
//  Possam
//
//  Created by Akash Thakur on 5/17/25.
//


//
//  ColorExtensions.swift
//  VoiceElite
//
//  Created to bridge the AppColors struct to UIKit and SwiftUI's color systems
//

import SwiftUI

// MARK: - Color Extensions
// These extensions make the AppColors struct accessible through the standard Color type
// This approach prevents conflicts with multiple extensions
extension Color {
    // MARK: - Premium Colors
    static var premiumBackground: Color { AppColors.premiumBackground }
    static var premiumAccent: Color { AppColors.premiumAccent }
    static var premiumGold: Color { AppColors.premiumGold }
    static var premiumGoldLight: Color { AppColors.premiumGoldLight }
    static var premiumRed: Color { AppColors.premiumRed }
    static var premiumBlue: Color { AppColors.premiumBlue }
    static var premiumLightBlue: Color { AppColors.premiumLightBlue }
    static var premiumLighterBlue: Color { AppColors.premiumLighterBlue }
    
    // MARK: - App Theme Colors
    static var appBackground: Color { AppColors.appBackground }
    static var appAccent: Color { AppColors.appAccent }
    static var appRed: Color { AppColors.appRed }
    static var appGreen: Color { AppColors.appGreen }
    
    // MARK: - Bubble Colors
    static var userBubble: Color { AppColors.userBubble }
    static var assistantBubble: Color { AppColors.assistantBubble }
    static var assistantProcessingBubble: Color { AppColors.assistantProcessingBubble }
    static var systemBubble: Color { AppColors.systemBubble }
    static var statusBubble: Color { AppColors.statusBubble }
    static var errorBubble: Color { AppColors.errorBubble }
    
    // MARK: - Text Colors
    static var bubbleText: Color { AppColors.bubbleText }
    static var systemText: Color { AppColors.systemText }
    static var statusText: Color { AppColors.statusText }
    static var errorText: Color { AppColors.errorText }
    
    // MARK: - Icon Colors
    static var userIcon: Color { AppColors.userIcon }
    static var assistantIcon: Color { AppColors.assistantIcon }
    static var assistantProcessingIcon: Color { AppColors.assistantProcessingIcon }
    static var systemIcon: Color { AppColors.systemIcon }
    static var statusIcon: Color { AppColors.statusIcon }
    static var errorIcon: Color { AppColors.errorIcon }
    
    // MARK: - Audio Visualization
    static var userAudioBar: Color { AppColors.userAudioBar }
    static var assistantAudioBar: Color { AppColors.assistantAudioBar }
}

// MARK: - LinearGradient Extensions
// Add extensions to access gradients more easily
extension LinearGradient {
    static var premiumBackground: LinearGradient { AppGradients.premiumBackground }
    static var premiumBackgroundAnimated: LinearGradient { AppGradients.premiumBackgroundAnimated }
    static var goldGradient: LinearGradient { AppGradients.goldGradient }
    static var navyGradient: LinearGradient { AppGradients.navyGradient }
    static var redGradient: LinearGradient { AppGradients.redGradient }
}
