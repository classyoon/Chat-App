//
//  ContentView.swift
//  Chat App
//
//  Created by Conner Yoon on 2/13/26.
//

import SwiftUI
import FoundationModels

struct ContentView: View {
    var body: some View {
        switch SystemLanguageModel.default.availability {
        case .available:
            ChatView()
        default:
            ContentUnavailableView(
                "On-Device Model Unavailable",
                systemImage: "brain",
                description: Text("This app requires Apple Intelligence. Please ensure you're running iOS 26 or later on a supported device with Apple Intelligence enabled.")
            )
        }
    }
}

#Preview {
    ContentView()
}
