//
//  ElonMigoApp.swift
//  ElonMigo
//
//  Created by Aaron Ma on 5/25/24.
//

import SwiftUI

@main
struct ElonMigoApp: App {
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
