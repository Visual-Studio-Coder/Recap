//
//  Question.swift
//  Recap
//

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
