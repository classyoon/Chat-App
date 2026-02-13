# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

iOS chat application built with Swift 5.0, SwiftUI, and SwiftData. Xcode project located at `Chat App/Chat App.xcodeproj`. Currently a fresh scaffold with basic item CRUD — intended to evolve into a full chat/messaging app.

## Build & Test Commands

```bash
# Build
xcodebuild -scheme "Chat App" -project "Chat App/Chat App.xcodeproj" -configuration Debug build

# Run on simulator
xcodebuild -scheme "Chat App" -project "Chat App/Chat App.xcodeproj" -destination 'platform=iOS Simulator,name=iPhone 16' build

# Run all tests
xcodebuild -scheme "Chat App" -project "Chat App/Chat App.xcodeproj" test -destination 'platform=iOS Simulator,name=iPhone 16'

# Run a single test
xcodebuild -scheme "Chat App" -project "Chat App/Chat App.xcodeproj" test -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:"Chat AppTests/Chat_AppTests/testExample"
```

## Architecture

**Entry point:** `Chat_AppApp.swift` — creates a SwiftData `ModelContainer` with SQLite persistence and injects it into the SwiftUI view hierarchy via `.modelContainer()`.

**Data flow:** SwiftData `@Model` classes are queried in views using `@Query` and mutated through `@Environment(\.modelContext)`. Currently there is one model (`Item`) with a single `timestamp` property.

**UI:** `ContentView` uses `NavigationSplitView` for a master-detail layout. Items are listed, added, and deleted inline.

**Capabilities configured:** iCloud CloudKit sync and push notifications are enabled in entitlements/Info.plist.

## Key Build Settings

- Deployment target: iOS 26.2 (iPhone + iPad)
- Swift concurrency: `MainActor` default actor isolation enabled
- Bundle ID: `con.yoon.Chat-App`
- No external dependencies — pure Apple frameworks

## On Commit

When committing changes, summarize the changes and append a new entry to `journal.md`. Each entry should include the date and a concise summary of what changed.
