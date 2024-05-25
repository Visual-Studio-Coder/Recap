//
//  Question.swift
//  ElonMigo
//
//  Created by Aaron Ma on 5/25/24.
//

import Foundation

struct Question: Codable {
    let questionType: QuestionType
    let question: String
    let options: [QuestionOption]
    let userSelection: String
    
    enum QuestionType: Codable {
        case MCQ
        case FRQ
    }
}
