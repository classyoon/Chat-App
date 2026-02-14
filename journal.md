# Journal

## 2026-02-13

- Added `CLAUDE.md` with project overview, build/test commands, architecture notes, and key build settings to guide future Claude Code sessions.
- Converted template CRUD app to Foundation Models chat app:
  - Created `ChatMessage.swift` (message model with role, content, streaming state)
  - Created `ChatViewModel.swift` (manages `LanguageModelSession`, streaming responses, conversation state)
  - Created `MessageBubbleView.swift` (styled chat bubbles — user blue/right, assistant gray/left)
  - Created `ChatView.swift` (main chat UI with auto-scrolling messages and input bar)
  - Rewrote `ContentView.swift` (availability gate for on-device model → ChatView)
  - Rewrote `Chat_AppApp.swift` (stripped SwiftData ModelContainer)
  - Deleted `Item.swift` (no longer needed)
  - Updated `CLAUDE.md` to reflect new architecture
- Added context window usage tracker:
  - `ChatViewModel.swift`: Estimate token usage via `NaturalLanguage` tokenizer, expose usage percent and near-limit flag; extract system instructions to a shared property
  - `ChatView.swift`: Added toolbar progress bar and token count label that turns red near the 4096-token limit
- Added voice interaction with hold-to-talk input and auto-read output:
  - Created `SpeechManager.swift`: `@Observable` class with on-device speech-to-text (AVAudioEngine + SFSpeechRecognizer) and text-to-speech (AVSpeechSynthesizer)
  - Updated `ChatView.swift`: Hold-to-talk mic button via DragGesture, live transcription overlay, auto-read toggle in toolbar, TTS triggered on streaming completion
  - Updated `Info.plist`: Added NSMicrophoneUsageDescription and NSSpeechRecognitionUsageDescription
- Added `README.md` with project overview, features, requirements, architecture, and build instructions

## 2026-02-14

- Added Foundation Models tools to extend on-device LLM capabilities:
  - Created `GetCurrentTimeTool.swift`: Tool that returns the current date and time via DateFormatter
  - Created `GetCurrentLocationTool.swift`: Tool that gets the user's city/location using CLLocationUpdate.liveUpdates() and CLGeocoder reverse geocoding
  - Created `CountLettersTool.swift`: Tool that accurately counts letters in a word (compensates for LLM character-counting weakness)
  - Created `MemoryTool.swift`: Tool for persisting conversation context across messages
  - Created `MemoryView.swift`: Sheet view for viewing stored memories, accessible via brain icon in toolbar
- Updated `ChatViewModel.swift`: Registered all tools with LanguageModelSession, added CoreLocation import and location authorization request, updated system instructions with assistant name "ConPal"
- Updated `ChatView.swift`: Added brain toolbar button and MemoryView sheet presentation
- Updated `Info.plist`: Added NSLocationWhenInUseUsageDescription for location permission
