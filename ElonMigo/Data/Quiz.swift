//
//  Quiz.swift
//  ElonMigo
//
//  Created by Aaron Ma on 5/25/24.
//

import Foundation

struct Quiz: Codable {
    let title: String
    let questions: [Question]
}
