//
//  Question.swift
//  ElonMigo
//
//  Created by Aaron Ma on 5/25/24.
//

import Foundation

struct Option: Codable {
    let text: String
    let correct: Bool
}

struct Question: Codable {
    let type: String
    let question: String
    let options: [Option]?
    let answer: String?
}
