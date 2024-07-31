import Foundation

struct Explanation: Codable {
    struct Choice: Codable {
        let answer_option: String
        let correct: Bool
        let explanation: String
    }
    
    let question: String
    let choices: [Choice]
}
