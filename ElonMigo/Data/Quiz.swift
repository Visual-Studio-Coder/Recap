//
//  Quiz.swift
//  ElonMigo
//
//  Created by Aaron Ma on 5/25/24.
//

import Foundation

//struct Quiz: Codable {
////    var id = UUID()
//    var quiz_title: String
//    let questions: [Question]
////    var userCorrect: Int = 0
//}
struct Quiz: Codable {
    let quiz_title: String
    let questions: [Question]
}

@MainActor
class QuizStorage: ObservableObject {
    @Published var history: [Quiz] = []

    private static func fileURL() throws -> URL {
        try FileManager.default.url(for: .documentDirectory,
                                    in: .userDomainMask,
                                    appropriateFor: nil,
                                    create: false)
        .appendingPathComponent("quiz.data")
    }

    func load() async throws {
        let task = Task<[Quiz], Error> {
            let fileURL = try Self.fileURL()
            guard let data = try? Data(contentsOf: fileURL) else {
                return []
            }
            let history = try JSONDecoder().decode([Quiz].self, from: data)
            return history
        }
        let history = try await task.value
        self.history = history
    }

    func save(history: [Quiz]) async throws {
        let task = Task {
            let data = try JSONEncoder().encode(history)
            let outfile = try Self.fileURL()
            try data.write(to: outfile)
        }
        _ = try await task.value
    }

//    func indexOfQuiz(withID id: UUID) -> Int? {
//        return history.firstIndex(where: { $0.id == id })
//    }
}
