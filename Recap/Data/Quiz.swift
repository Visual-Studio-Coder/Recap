import CoreTransferable
import Foundation
import UniformTypeIdentifiers

struct Quiz: Codable {
    let quiz_title: String
    let questions: [Question]
    var userAnswers: [UserAnswer]?  // Optional to handle quizzes without answers
    var userPrompt: String?
    var userLinks: [String]?
    var userPhotos: [Data]?
}

struct ExportableQuiz: Codable, Transferable {
    var quiz: Quiz
    //let prompt: String?
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .recapExportType)
    }
}

@MainActor
class QuizStorage: ObservableObject {
    @Published var history: [Quiz] = []
    
    private static func fileURL() throws -> URL {
        try FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        )
        .appendingPathComponent("quiz.data")
    }
    
    func load() async {
        do {
            let fileURL = try Self.fileURL()
            let data = try Data(contentsOf: fileURL)
            let history = try JSONDecoder().decode([Quiz].self, from: data)
            DispatchQueue.main.async {
                self.history = history
            }
        } catch {
            print("Failed to load quizzes: \(error)")
        }
    }
    
    func save(history: [Quiz]) async {
        do {
            let data = try JSONEncoder().encode(history)
            let outfile = try Self.fileURL()
            try data.write(to: outfile)
        } catch {
            print("Failed to save quizzes: \(error)")
        }
    }
    
    func addQuiz(_ quiz: Quiz, userAnswers: [UserAnswer], userPrompt: String, userLinks: [String], userPhotos: [Data]) async {
        var newQuiz = quiz
        newQuiz.userAnswers = userAnswers  // Assign user answers to the quiz
        newQuiz.userLinks = userLinks
        newQuiz.userPrompt = userPrompt
        newQuiz.userPhotos = userPhotos
        history.append(newQuiz)
        await save(history: history)
    }
}
