import Foundation
import Intents
import UserNotifications

/// Manages Siri integration for cleanBox app
class InboxSiriManager {
    static let shared = InboxSiriManager()
    
    // Notification name for Siri start requests
    static let siriStartMicNotificationName = Notification.Name("SiriStartMicRequest")
    
    /// Donates the StartMic intent to Siri for suggestions
    func donateStartMicIntent() {
        let intent = StartMicIntent()
        intent.suggestedInvocationPhrase = "Start cleanBox"
        
        // Create the interaction with proper nil checking
        let interaction = INInteraction(intent: intent, response: nil as INIntentResponse?)
        interaction.donate { error in
            if let error = error {
                print("Failed to donate intent: \(error.localizedDescription)")
            } else {
                print("Successfully donated cleanBox mic intent to Siri")
            }
        }
    }
    
    /// Checks if Siri shortcuts are enabled for this app
    func checkSiriAuthorization(completion: @escaping (Bool) -> Void) {
        INPreferences.requestSiriAuthorization { status in
            DispatchQueue.main.async {
                completion(status == .authorized)
            }
        }
    }
    
    /// Handles Siri intent to start the microphone
    func handleStartMicIntent(completion: @escaping (StartMicIntentResponse) -> Void) {
        // Post notification that will be observed by the app to start the mic
        NotificationCenter.default.post(name: Self.siriStartMicNotificationName, object: nil)
        
        // Create a response with the result property
        let response = StartMicIntentResponse(code: .success, userActivity: nil)
        
        // If you have a result property on your intent response, uncomment and use this:
        // response.result = "Started listening with cleanBox"
        
        completion(response)
    }
}
