//
//  GeminiAPI.swift
//  ElonMigo
//
//  Created by Aaron Ma on 5/25/24.
//

import GoogleGenerativeAI
import UIKit

class GeminiAPI {
    static var shared: GeminiAPI? = nil
    
    private var model: GenerativeModel?
    private var chat: Chat?
    private var apiKey: String
    
    @Published var computerResponse = ""
    
    private init(model: GenerativeModel? = nil, chat: Chat? = nil, apiKey: String, computerResponse: String = "") {
        self.model = model
        self.chat = chat
        self.apiKey = apiKey
        self.computerResponse = computerResponse
        initGemini()
    }
    
    static func `init`(with apiKey: String) {
        self.shared = GeminiAPI(apiKey: apiKey)
    }
    
    private func initGemini() {
        let config = GenerationConfig(temperature: 1, topP: 0.95, topK: 64, maxOutputTokens: 8192, responseMIMEType: "application/json")
        
        // TODO: more strict safety
        // https://ai.google.dev/gemini-api/docs/safety-settings
        self.model = GenerativeModel(name: "gemini-1.5-pro-latest", apiKey: apiKey, generationConfig: config, safetySettings: [SafetySetting(harmCategory: .harassment, threshold: .blockNone), SafetySetting(harmCategory: .hateSpeech, threshold: .blockNone), SafetySetting(harmCategory: .sexuallyExplicit, threshold: .blockNone), SafetySetting(harmCategory: .dangerousContent, threshold: .blockNone)], systemInstruction: "You are my teacher. Determine the subject of the notes and provide a JSON file with possible questions relating to the notes BASED ON THE EXAMPLE DATA I GIVE YOU. You may be asked to provide an explanation for a question or be asked to generate an entire quiz (most likely). For Multiple Choice Questions, you can mark as many answers as true.")
        
        if let model = self.model {
            self.chat = model.startChat(history: [])
        }
    }
    
    func sendMessage(userInput: String, selectedPhotosData: [Data]?, streamContent: Bool, generateQuiz: Bool, completion: @escaping (String) -> Void) {
        guard let chat = self.chat else { return }
        
        let quizPrompt: String = {
            if generateQuiz {
                return String("Use this JSON schema:")
            }
            
            return "Please follow the example JSON EXACTLY"
        }()
        
        if streamContent {
            Task {
                do {
                    if let imagesData = selectedPhotosData {
                        let response = chat.sendMessageStream("Notes: ", userInput, imagesData.compactMap { data in UIImage(data: data) })
                        
                        print("Gemini Interaction Log:")
                        
                        for try await chunk in response {
                            if let text = chunk.text {
                                print(text)
                                self.computerResponse += text
                            }
                            
                            DispatchQueue.main.async {
                                completion(self.computerResponse)
                            }
                        }
                    } else {
                        let response = chat.sendMessageStream("Notes: ", userInput, quizPrompt)
                        
                        print("Gemini Interaction Log:")
                        
                        for try await chunk in response {
                            if let text = chunk.text {
                                print(text)
                                self.computerResponse += text
                            }
                            
                            DispatchQueue.main.async {
                                completion(self.computerResponse)
                            }
                        }
                    }
                } catch {
                    print(error)
                    
                    DispatchQueue.main.async {
                        completion("Error: \(error)")
                    }
                }
            }
        } else {
            Task {
                do {}
            }
        }
    }
}
