//
//  Explanation.swift
//  Recap
//
//  Created by Aaron Ma on 5/25/24.
//

import Foundation

struct Explanation: Codable {
    struct Choice: Codable {
        let answer_option: String
        let correct: Bool
        let explanation: String
    }
    
    let question: String
    let choices: [Choice]
}
