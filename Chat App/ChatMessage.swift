//
//  ChatMessage.swift
//  Chat App
//
//  Created by Conner Yoon on 2/13/26.
//

import Foundation

enum MessageRole {
    case user
    case assistant
}

struct ChatMessage: Identifiable {
    let id = UUID()
    let role: MessageRole
    var content: String
    let timestamp = Date()
    var isStreaming: Bool = false
}
