//
//  ChatView.swift
//  Chat App
//
//  Created by Conner Yoon on 2/13/26.
//

import SwiftUI

struct ChatView: View {
    @State private var viewModel = ChatViewModel()
    @State private var speechManager = SpeechManager()
    @State private var inputText = ""
    @State private var showMemoryView = false
    @FocusState private var isInputFocused: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.messages) { message in
                                MessageBubbleView(message: message)
                                    .id(message.id)
                            }
                        }
                        .padding()
                    }
                    .onChange(of: viewModel.messages.count) {
                        scrollToBottom(proxy: proxy)
                    }
                    .onChange(of: viewModel.messages.last?.content) {
                        scrollToBottom(proxy: proxy)
                    }
                }

                Divider()

                // Live transcription overlay
                if speechManager.isRecording && !speechManager.transcribedText.isEmpty {
                    Text(speechManager.transcribedText)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                        .padding(.top, 8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .transition(.opacity)
                }

                HStack(alignment: .bottom, spacing: 8) {
                    TextField(
                        speechManager.isRecording ? "Listening..." : "Message...",
                        text: $inputText,
                        axis: .vertical
                    )
                    .lineLimit(1...5)
                    .textFieldStyle(.roundedBorder)
                    .focused($isInputFocused)
                    .onSubmit { send() }
                    .disabled(speechManager.isRecording)

                    // Mic button with hold-to-talk gesture
                    micButton

                    Button {
                        send()
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title)
                    }
                    .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isSending)
                }
                .padding()
            }
            .navigationTitle("Chat")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    VStack(alignment: .leading, spacing: 2) {
                        ProgressView(value: viewModel.contextUsagePercent)
                            .tint(viewModel.isNearContextLimit ? .red : .blue)
                            .frame(width: 100)
                        Text("\(viewModel.estimatedTokensUsed) / 4096 tokens")
                            .font(.caption2)
                            .foregroundStyle(viewModel.isNearContextLimit ? .red : .secondary)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 12) {
                        Button {
                            showMemoryView = true
                        } label: {
                            Image(systemName: "brain")
                        }
                        Button {
                            speechManager.autoReadEnabled.toggle()
                        } label: {
                            Image(systemName: speechManager.autoReadEnabled ? "speaker.wave.2.fill" : "speaker.slash")
                        }
                        Button("Clear") {
                            viewModel.clearConversation()
                            speechManager.stopSpeaking()
                        }
                    }
                }
            }
            .onChange(of: viewModel.messages.last?.isStreaming) { oldValue, newValue in
                if oldValue == true && newValue == false,
                   let lastMessage = viewModel.messages.last,
                   lastMessage.role == .assistant,
                   speechManager.autoReadEnabled {
                    speechManager.speak(lastMessage.content)
                }
            }
            .task {
                await speechManager.requestPermissions()
            }
            .sheet(isPresented: $showMemoryView) {
                MemoryView()
            }
        }
    }

    private var micButton: some View {
        Image(systemName: speechManager.isRecording ? "mic.fill" : "mic")
            .font(.title)
            .foregroundStyle(speechManager.isRecording ? .red : .blue)
            .symbolEffect(.pulse, isActive: speechManager.isRecording)
            .frame(width: 44, height: 44)
            .contentShape(Rectangle())
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !speechManager.isRecording && !viewModel.isSending && !speechManager.permissionsDenied {
                            speechManager.startRecording()
                        }
                    }
                    .onEnded { _ in
                        let text = speechManager.stopRecording()
                        if !text.isEmpty {
                            Task { await viewModel.sendMessage(text) }
                        }
                    }
            )
            .opacity(speechManager.permissionsDenied || viewModel.isSending ? 0.4 : 1.0)
            .allowsHitTesting(!speechManager.permissionsDenied && !viewModel.isSending)
    }

    private func send() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        inputText = ""
        Task { await viewModel.sendMessage(text) }
    }

    private func scrollToBottom(proxy: ScrollViewProxy) {
        if let lastMessage = viewModel.messages.last {
            withAnimation(.easeOut(duration: 0.2)) {
                proxy.scrollTo(lastMessage.id, anchor: .bottom)
            }
        }
    }
}

#Preview {
    ChatView()
}
