import SwiftUI

@main
struct Inbox0App: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            AppCoordinator()
        }
    }
}
