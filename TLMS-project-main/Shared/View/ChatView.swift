//
//  ChatView.swift
//  TLMS-project-main
//
//  Chat UI Component
//

import SwiftUI

struct ChatView: View {
    @ObservedObject var viewModel: ChatViewModel
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Gemini AI Assistant")
                    .font(.headline)
                    .foregroundColor(AppTheme.primaryText)
                
                Spacer()
                
                Button(action: {
                    withAnimation {
                        viewModel.isChatOpen = false
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(AppTheme.secondaryText)
                }
            }
            .padding()
            .background(AppTheme.groupedBackground)
            
            Divider()
            
            // Messages List
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.messages) { message in
                            MessageBubble(message: message)
                        }
                    }
                    .padding()
                }
                .onChange(of: viewModel.messages.count) { _ in
                    if let lastId = viewModel.messages.last?.id {
                        withAnimation {
                            proxy.scrollTo(lastId, anchor: .bottom)
                        }
                    }
                }
            }
            .background(AppTheme.background)
            
            Divider()
            
            // Input Area
            HStack(spacing: 12) {
                TextField("Ask anything...", text: $viewModel.inputText)
                    .textFieldStyle(.plain)
                    .padding(10)
                    .background(AppTheme.secondaryGroupedBackground)
                    .cornerRadius(20)
                    .focused($isInputFocused)
                    .onSubmit {
                        Task { await viewModel.sendMessage() }
                    }
                
                Button(action: {
                    Task { await viewModel.sendMessage() }
                }) {
                    if viewModel.isLoading {
                        ProgressView()
                            .tint(AppTheme.primaryBlue)
                    } else {
                        Image(systemName: "paperplane.fill")
                            .font(.title3)
                            .foregroundColor(viewModel.inputText.isEmpty ? AppTheme.secondaryText : AppTheme.primaryBlue)
                    }
                }
                .disabled(viewModel.inputText.isEmpty || viewModel.isLoading)
            }
            .padding()
            .background(AppTheme.groupedBackground)
        }
        .cornerRadius(16)
        .shadow(radius: 10)
    }
}

struct MessageBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 5) {
            if !message.isUser {
                Image(systemName: "sparkles") // AI Icon
                    .font(.caption)
                    .foregroundColor(AppTheme.primaryBlue)
                    .padding(6)
                    .background(AppTheme.primaryBlue.opacity(0.1))
                    .clipShape(Circle())
            } else {
                Spacer()
            }
            
            Text(LocalizedStringKey(message.text)) // Supports Markdown!
                .font(.system(size: 15))
                .foregroundColor(message.isUser ? .white : AppTheme.primaryText)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(message.isUser ? AppTheme.primaryBlue : AppTheme.secondaryGroupedBackground)
                .cornerRadius(16, corners: message.isUser ? [.topLeft, .topRight, .bottomLeft] : [.topLeft, .topRight, .bottomRight])
            
            if message.isUser {
                Spacer()
            }
        }
    }
}



struct FloatingChatButton: View {
    @ObservedObject var viewModel: ChatViewModel
    
    var body: some View {
        Button(action: {
            withAnimation(.spring()) {
                viewModel.toggleChat()
            }
        }) {
            Image(systemName: viewModel.isChatOpen ? "message.fill" : "sparkles")
                .font(.title2)
                .foregroundColor(.white)
                .padding()
                .background(AppTheme.primaryBlue)
                .clipShape(Circle())
                .shadow(radius: 4, x: 0, y: 4)
        }
    }
}
