//
//  AstroAIView.swift
//  HabitMissions
//
//  Created by David Springean on 18.05.25.
//


import SwiftUI

struct AstroAIView: View {
    @State private var messageText = ""
    @State private var messages: [Message] = [
        Message(id: UUID().uuidString, text: "Hello Captain! How can I assist with your habit missions today?", isUser: false)
    ]
    
    var body: some View {
        VStack {
            // Header
            HStack {
                Spacer()
                Text("AstroAI")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Button {
                    // Dismiss
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .padding()
            .background(AppColors.spaceBlue)
            
            // Messages
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(messages) { message in
                        MessageBubble(message: message)
                    }
                }
                .padding()
            }
            
            // Input area
            HStack {
                TextField("Message AstroAI...", text: $messageText)
                    .padding(12)
                    .background(AppColors.spaceGray.opacity(0.3))
                    .cornerRadius(18)
                    .foregroundColor(.white)
                
                Button {
                    sendMessage()
                } label: {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 18))
                        .foregroundColor(messageText.isEmpty ? .gray : AppColors.starYellow)
                }
                .disabled(messageText.isEmpty)
                .padding(.leading, 8)
            }
            .padding()
        }
        .background(AppColors.spaceDark)
    }
    
    private func sendMessage() {
        let userMessage = Message(id: UUID().uuidString, text: messageText, isUser: true)
        messages.append(userMessage)
        
        // Placeholder for AI response
        let aiResponseText = "This is a placeholder for AstroAI's response. In a real implementation, this would come from your AI service."
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let aiResponse = Message(id: UUID().uuidString, text: aiResponseText, isUser: false)
            messages.append(aiResponse)
        }
        
        messageText = ""
    }
}

struct Message: Identifiable {
    let id: String
    let text: String
    let isUser: Bool
}

struct MessageBubble: View {
    let message: Message
    
    var body: some View {
        HStack {
            if message.isUser { Spacer() }
            
            Text(message.text)
                .padding(12)
                .background(
                    message.isUser ? AppColors.cosmicPurple : AppColors.spaceGray.opacity(0.7)
                )
                .foregroundColor(.white)
                .cornerRadius(16)
                .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: message.isUser ? .trailing : .leading)
            
            if !message.isUser { Spacer() }
        }
    }
}