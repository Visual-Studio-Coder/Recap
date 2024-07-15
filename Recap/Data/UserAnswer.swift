import Foundation

struct UserAnswer: Identifiable, Codable {
    let id = UUID()
    let question: Question
    let userAnswer: [String]
    let isCorrect: Bool
    let correctAnswer: String?
}

struct GradingResult: Codable {
    var expectedAnswer: String
    var isCorrect: Bool
    var feedback: String
}
