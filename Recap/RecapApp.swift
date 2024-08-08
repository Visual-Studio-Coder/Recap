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
                    GeminiAPI.initialize(with: key, modelName: userPreferences.selectedOption, numberOfQuestions: userPreferences.numberOfQuestions)
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
                            
                            Text("Recap")
                                .font(.largeTitle)
                                .bold()
                                .foregroundStyle(.white)
                                .padding(.top, 5)
                                .shadow(radius: 50)
                            
                            Spacer()
                            
                            Text("Why did the AI quizzer app get top marks?\nBecause it aced all the byte-sized questions!")
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.white)
                                .padding(.bottom)
                            
                            Spacer()
                        }
                        
                        Spacer()
                    }
                }
        }
    }
}
