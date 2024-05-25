//
//  ElonMigoApp.swift
//  ElonMigo
//
//  Created by Aaron Ma on 5/25/24.
//

import SwiftUI

@main
struct ElonMigoApp: App {
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
