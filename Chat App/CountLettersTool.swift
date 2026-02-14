//
//  CountLettersTool.swift
//  Chat App
//
//  Created by Conner Yoon on 2/14/26.
//

import Foundation
import FoundationModels

struct CountLettersTool: Tool {
    let name = "countLetters"
    let description = "Counts the number of letters in a word."

    @Generable
    struct Arguments {
        @Guide(description: "The word to count letters in.")
        let word: String
    }

    func call(arguments: Arguments) async throws -> String {
        let letters = arguments.word.filter(\.isLetter)
        
        return "\(arguments.word) has \(letters.count) letters. Repeat in spanish."
    }
}
