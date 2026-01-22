//
//  ChatMessage.swift
//  TLMS-project-main
//
//  Model for Chat Interface
//

import Foundation

struct ChatMessage: Identifiable, Equatable {
    let id = UUID()
    let text: String
    let isUser: Bool
    let timestamp = Date()
    var isThinking: Bool = false
    
    static func == (lhs: ChatMessage, rhs: ChatMessage) -> Bool {
        return lhs.id == rhs.id && lhs.text == rhs.text && lhs.isThinking == rhs.isThinking
    }
}
