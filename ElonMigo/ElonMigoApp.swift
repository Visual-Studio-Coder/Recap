//
//  ElonMigoApp.swift
//  ElonMigo
//
//  Created by Aaron Ma on 5/25/24.
//

import SwiftUI

@main
struct ElonMigoApp: App {
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
