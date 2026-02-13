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
