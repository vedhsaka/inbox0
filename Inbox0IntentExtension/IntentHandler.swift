import Intents
// This import references your main app's module where the intent definitions are
import Possam

class IntentHandler: INExtension {
    override func handler(for intent: INIntent) -> Any {
        // Route intents to the appropriate handler
        switch intent {
        case is StartMicIntent:
            return StartMicIntentHandler()
        default:
            return self
        }
    }
}

class StartMicIntentHandler: NSObject, StartMicIntentHandling {
    func handle(intent: StartMicIntent, completion: @escaping (StartMicIntentResponse) -> Void) {
        // Post notification to start mic
        NotificationCenter.default.post(name: Notification.Name("SiriStartMicRequest"), object: nil)
        
        // Return success response with properly typed nil
        let response = StartMicIntentResponse(code: .success, userActivity: nil as NSUserActivity?)
        completion(response)
    }
    
    func confirm(intent: StartMicIntent, completion: @escaping (StartMicIntentResponse) -> Void) {
        // Always allow the intent to proceed
        let response = StartMicIntentResponse(code: .ready, userActivity: nil as NSUserActivity?)
        completion(response)
    }
}
