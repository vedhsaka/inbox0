//
//  HeaderView.swift
//  Possam
//
//  Created by Akash Thakur on 4/20/25.
//


import SwiftUI


// MARK: - Action Button View
struct ActionButtonView: View {
    let isCallActive: Bool
    let onStartTapped: () -> Void
    let onStopTapped: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = false
                }
                if isCallActive {
                    onStopTapped()
                } else {
                    onStartTapped()
                }
            }
        }) {
            ZStack {
                Circle()
                    .fill(isCallActive ? Color.appRed : Color.appAccent)
                    .frame(width: 64, height: 64)
                    .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                
                if isCallActive {
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: 20, height: 20)
                        .cornerRadius(2)
                } else {
                    Image(systemName: "mic.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.white)
                }
            }
            .scaleEffect(isPressed ? 0.9 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Message List View
struct MessageListView: View {
    let messages: [ChatMessage]
    
    var body: some View {
        ScrollViewReader { scrollProxy in
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(messages) { message in
                        MessageBubbleView(message: message)
                            .id(message.id)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
            .onChange(of: messages.count) { _ in
                if let lastMessage = messages.last {
                    withAnimation {
                        scrollProxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
        }
    }
}

// MARK: - Message Bubble View
struct MessageBubbleView: View {
    let message: ChatMessage
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            if message.type == .user {
                Spacer()
            }
            
            // Icon for non-user messages
            if message.type != .user {
                Image(systemName: message.icon)
                    .font(.system(size: 24))
                    .foregroundColor(message.iconColor)
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                    )
            }
            
            // Message bubble
            VStack(alignment: message.type == .user ? .trailing : .leading, spacing: 4) {
                Text(message.text)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(message.textColor)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(message.bubbleColor)
                            .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 1)
                    )
                
                // Optional timestamp
                if message.type == .user || message.type == .assistant {
                    Text(formattedTime(message.timestamp))
                        .font(.system(size: 11, weight: .light))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 4)
                }
            }
            .frame(maxWidth: 280, alignment: message.type == .user ? .trailing : .leading)
            
            // User icon
            if message.type == .user {
                Image(systemName: message.icon)
                    .font(.system(size: 24))
                    .foregroundColor(message.iconColor)
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                    )
            }
            
            if message.type != .user {
                Spacer()
            }
        }
        .padding(.bottom, 2)
        .transition(message.type == .user ? 
            .asymmetric(
                insertion: .slide.combined(with: .opacity).animation(.spring(response: 0.3, dampingFraction: 0.7)),
                removal: .opacity.animation(.easeOut(duration: 0.2))
            ) :
            .asymmetric(
                insertion: .scale.combined(with: .opacity).animation(.spring(response: 0.4, dampingFraction: 0.7)),
                removal: .opacity.animation(.easeOut(duration: 0.2))
            )
        )
    }
    
    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Audio Wave View
struct AudioWaveView: View {
    let isActive: Bool
    let level: Double
    let barColor: Color
    
    @State private var animatedBars: [AudioBar] = []
    
    // Number of bars in the waveform
    private let barCount = 10
    
    var body: some View {
        HStack(alignment: .center, spacing: 4) {
            ForEach(animatedBars) { bar in
                RoundedRectangle(cornerRadius: 2)
                    .fill(barColor.opacity(isActive ? 1.0 : 0.3))
                    .frame(width: 6, height: bar.height)
                    .animation(
                        .spring(response: 0.3, dampingFraction: 0.6)
                        .delay(bar.delay),
                        value: bar.height
                    )
            }
        }
        .onAppear {
            // Initialize the bars
            for i in 0..<barCount {
                animatedBars.append(AudioBar(height: 5, delay: Double(i) * 0.05))
            }
        }
        .onChange(of: level) { newLevel in
            if isActive {
                // Update the heights based on the level
                for i in 0..<animatedBars.count {
                    let sinValue = sin(Double(i) * 0.8 + CACurrentMediaTime() * 4)
                    let heightMultiplier = abs(sinValue) * 0.8 + 0.2
                    let newHeight = 5 + 35 * newLevel * heightMultiplier
                    
                    if i < animatedBars.count {
                        animatedBars[i].height = newHeight
                        animatedBars[i].delay = Double(i) * 0.02
                    }
                }
            } else {
                // Reset to minimal height when not speaking
                for i in 0..<animatedBars.count {
                    if i < animatedBars.count {
                        animatedBars[i].height = 5
                    }
                }
            }
        }
    }
}
