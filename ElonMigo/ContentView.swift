//
//  ContentView.swift
//  ElonMigo
//
//  Created by Aaron Ma on 5/25/24.
//

import SwiftUI
import PhotosUI
//import Kanna

struct ContentView: View {
    @EnvironmentObject var quizStorage: QuizStorage
    
    @AppStorage("apiKey") private var apiKey = ""
    
    // Gemini
    let geminiAPI = GeminiAPI.shared
    @AppStorage("model") private var selectedOption = "gemini-1.5-pro-latest"
    let options = ["Gemini 1.5 Pro", "Gemini 1.5 Flash"]
    
    @State private var quiz: Quiz?
    @State private var showingQuizSheet = false
    @State private var showingQuizCustomizationSheet = false
    @State private var gemeniGeneratingQuiz = false
    @State private var showingGeminiAPIAlert = false
    @State private var showingGeminiFailAlert = false
    
    @State private var showQuiz = false
    @State private var showingSettingsSheet = false
    
    @State private var userInput = ""
    @AppStorage("numberOfQuestions") private var numberOfQuestions = 5
    
    // Settings
    @AppStorage("geminiModel") private var geminiModel = AppSettings.geminiModel
    let geminiModels = ["1.5 Pro", "1.5 Flash"]
    
    // Web Search
    @State private var showingURLSheet = false
    @State private var links: [String] = []
    
    // Photos Picker
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedPhotosData: [Data] = []
    
    func decodeJSON(from jsonString: String) -> Quiz? {
        let jsonData = jsonString.data(using: .utf8)!
        return try? JSONDecoder().decode(Quiz.self, from: jsonData)
    }
    
    var body: some View {
        if showQuiz, let quiz = quiz {
            QuizView(quiz: quiz, showQuiz: $showQuiz)
                .environmentObject(quizStorage)
                .onAppear {
                    gemeniGeneratingQuiz = false
                }
        } else {
            NavigationStack {
                ScrollView {
                    if !quizStorage.history.isEmpty {
                        VStack {
                            Text("Recent Quizzes")
                                .font(.title)
                                .bold()
                        }
                        .padding(.leading)
                        //List {
                            ForEach(quizStorage.history.indices) { i in
                                VStack {
                                    Text(quizStorage.history[i].quiz_title)
                                        .bold()
                                    
                                    Text("\(quizStorage.history[i].questions.count) Questions")
                                        .foregroundStyle(.secondary)
                                }
                                .padding()
                            }
                        //}
                    }
                    VStack(alignment: .leading) {
                        Spacer()
                        TextField("What would you like to quiz yourself on?", text: $userInput)
                            .padding()
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                            .overlay(RoundedRectangle(cornerRadius: 15).stroke(.gray, lineWidth: 1))
                            .scrollDismissesKeyboard(.interactively)
                            .padding(.horizontal)
                        
                        HStack {
                            Button {
                                showingQuizCustomizationSheet.toggle()
                            } label: {
                                Image(systemName: "slider.horizontal.3")
                            }
                            .buttonStyle(.bordered)
                            .clipShape(RoundedRectangle(cornerRadius: 100))
                            Spacer()
                            HStack {
                                PhotosPicker(selection: $selectedItems, maxSelectionCount: 1, matching: .images) {
                                    if selectedItems.count == 1 {
                                        Label("\(selectedItems.count != 0 ? "\(selectedItems.count) Selected" : "")", systemImage: "photo")
                                    } else if selectedItems.count == 0 {
                                        Image(systemName: "photo")
                                    } else {
                                        Label("\(selectedItems.count != 0 ? "\(selectedItems.count) Selected" : "")", systemImage: "photo")
                                    }
                                }
                            }
                            .buttonStyle(.bordered)
                            .clipShape(RoundedRectangle(cornerRadius: 100))
                            .onChange(of: selectedItems) {
                                selectedPhotosData = []
                                
                                for i in selectedItems {
                                    Task {
                                        if let data = try? await i.loadTransferable(type: Data.self) {
                                            selectedPhotosData.append(data)
                                        }
                                    }
                                }
                            }
                            
                            Button {
                                showingURLSheet = true
                            } label: {
                                if links.count == 1 {
                                    Label("\(links.count != 0 ? "\(links.count) Link" : "")", systemImage: "link.badge.plus")
                                } else if links.count == 0 {
                                    Image(systemName: "link.badge.plus")
                                } else {
                                    Label("\(links.count != 0 ? "\(links.count) Links" : "")", systemImage: "link.badge.plus")
                                }
                            }
                            .buttonStyle(.bordered)
                            .clipShape(RoundedRectangle(cornerRadius: 100.00))
                        }
                        .padding([.bottom, .leading, .trailing])
                        
                        Button {
                            gemeniGeneratingQuiz = true
                            print(apiKey)
                            print(geminiModel)
                            
                            // Create a DispatchGroup to handle multiple asynchronous tasks
                            let group = DispatchGroup()
                            
                            var websiteContent = ""
                            
                            // Use a regular Swift for loop to iterate over the links array
                            for link in links {
                                if let url = URL(string: link) {
                                    group.enter()
                                    
                                    DispatchQueue.global().async {
                                        do {
                                            let contents = try String(contentsOf: url)
                                            let atr = try! NSAttributedString(data: contents.data(using: .unicode)!, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
                                            let plainString = atr.string
                                            websiteContent += plainString
                                        } catch {
                                            // contents could not be loaded
                                        }
                                        group.leave()
                                    }
                                }
                            }
                            
                            group.notify(queue: .main) {
                                if apiKey != "" {
                                    let message = userInput + "Attached Website Content:" + websiteContent
                                    geminiAPI!.sendMessage(userInput: message, selectedPhotosData: selectedPhotosData, streamContent: false, generateQuiz: true) { response in
                                        print(response)
                                        
                                        do {
                                            let quiz = decodeJSON(from: response)
                                            
                                            DispatchQueue.main.async {
                                                self.quiz = quiz
                                                self.showQuiz = true
                                            }
                                        } catch {
                                            print(error)
                                            self.showingGeminiFailAlert = true
                                            gemeniGeneratingQuiz = false
                                        }
                                    }
                                } else {
                                    self.showingGeminiAPIAlert = true
                                    gemeniGeneratingQuiz = false
                                }
                            }
                        } label: {
                            if gemeniGeneratingQuiz {
                                HStack {
                                    ProgressView()
                                    Text("Generating Quiz...")
                                }
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.accentColor)
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                            } else {
                                Label("Generate Quiz", systemImage: "paperplane")
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.accentColor)
                                    .clipShape(RoundedRectangle(cornerRadius: 15))
                            }
                        }
                        .disabled(gemeniGeneratingQuiz || (userInput.isEmpty && selectedPhotosData.count == 0 && links.count == 0))
                        .padding(.horizontal)
                    }
                    .navigationTitle("ElonMigo")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button {
                                showingSettingsSheet = true
                            } label: {
                                Label("Settings", systemImage: "gearshape")
                            }
                        }
                    }
                    .alert("To use ElonMigo, enter your API key!", isPresented: $showingGeminiAPIAlert) {
                        Button("Open Settings") {
                            showingSettingsSheet.toggle()
                        }
                    }

                    .alert("An unknown error occured while generating the quiz!", isPresented: $showingGeminiFailAlert) {}
                    .sheet(isPresented: $showingQuizCustomizationSheet) {
                        NavigationStack {
                            Form {
                                Section {
                                    Stepper("Number of Questions: \(numberOfQuestions)", value: $numberOfQuestions)
                                } header: {
                                    Text("Customize Question Count")
                                } footer: {
                                    Text("No guarantee, but we'll try to get Gemini to generate only ^[\(numberOfQuestions) question](inflect: true).")
                                }
                            }
                            .navigationTitle("Quiz Settings")
                            .navigationBarTitleDisplayMode(.inline)
                            .toolbar {
                                ToolbarItem(placement: .topBarTrailing) {
                                    Button("Done") {
                                        showingQuizCustomizationSheet = false
                                    }
                                }
                            }
                        }
                        .presentationDetents([.large, .medium])
                    }
                    .sheet(isPresented: $showingURLSheet) {
                        NavigationStack {
                            Form {
                                Section {
                                    ForEach(links.indices, id: \.self) { index in
                                        TextField("Enter URL #\(index + 1)", text: $links[index])
                                            .swipeActions(edge: .trailing) {
                                                Button(role: .destructive) {
                                                    links.remove(at: index)
                                                } label: {
                                                    Label("Delete", systemImage: "trash")
                                                }
                                            }
                                    }
                                    .onMove(perform: { from, to in
                                        links.move(fromOffsets: from, toOffset: to)
                                    })
                                    .onDelete(perform: { offsets in
                                        links.remove(atOffsets: offsets)
                                    })
                                }
                                
                                Section {
                                    Button {
                                        links.append("")
                                    } label: {
                                        Label("Add New Link", systemImage: "plus")
                                    }
                                    .disabled(links.count == 5)
                                }
                            }
                            .navigationTitle("Web Search")
                            .navigationBarTitleDisplayMode(.inline)
                            .toolbar {
                                ToolbarItem(placement: .topBarLeading) {
                                    EditButton()
                                        .disabled(links.isEmpty)
                                }
                                
                                ToolbarItem(placement: .topBarTrailing) {
                                    Button("Done") {
                                        showingURLSheet = false
                                    }
                                }
                            }
                        }
                        .presentationDetents([.medium, .large])
                    }
                    .sheet(isPresented: $showingSettingsSheet) {
                        NavigationStack {
                            Form {
                                Section {
                                    SecureField("Top Secret Gemini API Key", text: $apiKey)
                                } header: {
                                    Text("API Key")
                                } footer: {
                                    Text("Grab one for free from [makersuite.google.com](https://makersuite.google.com/app/apikey)\n**Reminder: Never share API keys.**")
                                }
                                
                                Section {
                                    Picker("Preferred Model", selection: $selectedOption) {
                                        ForEach(options, id: \.self) { option in
                                            HStack {
                                                if option == "Gemini 1.5 Flash" {
                                                    Label(" \(option)", systemImage: "bolt.fill")
                                                } else {
                                                    Label(" \(option)", systemImage: "brain.head.profile")
                                                }
                                            }
                                        }
                                    }
                                } header: {
                                    Text("Choose Model")
                                } footer: {
                                    
                                    if selectedOption == "Gemini 1.5 Flash" {
                                        Text("You will receive a **faster response** but not necessarily a smarter, more accurate quiz.")
                                    } else {
                                        Text("You will receive a **smarter response** but not necessarily a in a short amount of time.")
                                    }
                                }
                                .onChange(of: selectedOption) {
                                    selectedOption = selectedOption
                                }
                                
                                Section("Privacy") {
                                    Toggle("Save Quiz Results", isOn: .constant(true))
                                    Toggle("Improve Gemini for Everyone", isOn: .constant(true))
                                }
                            }
                            .navigationTitle("Settings")
                            .navigationBarTitleDisplayMode(.inline)
                            .toolbar {
                                ToolbarItem(placement: .topBarTrailing) {
                                    Button("Done") {
                                        showingSettingsSheet = false
                                    }
                                }
                            }
                        }
                        .presentationDetents([.medium, .large])
                    }
                }
            }
        }
    }
}

#Preview {
    Group {
        @StateObject var quizStorage = QuizStorage()
        
        ContentView()
            .environmentObject(quizStorage)
    }
}
