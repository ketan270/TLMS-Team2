//
//  ChatViewModel.swift
//  TLMS-project-main
//
//  ViewModel for Gemini Chat Interface
//

import SwiftUI
import Combine

@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var inputText: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isChatOpen: Bool = false // Controls visibility
    
    private let service = GeminiService.shared
    
    init() {
        // Initial welcome message
        messages.append(ChatMessage(text: "Hi! I'm your AI learning assistant. How can I help you today?", isUser: false))
    }
    
    func sendMessage() async {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        
        // Add user message
        let userMessage = ChatMessage(text: text, isUser: true)
        messages.append(userMessage)
        inputText = ""
        errorMessage = nil
        isLoading = true
        
        // Add thinking placeholder
        let thinkingMessage = ChatMessage(text: "Thinking...", isUser: false, isThinking: true)
        messages.append(thinkingMessage)
        
        // Check for commands
        if text.caseInsensitiveCompare("/models") == .orderedSame {
            do {
                let modelsList = try await service.listModels()
                 // Remove thinking message
                messages.removeAll { $0.id == thinkingMessage.id }
                
                // Add AI response
                let aiMessage = ChatMessage(text: modelsList, isUser: false)
                messages.append(aiMessage)
            } catch {
                messages.removeAll { $0.id == thinkingMessage.id }
                let errorMsg = ChatMessage(text: "Failed to list models: \(error.localizedDescription)", isUser: false)
                messages.append(errorMsg)
            }
            isLoading = false
            return
        }
        
        do {
            let responseText = try await service.sendMessage(text)
            
            // Remove thinking message
            messages.removeAll { $0.id == thinkingMessage.id }
            
            // Add AI response
            let aiMessage = ChatMessage(text: responseText, isUser: false)
            messages.append(aiMessage)
            
        } catch {
            // Remove thinking message
            messages.removeAll { $0.id == thinkingMessage.id }
            
            errorMessage = error.localizedDescription
            let errorMsg = ChatMessage(text: "Error: \(error.localizedDescription)", isUser: false)
            messages.append(errorMsg)
        }
        
        isLoading = false
    }
    
    func toggleChat() {
        isChatOpen.toggle()
    }
}
