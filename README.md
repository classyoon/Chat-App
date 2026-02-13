# Chat App

An iOS chat application powered by Apple's on-device **Foundation Models** framework (iOS 26+). Uses the same 3B-parameter LLM that powers Apple Intelligence — runs entirely on-device, free, no API keys needed.

## Features

- **On-device AI chat** — streaming responses from Apple's built-in language model
- **Hold-to-talk voice input** — hold the mic button to dictate, release to auto-send
- **Auto-read responses** — assistant messages are spoken aloud via text-to-speech (toggleable)
- **Context window tracker** — visual progress bar showing token usage against the ~4,096 token limit
- **Fully private** — all processing happens on-device, nothing leaves your phone

## Requirements

- iOS 26+ device with Apple Intelligence enabled
- Xcode 26+

> **Note:** The on-device model is not available in the Simulator. Running there will show an unavailability screen.

## Architecture

```
Chat App/
├── Chat_AppApp.swift        # @main entry point
├── ContentView.swift        # Availability gate for on-device model
├── ChatView.swift           # Main chat UI with voice controls
├── ChatViewModel.swift      # LanguageModelSession management & streaming
├── ChatMessage.swift        # Message data model
├── MessageBubbleView.swift  # Styled chat bubbles
└── SpeechManager.swift      # STT (Speech framework) + TTS (AVSpeechSynthesizer)
```

- **No external dependencies** — pure Apple frameworks (FoundationModels, Speech, AVFoundation, SwiftUI)
- **No API keys** — everything runs on-device
- **No persistence** — conversations reset on launch

## Build

```bash
xcodebuild -scheme "Chat App" -project "Chat App/Chat App.xcodeproj" -configuration Debug build
```

## License

MIT
