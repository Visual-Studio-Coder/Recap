import Foundation

struct PredefinedQuiz: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let prompt: String
    let links: [String]
    let category: String
}
