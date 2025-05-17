import SwiftUI

// Update the main app file with the new premium name
@main
struct VoiceEliteApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            AppCoordinator()
        }
    }
}
