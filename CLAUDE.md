# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

iOS chat application powered by Apple's on-device Foundation Models framework (iOS 26+). Uses the same 3B-parameter LLM that powers Apple Intelligence — runs entirely on-device, free, no API keys needed. Xcode project located at `Chat App/Chat App.xcodeproj`.

## Build & Test Commands

```bash
# Build
xcodebuild -scheme "Chat App" -project "Chat App/Chat App.xcodeproj" -configuration Debug build

# Run on simulator
xcodebuild -scheme "Chat App" -project "Chat App/Chat App.xcodeproj" -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build

# Run all tests
xcodebuild -scheme "Chat App" -project "Chat App/Chat App.xcodeproj" test -destination 'platform=iOS Simulator,name=iPhone 17 Pro'

# Run a single test
xcodebuild -scheme "Chat App" -project "Chat App/Chat App.xcodeproj" test -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -only-testing:"Chat AppTests/Chat_AppTests/testExample"
```

## Architecture

**Entry point:** `Chat_AppApp.swift` — minimal `@main` App struct, renders `ContentView`.

**Availability gate:** `ContentView.swift` checks `SystemLanguageModel.default.availability`. Shows `ChatView` if the on-device model is available, otherwise shows a `ContentUnavailableView` with guidance.

**Data model:** `ChatMessage.swift` — `Identifiable` struct with `id`, `role` (`.user`/`.assistant`), `content`, `timestamp`, and `isStreaming` flag. No persistence (conversation resets on launch).

**ViewModel:** `ChatViewModel.swift` — `@Observable` class managing a `LanguageModelSession` (from `FoundationModels`). Handles sending messages, streaming responses via `session.streamResponse(to:)`, prewarming the model, and clearing conversations.

**Views:**
- `ChatView.swift` — main chat UI with `ScrollViewReader` + `LazyVStack` for messages, auto-scrolling, expanding text input, and a Clear toolbar button
- `MessageBubbleView.swift` — styled chat bubbles (user=blue/right, assistant=gray/left) with streaming indicator

**Capabilities configured:** iCloud CloudKit sync and push notifications are enabled in entitlements/Info.plist.

## Key Build Settings

- Deployment target: iOS 26.2 (iPhone + iPad)
- Swift concurrency: `MainActor` default actor isolation enabled (`SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`)
- Bundle ID: `con.yoon.Chat-App`
- No external dependencies — pure Apple frameworks
- Uses `PBXFileSystemSynchronizedRootGroup` — new files on disk are auto-detected by Xcode

## Key Technical Notes

- All types are implicitly `@MainActor` due to build settings. The streaming `for try await` loop runs on MainActor; `LanguageModelSession` does heavy work internally off-thread.
- The on-device model has a ~4,096 token context window. The Clear button lets users reset when conversations get long.
- Foundation Models framework is only available on iOS 26+ devices with Apple Intelligence enabled. The Simulator will show the unavailability screen.

## On Commit

When committing changes, summarize the changes and append a new entry to `journal.md`. Each entry should include the date and a concise summary of what changed.
