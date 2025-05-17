import SwiftUI
import IntentsUI

struct SiriShortcutsView: View {
    @State private var isShowingAddShortcut = false
    @State private var isSiriAuthorized = false
    @State private var isCheckingAuthorization = true
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Text("Siri Shortcuts")
                    .font(.title)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding(.horizontal)
            
            if isCheckingAuthorization {
                // Loading indicator
                ProgressView()
                    .padding()
            } else {
                // Main content based on authorization
                Group {
                    if isSiriAuthorized {
                        authorizedView
                    } else {
                        unauthorizedView
                    }
                }
            }
            
            Spacer()
        }
        .padding(.top, 20)
        .navigationTitle("Siri Shortcuts")
        .onAppear {
            checkSiriAuthorization()
        }
        .sheet(isPresented: $isShowingAddShortcut) {
            SiriShortcutAddView()
        }
    }
    
    // View when Siri access is authorized
    private var authorizedView: some View {
        VStack(spacing: 20) {
            // Explanation
            Text("Use \"Hey Siri\" to start cleanBox's microphone with your voice. You can say phrases like \"Hey Siri, start cleanBox\" without having to open the app.")
                .padding(.horizontal)
                .foregroundColor(.secondary)
            
            // Shortcut card
            VStack(spacing: 16) {
                HStack {
                    Image(systemName: "mic.fill")
                        .font(.system(size: 26))
                        .foregroundColor(.white)
                        .frame(width: 50, height: 50)
                        .background(Circle().fill(Color.blue.opacity(0.8)))
                        .padding(.trailing, 8)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Start cleanBox")
                            .font(.headline)
                        
                        Text("Activate the microphone with Siri")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        isShowingAddShortcut = true
                    }) {
                        Text("Add to Siri")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Capsule().fill(Color.blue))
                    }
                }
                
                // Suggested phrases
                VStack(alignment: .leading, spacing: 8) {
                    Text("Suggested phrases:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    ForEach(suggestedPhrases, id: \.self) { phrase in
                        HStack {
                            Image(systemName: "quote.opening")
                                .foregroundColor(.gray)
                                .font(.system(size: 12))
                            
                            Text(phrase)
                            
                            Image(systemName: "quote.closing")
                                .foregroundColor(.gray)
                                .font(.system(size: 12))
                        }
                    }
                }
                .padding(.leading, 4)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
            )
            .padding(.horizontal)
        }
    }
    
    // View when Siri access is not authorized
    private var unauthorizedView: some View {
        VStack(spacing: 24) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.orange)
                .padding()
            
            Text("Siri Access Required")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("To use voice commands with cleanBox, you need to allow Siri access in your device settings.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            Button(action: {
                openSettings()
            }) {
                Text("Open Settings")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Capsule().fill(Color.blue))
            }
            .padding(.top, 10)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
        .padding()
    }
    
    // Check Siri authorization status
    private func checkSiriAuthorization() {
        isCheckingAuthorization = true
        
        InboxSiriManager.shared.checkSiriAuthorization { authorized in
            isSiriAuthorized = authorized
            isCheckingAuthorization = false
        }
    }
    
    // Open app settings
    private func openSettings() {
        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsURL)
        }
    }
    
    // Suggested phrases for Siri
    private var suggestedPhrases: [String] = [
        "Start cleanBox",
        "Turn on cleanBox",
        "Open cleanBox assistant",
        "Listen to me cleanBox"
    ]
}

struct SiriShortcutAddView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            Text("Add to Siri")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top, 20)
            
            Text("Set up a voice command to start cleanBox's microphone using Siri")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            // This uses UIViewControllerRepresentable to embed the INUIAddVoiceShortcutViewController
            SiriShortcutAddViewRepresentable()
                .padding()
            
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Close")
                    .font(.headline)
                    .foregroundColor(.blue)
                    .padding()
            }
        }
    }
}

// UIViewControllerRepresentable to wrap the IntentsUI view
struct SiriShortcutAddViewRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        // Create the intent
        let intent = StartMicIntent()
        intent.suggestedInvocationPhrase = "Start cleanBox"
        
        // Create the shortcut - FIX: Properly unwrap the optional
        guard let shortcut = INShortcut(intent: intent) else {
            // Return an empty view controller if shortcut creation fails
            return UIViewController()
        }
        
        // Create the UI to add the shortcut
        let viewController = INUIAddVoiceShortcutViewController(shortcut: shortcut)
        viewController.delegate = context.coordinator
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // Nothing to update here
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, INUIAddVoiceShortcutViewControllerDelegate {
        var parent: SiriShortcutAddViewRepresentable
        
        init(_ parent: SiriShortcutAddViewRepresentable) {
            self.parent = parent
        }
        
        func addVoiceShortcutViewController(_ controller: INUIAddVoiceShortcutViewController, didFinishWith voiceShortcut: INVoiceShortcut?, error: Error?) {
            // Dismiss the view controller
            controller.dismiss(animated: true, completion: nil)
        }
        
        func addVoiceShortcutViewControllerDidCancel(_ controller: INUIAddVoiceShortcutViewController) {
            // Dismiss the view controller
            controller.dismiss(animated: true, completion: nil)
        }
    }
}
