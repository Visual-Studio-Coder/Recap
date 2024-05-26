import Foundation
struct UserAnswer: Identifiable {
    let id = UUID()
    let question: Question
    let userAnswer: [String]
    let isCorrect: Bool
}
