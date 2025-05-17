import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @EnvironmentObject var appState: AppState
    @Binding var showSideMenu: Bool // CHANGED FROM @Environment to @Binding
    @State private var showLogoutConfirmation = false
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background color
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Search bar
                    VStack(spacing: 8) {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                            
                            TextField("Search for a setting...", text: $searchText)
                                .font(.system(size: 16))
                        }
                        .padding(12)
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .cornerRadius(10)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                    }
                    
                    // Settings list
                    List {
                        Group {
                            // Account section
                            NavigationLink(destination: AccountSettingsView()) {
                                SettingsRowView(
                                    icon: "person.circle",
                                    title: "Account",
                                    iconColor: .black
                                )
                            }
                            
                            // Tools section
                            NavigationLink(destination: ToolsSettingsView()) {
                                SettingsRowView(
                                    icon: "hammer",
                                    title: "Tools",
                                    iconColor: .black
                                )
                            }
                            
                            // Notifications section
                            NavigationLink(destination: NotificationsSettingsView()) {
                                SettingsRowView(
                                    icon: "bell.fill",
                                    title: "Notifications",
                                    iconColor: .black
                                )
                            }
                            
                            // Appearance section
                            NavigationLink(destination: AppearanceSettingsView()) {
                                SettingsRowView(
                                    icon: "eye",
                                    title: "Appearance",
                                    iconColor: .black
                                )
                            }
                            
                            // Privacy & Security section
                            NavigationLink(destination: PrivacySecuritySettingsView()) {
                                SettingsRowView(
                                    icon: "lock",
                                    title: "Privacy & Security",
                                    iconColor: .black
                                )
                            }
                            
                            // Help and Support section
                            NavigationLink(destination: HelpSupportView()) {
                                SettingsRowView(
                                    icon: "headphones",
                                    title: "Help and Support",
                                    iconColor: .black
                                )
                            }
                            
                            // About section
                            NavigationLink(destination: AboutView()) {
                                SettingsRowView(
                                    icon: "info.circle",
                                    title: "About",
                                    iconColor: .black
                                )
                            }
                        }
                        .listRowSeparator(.visible)
                        
                        // Logout button (separated from navigation links)
                        Button(action: {
                            print("Logout button tapped")
                            showLogoutConfirmation = true
                        }) {
                            SettingsRowView(
                                icon: "arrow.right.square",
                                title: "Logout",
                                iconColor: .red
                            )
                        }
                        .listRowSeparator(.visible)
                    }
                    .listStyle(InsetGroupedListStyle())
                    .background(Color(UIColor.systemGroupedBackground))
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        withAnimation(.spring()) {
                            showSideMenu = false // FIXED - Now closes the side menu
                        }
                    }) {
                        Image(systemName: "arrow.left")
                            .foregroundColor(.primary)
                    }
                }
            }
        }
        .alert("Logout", isPresented: $showLogoutConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Logout", role: .destructive) {
                print("Logout confirmed")
                logout()
            }
        } message: {
            Text("Are you sure you want to log out of your account?")
        }
    }
    
    private func logout() {
        print("Logout function called")
        
        // Show a loading indicator
        appState.isLoading = true
        appState.loadingMessage = "Logging out..."
        
        // Call the logout method from AuthViewModel
        Task {
            // Explicit calls to sign out from both services
            GoogleAuthManager.shared.signOut()
            await SupabaseAuthManager.shared.signOut()
            
            await MainActor.run {
                // Update auth view model properties
                authViewModel.isLoggedIn = false
                authViewModel.userName = nil
                authViewModel.userEmail = nil
                authViewModel.hasConnectedTools = false
                authViewModel.needsEmailVerification = false
                authViewModel.verificationEmail = nil
                
                // Update app state
                appState.isAuthenticated = false
                
                // Stop loading indicator and navigate to welcome screen
                appState.isLoading = false
                appState.navigateTo(.welcome)
                
                print("Logout completed, navigating to welcome screen")
            }
        }
    }
}

// Reusable row view for settings
struct SettingsRowView: View {
    let icon: String
    let title: String
    let iconColor: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(iconColor)
                .frame(width: 24, height: 24)
                .padding(6)
            
            Text(title)
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(.primary)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.gray)
        }
        .padding(.vertical, 4)
    }
}

// Placeholder views for each settings section
struct AccountSettingsView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Profile info
            VStack(alignment: .leading, spacing: 6) {
                Text("Profile Information")
                    .font(.headline)
                    .padding(.top)
                
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Name")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(authViewModel.userName ?? "Not set")
                    }
                    
                    Divider()
                    
                    HStack {
                        Text("Email")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(authViewModel.userEmail ?? "Not set")
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Account")
        .background(Color.appBackground.ignoresSafeArea())
    }
}

struct ToolsSettingsView: View {
    var body: some View {
        Text("Tools Settings")
            .navigationTitle("Tools")
    }
}

struct NotificationsSettingsView: View {
    @State private var voiceNotifications = true
    @State private var emailNotifications = false
    
    var body: some View {
        Form {
            Section(header: Text("Notifications")) {
                Toggle("Voice Prompts", isOn: $voiceNotifications)
                Toggle("Email Updates", isOn: $emailNotifications)
            }
        }
        .navigationTitle("Notifications")
    }
}

struct AppearanceSettingsView: View {
    @State private var darkMode = false
    @State private var fontSize = 1.0
    
    var body: some View {
        Form {
            Section(header: Text("Theme")) {
                Toggle("Dark Mode", isOn: $darkMode)
            }
            
            Section(header: Text("Text Size")) {
                Slider(value: $fontSize, in: 0.8...1.2, step: 0.1)
                    .padding(.vertical, 8)
                
                Text("Preview Text")
                    .font(.system(size: 17 * fontSize))
                    .padding(.vertical, 8)
            }
        }
        .navigationTitle("Appearance")
    }
}

struct PrivacySecuritySettingsView: View {
    @State private var biometricAuth = true
    @State private var saveTranscripts = true
    
    var body: some View {
        Form {
            Section(header: Text("Security")) {
                Toggle("Face ID / Touch ID Login", isOn: $biometricAuth)
            }
            
            Section(header: Text("Privacy")) {
                Toggle("Save Voice Transcripts", isOn: $saveTranscripts)
                
                Button(action: {
                    // Action to clear data
                }) {
                    Text("Clear Conversation History")
                        .foregroundColor(.red)
                }
            }
        }
        .navigationTitle("Privacy & Security")
    }
}

struct HelpSupportView: View {
    var body: some View {
        List {
            Section {
                NavigationLink(destination: FAQView()) {
                    Label("FAQs", systemImage: "questionmark.circle")
                }
                
                NavigationLink(destination: ContactSupportView()) {
                    Label("Contact Support", systemImage: "envelope")
                }
            }
            
            Section {
                NavigationLink(destination: TutorialsView()) {
                    Label("Tutorials", systemImage: "book")
                }
            }
        }
        .navigationTitle("Help & Support")
    }
}

struct FAQView: View {
    var body: some View {
        Text("Frequently Asked Questions")
    }
}

struct ContactSupportView: View {
    var body: some View {
        Text("Contact Support")
    }
}

struct TutorialsView: View {
    var body: some View {
        Text("Tutorials")
    }
}

struct AboutView: View {
    var body: some View {
        List {
            Section {
                HStack {
                    Text("Version")
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(.gray)
                }
                
                HStack {
                    Text("Build")
                    Spacer()
                    Text("103")
                        .foregroundColor(.gray)
                }
            }
            
            Section {
                NavigationLink(destination: PrivacyPolicyView()) {
                    Text("Privacy Policy")
                }
                
                NavigationLink(destination: TermsOfServiceView()) {
                    Text("Terms of Service")
                }
                
                NavigationLink(destination: LicensesView()) {
                    Text("Licenses")
                }
            }
        }
        .navigationTitle("About")
    }
}

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            Text("Privacy Policy")
                .font(.title)
                .padding()
            
            Text("Privacy policy content goes here...")
                .padding()
        }
    }
}

struct TermsOfServiceView: View {
    var body: some View {
        ScrollView {
            Text("Terms of Service")
                .font(.title)
                .padding()
            
            Text("Terms of service content goes here...")
                .padding()
        }
    }
}

struct LicensesView: View {
    var body: some View {
        Text("Licenses")
    }
}
