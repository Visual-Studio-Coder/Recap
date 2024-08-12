import GoogleGenerativeAI
import UIKit

class GeminiAPI: ObservableObject {
    
    static var shared: GeminiAPI? = nil
    
    public var model: GenerativeModel?
    private var chat: Chat?
    @Published var computerResponse = ""
    
    private var key: String
    private var modelName: String
    private var safetySettings: Bool
    private var numberOfQuestions: Int
    
    private init(key: String, modelName: String, safetySettings: Bool, numberOfQuestions: Int) {
        self.key = key
        self.modelName = modelName
        self.numberOfQuestions = numberOfQuestions
        self.safetySettings = safetySettings
        initializeModel(modelName: modelName, safetySettings: safetySettings)
    }
    
    static func initialize(with key: String, modelName: String, safetySettings: Bool, numberOfQuestions: Int) {
        self.shared = GeminiAPI(key: key, modelName: modelName, safetySettings: safetySettings, numberOfQuestions: numberOfQuestions)
    }
    
    func clearChat() {
        chat?.history.removeAll()
    }
    
    private func initializeModel(modelName: String, safetySettings: Bool) {
        let config = GenerationConfig(
            responseMIMEType: "application/json"
        )
        
        self.model = GenerativeModel(
            name: modelName,
            apiKey: key,
            generationConfig: config,
            safetySettings: [
                SafetySetting(harmCategory: .harassment, threshold: safetySettings ? .blockOnlyHigh : .blockNone),
                SafetySetting(harmCategory: .hateSpeech, threshold: safetySettings ? .blockOnlyHigh : .blockNone),
                SafetySetting(harmCategory: .sexuallyExplicit, threshold: safetySettings ? .blockOnlyHigh : .blockNone),
                SafetySetting(harmCategory: .dangerousContent, threshold: safetySettings ? .blockOnlyHigh : .blockNone),
            ],
            systemInstruction:
                "You are my teacher. Determine the subject of the notes and provide a json with possible questions relating to the notes BASED ON THE EXAMPLE JSON I GIVE YOU. You may be asked to provide an explanation for a question or be asked to generate an entire quiz (more likely). For Multiple choice questions, you can mark as many answers as true, but if all answers are true and you decide to use \"all of the above\", PLEASE MAKE THE OTHER ANSWERS FALSE. Also, make sure to use the exact same property names, but just change the contents/values of each property based on the notes provided. Also make sure that all the information is true and taken purely from the notes. Use GitHub Flavored Markdown (no HTML markdown or LateX is supported) whenever possible in the questions and answers, but replace all occurences of ``` with <`>"
        )
        
        if let model = self.model {
            self.chat = model.startChat(history: [])
        }
    }
    
    func sendMessage(
        userInput: String, selectedPhotosData: [Data]?, streamContent: Bool, generateQuiz: Bool,
        completion: @escaping (String) -> Void
    ) {
        guard let chat = self.chat else { return }
        
        let quizPrompt: String = {
            if generateQuiz {
                return String("\n\nUse this JSON schema to generate \(numberOfQuestions == 0 ? 5 : numberOfQuestions) questions, and make sure to randomize the order of the options such that the correct answer is not always in the same place:\n\n{\n  \"quiz_title\": \"Sample Quiz\",\n  \"questions\": [\n    {\n      \"type\": \"multiple_choice\",\n      \"question\": \"What is the capital of France?\",\n      \"options\": [\n        {\"text\": \"Paris\", \"correct\": true},\n        {\"text\": \"London\",  \"correct\": false},\n        {\"text\": \"Berlin\", \"correct\": false},\n        {\"text\": \"Rome\", \"correct\": false}\n      ]\n    },\n    {\n      \"type\": \"multiple_choice\",\n      \"question\": \"What is the largest planet in our solar system?\",\n      \"options\": [\n        {\"text\": \"Earth\", \"correct\": false},\n        {\"text\": \"Saturn\", \"correct\": false},\n        {\"text\": \"Jupiter\", \"correct\": true},\n        {\"text\": \"Uranus\", \"correct\": false}\n      ]\n    },\n    {\n      \"type\": \"free_answer\",\n      \"question\": \"What is the meaning of life?\",\n      \"answer\": \"\" // user input will be stored here\n    },\n    {\n      \"type\": \"multiple_choice\",\n      \"question\": \"Which of the following is not a primary color?\",\n      \"options\": [\n        {\"text\": \"Red\", \"correct\": false},\n        {\"text\": \"Blue\", \"correct\": false},\n        {\"text\": \"Yellow\", \"correct\": false},\n        {\"text\": \"Green\", \"correct\": true}\n      ]\n    },\n    {\n      \"type\": \"free_answer\",\n      \"question\": \"Describe the concept of artificial intelligence.\",\n      \"answer\": \"Enter the answer here\" \n    }\n  ]\n}\n")
            }
            return "Please follow the example JSON EXACTLY"
        }()
        
        if streamContent {
            Task {
                do {
                    var validJsonReceived = false
                    if let imagesData = selectedPhotosData {
                        let response = chat.sendMessageStream(
                            "Notes:", userInput,
                            imagesData.compactMap { data in
                                UIImage(data: data)
                            })
                        
                        for try await chunk in response {
                            if validJsonReceived {
                                break
                            }
                            
                            if let text = chunk.text {
                                DispatchQueue.main.async {
                                    self.computerResponse += text
                                    print(self.computerResponse)
                                }
                            }
                            
                            let data = Data(self.computerResponse.utf8)
                            let decoder = JSONDecoder()
                            
                            // Try decoding the computerResponse into an Explanation
                            if let _ = try? decoder.decode(Explanation.self, from: data) {
                                // If it's successful, set validJsonReceived to true
                                validJsonReceived = true
                            }
                        }
                        
                        DispatchQueue.main.async {
                            completion(self.computerResponse)
                        }
                        
                    } else {
                        let response = chat.sendMessageStream(
                            "Notes:", userInput,
                            quizPrompt
                        )
                        for try await chunk in response {
                            if validJsonReceived {
                                break
                            }
                            
                            if let text = chunk.text {
                                DispatchQueue.main.async {
                                    self.computerResponse += text
                                    print(self.computerResponse)
                                }
                            }
                            
                            let data = Data(self.computerResponse.utf8)
                            let decoder = JSONDecoder()
                            
                            // Try decoding the computerResponse into an Explanation
                            if let _ = try? decoder.decode(Explanation.self, from: data) {
                                // If it's successful, set validJsonReceived to true
                                validJsonReceived = true
                            }
                        }
                        
                        DispatchQueue.main.async {
                            completion(self.computerResponse)
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
                do {
                    if let imagesData = selectedPhotosData {
                        let response = try await chat.sendMessage(
                            "Notes:", userInput,
                            quizPrompt,
                            imagesData.compactMap { data in
                                UIImage(data: data)
                            })
                        print("geminiInteraction log:", response.text ?? "No response received")
                        DispatchQueue.main.async {
                            self.computerResponse = response.text ?? "No response received"
                            completion(self.computerResponse)
                        }
                        
                    } else {
                        let response = try await chat.sendMessage(
                            "Notes:", userInput, quizPrompt
                        )
                        print("geminiInteraction log:", response.text ?? "No response received")
                        DispatchQueue.main.async {
                            self.computerResponse = response.text ?? "No response received"
                            completion(self.computerResponse)
                            print(self.computerResponse)
                        }
                    }
                } catch {
                    print(error)
                    DispatchQueue.main.async {
                        completion("Error: \(error)")
                    }
                }
            }
        }
    }
}
