//
//  ContentView.swift
//  ElonMigo
//
//  Created by Aaron Ma on 5/25/24.
//

import SwiftUI
import PhotosUI

struct ContentView: View {
    @AppStorage("apiKey") private var apiKey = ""
    
    // Gemini
    let geminiAPI = GeminiAPI.shared
    @State private var quiz: Quiz?
    @State private var showingQuizSheet = false
    @State private var gemeniGeneratingQuiz = false
    @State private var showingGeminiAPIAlert = false
    @State private var showingGeminiFailAlert = false
    
    @State private var showingSettingsSheet = false
    
    @State private var userInput = ""
    
    // Settings
    @AppStorage("geminiModel") private var selectedOption = AppSettings.geminiModel
    let options = ["Gemini 1.5 Pro", "Gemini 1.5 Flash"]
    
    // Web Search
    @State private var showingURLSheet = false
    @State private var links: [String] = []
    
    // Photos Picker
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedPhotosData: [Data] = []
    
    func decodeJSON(from json: String) -> Quiz? {
        return try? JSONDecoder().decode(Quiz.self, from: Data(json.utf8))
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) {
                    TextField("What would you like to study?", text: $userInput)
                        .padding()
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .overlay(RoundedRectangle(cornerRadius: 15).stroke(.gray, lineWidth: 1))
                        .scrollDismissesKeyboard(.interactively)
                        .padding(.horizontal)
                    
                    HStack {
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
                        .onChange(of: selectedItems) { items in
                            selectedPhotosData = []
                            
                            for i in items {
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
                        print(apiKey)
                        print(selectedOption)
                        
                        if apiKey != "" {
                            geminiAPI!.sendMessage(userInput: userInput, selectedPhotosData: selectedPhotosData, streamContent: false, generateQuiz: true) { response in
                                print(response)
                                
                                if let quiz = decodeJSON(from: response) {
                                    DispatchQueue.main.async {
                                        self.quiz = quiz
                                        gemeniGeneratingQuiz = true
                                    }
                                } else {
                                    showingGeminiFailAlert = true
                                }
                            }
                        } else {
                            showingGeminiAPIAlert = true
                        }
                    } label: {
                        if gemeniGeneratingQuiz {
                            ProgressView()
                        }
                        
                        Label(gemeniGeneratingQuiz ? "Generating Quiz..." : "Generate Quiz", systemImage: "paperplane")
                            .foregroundStyle(.white)
                            //.opacity(userInput.isEmpty ? 0.3 : 1)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                    }
                    .disabled(gemeniGeneratingQuiz || (userInput.isEmpty && selectedPhotosData.count == 0))
                    .padding(.horizontal)
//                    .onChange(of: gemeniGeneratingQuiz) { status in
//                        if !status {
//                            showingQuizSheet = true
//                        }
//                    }
                    
                    Spacer()
                    
                    Divider()
                    
                    VStack {
                        Text("Recent Quizzes")
                            .font(.title)
                            .bold()
                    }
                    .padding(.leading)
                }
                .navigationTitle("ElonMigo")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showingSettingsSheet = true
                        } label: {
                            Label("Settings", systemImage: "gearshape")
                        }
                    }
                }
                .alert("To use ElonMigo, enter your API key!", isPresented: $showingGeminiAPIAlert) {}
                .alert("An unknown error occured while generating the quiz!", isPresented: $showingGeminiFailAlert) {}
//                .fullScreenCover(isPresented: $showingQuizSheet) {
//                    if let quiz = quiz {
//                        QuizView(quiz: quiz)
//                    }
//                }
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
                                Text("Grab one from [makersuite.google.com](https://makersuite.google.com/app/apikey)\n**Reminder: Never share API keys.**")
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

#Preview {
    ContentView()
}
