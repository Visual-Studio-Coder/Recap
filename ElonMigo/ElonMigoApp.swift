//
//  RecapApp.swift
//  Recap
//

//

import SwiftUI

@main
struct RecapApp: App {
    @AppStorage("apiKey") private var apiKey = AppSettings.apiKey
    
    init() {
        GeminiAPI.`init`(with: apiKey)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
