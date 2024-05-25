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
        GeminiAPI.`init`(with: AppSettings.apiKey)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
