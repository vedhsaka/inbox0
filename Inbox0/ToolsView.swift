import SwiftUI
import Combine

// Tool model
struct Tool: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let description: String
    let iconName: String
    let isRequired: Bool
    let connectionUrl: String?
    
    // Default icon if none provided
    var systemIcon: String {
        // Provide default icon name if the iconName doesn't exist in SF Symbols
        return iconName.isEmpty ? "questionmark.circle" : iconName
    }
}

class ToolsManager: ObservableObject {
    static let shared = ToolsManager()
    
    @Published var availableTools: [Tool] = []
    @Published var connectedToolIds: Set<String> = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let apiBaseUrl = "https://api.example.com/v1" // Replace with your actual API base URL
    
    // Fetch available tools from API
    func fetchAvailableTools() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            // In a real implementation, you would fetch from your API
            // For now, we'll use mock data
            let tools = mockTools()
            
            // Simulate network request
            try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
            
            await MainActor.run {
                self.availableTools = tools
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to fetch tools: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    // Connect to a tool
    func connectToTool(toolId: String) async -> Bool {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            // In a real implementation, you would make an API call to connect
            // For now, we'll simulate the connection
            
            // Simulate network request
            try await Task.sleep(nanoseconds: 2_000_000_000) // 2 second delay
            
            // Simulate success
            await MainActor.run {
                connectedToolIds.insert(toolId)
                isLoading = false
            }
            return true
        } catch {
            await MainActor.run {
                errorMessage = "Failed to connect tool: \(error.localizedDescription)"
                isLoading = false
            }
            return false
        }
    }
    
    // Disconnect from a tool
    func disconnectTool(toolId: String) async -> Bool {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            // In a real implementation, you would make an API call to disconnect
            // For now, we'll simulate the disconnection
            
            // Simulate network request
            try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
            
            // Simulate success
            await MainActor.run {
                connectedToolIds.remove(toolId)
                isLoading = false
            }
            return true
        } catch {
            await MainActor.run {
                errorMessage = "Failed to disconnect tool: \(error.localizedDescription)"
                isLoading = false
            }
            return false
        }
    }
    
    // Check if all required tools are connected
    func areAllRequiredToolsConnected() -> Bool {
        let requiredTools = availableTools.filter { $0.isRequired }
        return requiredTools.allSatisfy { connectedToolIds.contains($0.id) }
    }
    
    // Save connected tools to UserDefaults
    func saveConnectedTools() {
        let connectedIdsArray = Array(connectedToolIds)
        UserDefaults.standard.set(connectedIdsArray, forKey: "connectedToolIds")
    }
    
    // Load connected tools from UserDefaults
    func loadConnectedTools() {
        if let connectedIdsArray = UserDefaults.standard.array(forKey: "connectedToolIds") as? [String] {
            connectedToolIds = Set(connectedIdsArray)
        }
    }
    
    // Mock tools for development and testing
    private func mockTools() -> [Tool] {
        return [
            Tool(
                id: "gmail",
                name: "Gmail",
                description: "Connect to your Gmail account to read and send emails",
                iconName: "envelope.fill",
                isRequired: true,
                connectionUrl: "https://api.example.com/connect/gmail"
            ),
            Tool(
                id: "calendar",
                name: "Calendar",
                description: "Connect to your calendar to schedule and manage events",
                iconName: "calendar",
                isRequired: false,
                connectionUrl: "https://api.example.com/connect/calendar"
            ),
            Tool(
                id: "drive",
                name: "Google Drive",
                description: "Connect to Google Drive to access your documents",
                iconName: "doc.fill",
                isRequired: false,
                connectionUrl: "https://api.example.com/connect/drive"
            ),
            Tool(
                id: "slack",
                name: "Slack",
                description: "Connect to Slack to send and receive messages",
                iconName: "message.fill",
                isRequired: false,
                connectionUrl: "https://api.example.com/connect/slack"
            ),
            Tool(
                id: "spotify",
                name: "Spotify",
                description: "Connect to Spotify to control music playback",
                iconName: "music.note",
                isRequired: false,
                connectionUrl: "https://api.example.com/connect/spotify"
            )
        ]
    }
}
