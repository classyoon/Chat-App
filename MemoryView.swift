//
//  MemoryView.swift
//  Chat App
//
//  Created by Conner Yoon on 2/14/26.
//

import SwiftUI

struct MemoryView: View {
    @State private var memories: [Memory] = []
    @State private var showDeleteConfirmation = false
    @State private var memoryToDelete: Memory?
    
    private let storageKey = "chat_memories"
    
    var body: some View {
        NavigationStack {
            Group {
                if memories.isEmpty {
                    ContentUnavailableView(
                        "No Memories",
                        systemImage: "brain",
                        description: Text("The assistant hasn't stored any memories yet. Memories will appear here when the assistant learns about you.")
                    )
                } else {
                    List {
                        ForEach(memories) { memory in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(memory.content)
                                    .font(.body)
                                
                                Text(memory.timestamp, style: .relative)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 4)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    memoryToDelete = memory
                                    showDeleteConfirmation = true
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Memories")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if !memories.isEmpty {
                        Button(role: .destructive) {
                            clearAllMemories()
                        } label: {
                            Text("Clear All")
                        }
                    }
                }
            }
            .alert("Delete Memory?", isPresented: $showDeleteConfirmation) {
                Button("Cancel", role: .cancel) {
                    memoryToDelete = nil
                }
                Button("Delete", role: .destructive) {
                    if let memory = memoryToDelete {
                        deleteMemory(memory)
                    }
                    memoryToDelete = nil
                }
            } message: {
                if let memory = memoryToDelete {
                    Text("Are you sure you want to delete this memory?\n\n\"\(memory.content)\"")
                }
            }
            .onAppear {
                loadMemories()
            }
        }
    }
    
    private func loadMemories() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([Memory].self, from: data) else {
            memories = []
            return
        }
        // Sort by most recent first
        memories = decoded.sorted { $0.timestamp > $1.timestamp }
    }
    
    private func deleteMemory(_ memory: Memory) {
        memories.removeAll { $0.id == memory.id }
        saveMemories()
    }
    
    private func clearAllMemories() {
        memories.removeAll()
        UserDefaults.standard.removeObject(forKey: storageKey)
    }
    
    private func saveMemories() {
        if let data = try? JSONEncoder().encode(memories) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
}

struct Memory: Codable, Identifiable {
    let id: UUID
    let content: String
    let timestamp: Date
    
    init(id: UUID = UUID(), content: String, timestamp: Date) {
        self.id = id
        self.content = content
        self.timestamp = timestamp
    }
}

#Preview {
    MemoryView()
}
