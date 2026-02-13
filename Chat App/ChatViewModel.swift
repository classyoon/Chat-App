//
//  ChatViewModel.swift
//  Chat App
//
//  Created by Conner Yoon on 2/13/26.
//

import SwiftUI
import FoundationModels

@Observable
class ChatViewModel {
    var messages: [ChatMessage] = []
    var isSending = false

    private var session: LanguageModelSession

    init() {
        let instructions = "You are a helpful, friendly assistant. Keep responses concise and clear."
        session = LanguageModelSession(instructions: instructions)
        Task { try? await session.prewarm() }
    }

    func checkAvailability() -> SystemLanguageModel.Availability {
        SystemLanguageModel.default.availability
    }

    func sendMessage(_ text: String) async {
        let userMessage = ChatMessage(role: .user, content: text)
        messages.append(userMessage)

        let assistantIndex = messages.count
        messages.append(ChatMessage(role: .assistant, content: "", isStreaming: true))

        isSending = true
        defer { isSending = false }

        do {
            var cumulative = ""
            let stream = session.streamResponse(to: text)
            for try await partial in stream {
                cumulative = partial.content
                messages[assistantIndex].content = cumulative
            }
            messages[assistantIndex].isStreaming = false
        } catch {
            messages[assistantIndex].content = "Sorry, something went wrong: \(error.localizedDescription)"
            messages[assistantIndex].isStreaming = false
        }
    }

    func clearConversation() {
        messages.removeAll()
        let instructions = "You are a helpful, friendly assistant. Keep responses concise and clear."
        session = LanguageModelSession(instructions: instructions)
    }
}
