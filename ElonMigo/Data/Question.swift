//
//  Question.swift
//  ElonMigo
//
//  Created by Aaron Ma on 5/25/24.
//

import Foundation

struct Question: Codable {
    let questionType: String
    let question: String
    let options: [QuestionOption]
    let answer: String
    
    enum QuestionType {
        case MCQ
        case FRQ
    }
}
