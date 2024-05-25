//
//  UserAnswer.swift
//  ElonMigo
//
//  Created by Aaron Ma on 5/25/24.
//

import Foundation

struct UserAnswer: Identifiable {
    let id = UUID()
    let question: Question
    let userAnswer: String
    let isCorrect: Bool
}
