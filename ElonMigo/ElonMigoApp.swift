//
//  RecapApp.swift
//  Recap
//

//

import SwiftUI

@main
struct RecapApp: App {
    @AppStorage("apiKey") var key: String = ""
    
    init() {
        GeminiAPI.initialize(with: key)
    }
    
    @StateObject private var quizStorage = QuizStorage()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(quizStorage)
        }
    }
}
