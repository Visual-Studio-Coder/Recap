//
//  ContentView.swift
//  ElonMigo
//
//  Created by Aaron Ma on 5/25/24.
//

import SwiftUI
import PhotosUI

struct ContentView: View {
    @AppStorage("apiKey") var apiKey = ""
    
    @State private var showingSettingsSheet = false
    
    @State private var userInput = ""
    
    // Web Search
    @State private var links = [""]
    
    // Photos Picker
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedPhotosData: [Data] = []
    
    func decodeJSON(from jsonFile: String) -> Quiz? {
        return try? JSONDecoder().decode(Quiz.self, from: Data(jsonFile.utf8))
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    PhotosPicker(selection: $selectedItems, maxSelectionCount: 1, matching: .images) {
                        Label("Select Photos", systemImage: "photo.on.rectangle.angled")
                    }
                }
                .buttonStyle(.bordered)
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
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(selectedPhotosData, id: \.self) { photoData in
                            if let image = UIImage(data: photoData) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .cornerRadius(10.0)
                            }
                        }
                    }
                }
                
                Section("Web Search") {
                    ForEach(links.indices, id: \.self) { index in
                        HStack {
                            TextField("Enter Link #\(index + 1)", text: $links[index])
                                .textFieldStyle(.roundedBorder)
                            
                            Button {
                                links.remove(at: index)
                            } label: {
                                Image(systemName: "minus.circle")
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    
                    Button {
                        links.append("")
                    } label: {
                        Label("Add New Link", systemImage: "plus")
                    }
                }
                
                Divider()
                
                TextField("What would you like to study?", text: $userInput)
                    .padding()
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .overlay(RoundedRectangle(cornerRadius: 15).stroke(.gray, lineWidth: 1))
                    .scrollDismissesKeyboard(.interactively)
                    .padding(.horizontal)
                
                Button {} label: {
                    Label("Generate Quiz", systemImage: "paperplane")
                }
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
            .sheet(isPresented: $showingSettingsSheet) {
                NavigationStack {
                    Form {
                        Section {
                            SecureField("Top Secret Gemini API Key", text: $apiKey)
                        } header: {
                            Text("API Key")
                        } footer: {
                            Text("**Reminder:** Never share API keys.")
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

#Preview {
    ContentView()
}
