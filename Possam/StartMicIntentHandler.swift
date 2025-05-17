
import Intents

class StartMicIntentHandler: NSObject, StartMicIntentHandling {
    func handle(intent: StartMicIntent, completion: @escaping (StartMicIntentResponse) -> Void) {
        // Use our centralized manager to handle the intent
        InboxSiriManager.shared.handleStartMicIntent(completion: completion)
    }
    
    // This is called when Siri is confirming the intent with the user
    func confirm(intent: StartMicIntent, completion: @escaping (StartMicIntentResponse) -> Void) {
        // Always allow the intent to proceed
        let response = StartMicIntentResponse(code: .ready, userActivity: nil)
        completion(response)
    }
}
