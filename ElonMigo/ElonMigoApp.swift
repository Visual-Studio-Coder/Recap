//
//  RecapApp.swift
//  Recap
//

//

import SwiftUI

@main
struct RecapApp: App {
    @AppStorage("apiKey") var key: String = "";
    init() {
        GeminiAPI.initialize(with: key)
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
