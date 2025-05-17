import SwiftUI

// Background gradients as computed properties
extension LinearGradient {
    static var premiumBackground: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                .white,
                Color.premiumLightBlue
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    static var premiumBackgroundAnimated: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                .white,
                Color.premiumLightBlue,
                Color.premiumLighterBlue
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static var goldGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.premiumGold,
                Color.premiumGoldLight,
                Color.premiumGold
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static var navyGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.premiumAccent,
                Color.premiumBlue
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    static var redGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.premiumRed,
                Color.premiumRed.opacity(0.8)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
}
