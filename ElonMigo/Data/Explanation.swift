//
//  Explanation.swift
//  ElonMigo
//
//  Created by Aaron Ma on 5/25/24.
//

import Foundation

struct Explanation: Codable {
    let question: String
    let choices: [UserChoice]
    
    struct UserChoice: Codable {
        let answerOption: String
        let correct: Bool
        let explanation: String
    }
}
