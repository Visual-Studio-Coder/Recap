// Copyright 2024-2025 Vaibhav Satishkumar
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import SwiftUI

@main
struct RecapApp: App {
    @Environment(\.colorScheme) var colorScheme
    
    @AppStorage("apiKey") var key: String = ""
    
    
    @StateObject private var quizStorage = QuizStorage()
    @StateObject private var userPreferences = UserPreferences()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(userPreferences)
                .environmentObject(quizStorage)
                .onAppear {
                    Task {
                        await quizStorage.load()
                    }
                }
                .onAppear {
                    GeminiAPI.initialize(with: userPreferences.apiKey, modelName: userPreferences.selectedOption, selectedLanguage: userPreferences.selectedLanguage, safetySettings: userPreferences.safetySettings, numberOfQuestions: userPreferences.numberOfQuestions)
                }
                .splashView {
                    ZStack {
                        LinearGradient(colors: [.brown.opacity(0.1), .brown.opacity(0.2), .brown.opacity(0.3), .brown.opacity(0.4), .brown.opacity(0.5), .brown.opacity(0.6), .brown.opacity(0.7), .brown.opacity(0.8), .brown.opacity(0.9), .brown], startPoint: .topLeading, endPoint: .bottomTrailing)
                            .ignoresSafeArea()
                        
                        VStack {
                            Spacer()
                            
                            Spacer()
                            
                            Image(uiImage: Bundle.main.icon ?? UIImage())
                                .resizable()
                                .frame(width: 150, height: 150)
                                .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                                .shadow(color: colorScheme == .dark ? .brown : .brown.opacity(0.1), radius: 50)
                            
                            Spacer()

                            Text("Recap")
                                .font(.largeTitle)
                                .bold()
                                .foregroundStyle(.white)
                                .padding(.top, 5)
                                .shadow(radius: 50)
                            
                            Spacer()
                        }
                        
                        Spacer()
                    }
                }
        }
    }
}
