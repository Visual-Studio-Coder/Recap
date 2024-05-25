//
//  Question.swift
//  Recap
//

//

import Foundation

struct Question: Codable {
    let questionType: QuestionType
    let question: String
    let options: [QuestionOption]
    let answer: String
    var userSelection: String = ""
    
    enum QuestionType: Codable {
        case MCQ
        case FRQ
    }
}
