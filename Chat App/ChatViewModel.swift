//
//  ChatViewModel.swift
//  Chat App
//
//  Created by Conner Yoon on 2/13/26.
//

import SwiftUI
import FoundationModels
import NaturalLanguage
import CoreLocation

@Observable
class ChatViewModel {
    var messages: [ChatMessage] = []
    var isSending = false

    private var session: LanguageModelSession
    private let systemInstructions = "You are a helpful, friendly assistant named ConPal. Keep responses concise and clear. Use the memory tool to remember the last few messages you've received. Greet the user by name after the first message."
    private let contextWindowSize = 4096
    private let locationManager = CLLocationManager()
    private let tools: [any Tool] = [GetCurrentTimeTool(), GetCurrentLocationTool(), CountLettersTool(), MemoryTool()]

    var estimatedTokensUsed: Int {
        let allText = systemInstructions + " " + messages.map(\.content).joined(separator: " ")
        let tokenizer = NLTokenizer(unit: .word)
        tokenizer.string = allText
        var wordCount = 0
        tokenizer.enumerateTokens(in: allText.startIndex..<allText.endIndex) { _, _ in
            wordCount += 1
            return true
        }
        return Int(Double(wordCount) * 1.3)
    }

    var contextUsagePercent: Double {
        min(Double(estimatedTokensUsed) / Double(contextWindowSize), 1.0)
    }

    var isNearContextLimit: Bool {
        contextUsagePercent > 0.8
    }

    init() {
        session = LanguageModelSession(tools: tools, instructions: systemInstructions)
        locationManager.requestWhenInUseAuthorization()
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
        session = LanguageModelSession(tools: tools, instructions: systemInstructions)
    }
}
