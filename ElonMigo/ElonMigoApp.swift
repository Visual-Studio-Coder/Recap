//
//  ElonMigoApp.swift
//  ElonMigo
//
//  Created by Aaron Ma on 5/25/24.
//

import SwiftUI

@main
struct ElonMigoApp: App {
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
