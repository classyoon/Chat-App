//
//  MemoryTool.swift
//  Chat App
//
//  Created by Conner Yoon on 2/14/26.
//

import Foundation
import FoundationModels

/// A tool that allows the assistant to store and retrieve memories about the user and conversation
final class MemoryTool: Tool {
    let name = "memory"
    let description = "Store or retrieve memories about the user, their preferences, past conversations, or important facts. Use this to remember things across conversations."
    
    @Generable
    struct Arguments {
        @Guide(description: "The action to perform: 'store' to save a memory, 'retrieve' to search memories, or 'list' to see all memories")
        let action: String
        
        @Guide(description: "For 'store': the memory to save (e.g., 'User's name is Alex'). For 'retrieve': search query (e.g., 'name'). Not needed for 'list'.")
        let content: String?
    }
    
    // Store memories in UserDefaults for persistence across app launches
    private let storageKey = "chat_memories"
    
    func call(arguments: Arguments) async throws -> String {
        switch arguments.action.lowercased() {
        case "store":
            guard let content = arguments.content, !content.isEmpty else {
                return "Error: No content provided to store"
            }
            return storeMemory(content)
            
        case "retrieve":
            guard let query = arguments.content, !query.isEmpty else {
                return "Error: No search query provided"
            }
            return retrieveMemories(matching: query)
            
        case "list":
            return listAllMemories()
            
        default:
            return "Error: Invalid action '\(arguments.action)'. Use 'store', 'retrieve', or 'list'"
        }
    }
    
    private func storeMemory(_ content: String) -> String {
        var memories = loadMemories()
        let timestamp = Date()
        let memory = StoredMemory(content: content, timestamp: timestamp)
        memories.append(memory)
        saveMemories(memories)
        return "Memory stored successfully: \"\(content)\""
    }
    
    private func retrieveMemories(matching query: String) -> String {
        let memories = loadMemories()
        
        // Search for memories containing the query (case-insensitive)
        let matches = memories.filter { memory in
            memory.content.localizedCaseInsensitiveContains(query)
        }
        
        if matches.isEmpty {
            return "No memories found matching '\(query)'"
        }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        
        let results = matches.map { memory in
            "\"\(memory.content)\" (stored \(formatter.string(from: memory.timestamp)))"
        }.joined(separator: "\n")
        
        return "Found \(matches.count) memory(s):\n\(results)"
    }
    
    private func listAllMemories() -> String {
        let memories = loadMemories()
        
        if memories.isEmpty {
            return "No memories stored yet"
        }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        
        let list = memories.enumerated().map { index, memory in
            "\(index + 1). \"\(memory.content)\" (stored \(formatter.string(from: memory.timestamp)))"
        }.joined(separator: "\n")
        
        return "All memories (\(memories.count) total):\n\(list)"
    }
    
    private func loadMemories() -> [StoredMemory] {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let memories = try? JSONDecoder().decode([StoredMemory].self, from: data) else {
            print("I forgot")
            return []
        }
        print(memories)
        return memories
    }
    
    private func saveMemories(_ memories: [StoredMemory]) {
        if let data = try? JSONEncoder().encode(memories) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
    
    private struct StoredMemory: Codable {
        let id: UUID
        let content: String
        let timestamp: Date
        
        init(content: String, timestamp: Date) {
            self.id = UUID()
            self.content = content
            self.timestamp = timestamp
        }
    }
}
