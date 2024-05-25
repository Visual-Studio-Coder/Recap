//
//  RecapApp.swift
//  Recap
//

//

import SwiftUI

@main
struct RecapApp: App {
    @AppStorage("apiKey") var apiKey = ""
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
