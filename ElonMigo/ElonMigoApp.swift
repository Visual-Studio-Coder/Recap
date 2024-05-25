//
//  RecapApp.swift
//  Recap
//

//

import SwiftUI

@main
struct RecapApp: App {
    @AppStorage("apiKey") var apiKey = ""
    
//    init() {
//        GeminiAPI.`init`(with: apiKey)
//    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
