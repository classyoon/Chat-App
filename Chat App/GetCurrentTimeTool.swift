//
//  GetCurrentTimeTool.swift
//  Chat App
//
//  Created by Conner Yoon on 2/14/26.
//

import Foundation
import FoundationModels

struct GetCurrentTimeTool: Tool {
    let name = "getCurrentTime"
    let description = "Gets the current date and time."

    @Generable
    struct Arguments {}

    func call(arguments: Arguments) async throws -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .short
        return formatter.string(from: Date())
    }
}
