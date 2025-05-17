import UIKit
import SwiftUI
import AVFAudio
import GoogleSignIn
import Intents

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Set up audio session
        configureAudioSession()
        
        // Configure Google Sign In
        GoogleAuthManager.shared.configure()
        
        // Register for audio session interruptions
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAudioSessionInterruption),
            name: AVAudioSession.interruptionNotification,
            object: nil
        )
        
        // Donate the StartMic intent to Siri
        InboxSiriManager.shared.donateStartMicIntent()
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        // Handle Google Sign-In URL
        if GoogleAuthManager.shared.handleSignInURL(url) {
            return true
        }
        
        // Handle other URL schemes if needed
        return false
    }
    
    // MARK: - Siri Intent Handling
    
    // Support for handling intents while app is in foreground
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        // Check if this is a Siri intent
        if let intent = userActivity.interaction?.intent as? StartMicIntent {
            // Post notification to start mic
            NotificationCenter.default.post(name: InboxSiriManager.siriStartMicNotificationName, object: nil)
            return true
        }
        
        return false
    }
    
    // Handle audio session interruptions
    @objc func handleAudioSessionInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }
        
        switch type {
        case .began:
            // Interruption began - pause audio if needed
            print("Audio session interruption began")
        case .ended:
            // Interruption ended - resume audio if needed
            if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
                let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                if options.contains(.shouldResume) {
                    // Resume audio here
                    print("Audio session interruption ended - resuming audio")
                    activateAudioSession()
                }
            }
        @unknown default:
            break
        }
    }
    
    // Audio session configuration
    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            
            // Configure the session for voice chat mode with background audio
            try session.setCategory(
                .playAndRecord,
                mode: .voiceChat,  // Enable echo cancellation
                options: [
                    .defaultToSpeaker,
                    .allowBluetooth,
                    .allowBluetoothA2DP,
                    .duckOthers,
                    .mixWithOthers,  // Allow mixing with other apps
                    .allowAirPlay
                ]
            )
            
            // Use a voice processing IO unit
            try session.setMode(.voiceChat)
            
            // Set preferred sample rate and I/O buffer duration for minimal latency
            try session.setPreferredSampleRate(48000)
            try session.setPreferredIOBufferDuration(0.005)
            
            // Activate the session
            activateAudioSession()
            
            // Register for route change notifications
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(handleAudioRouteChange),
                name: AVAudioSession.routeChangeNotification,
                object: nil
            )
            
        } catch {
            print("Failed to configure audio session: \(error.localizedDescription)")
        }
    }
    
    func activateAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Failed to activate audio session: \(error.localizedDescription)")
        }
    }
    
    @objc func handleAudioRouteChange(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
              let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else {
            return
        }
        
        // Handle route changes (headphones connected/disconnected, etc.)
        switch reason {
        case .newDeviceAvailable:
            print("New audio device connected")
        case .oldDeviceUnavailable:
            print("Audio device disconnected")
        default:
            break
        }
    }
}
