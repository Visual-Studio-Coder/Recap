import Foundation

struct PredefinedQuiz: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let prompt: String
    let links: [String]
    // let photos: [String] // Assuming photos are represented by their names or URLs
    let category: String
}
