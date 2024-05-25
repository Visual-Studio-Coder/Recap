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
                    SecureField("Top Secret API Key", text: $apiKey)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .border(.black)
                        .cornerRadius(10.0)
                        .padding(.horizontal)
                }
                
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
            }
            .navigationTitle("ElonMigo")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {} label: {
                        Label("Settings", systemImage: "gearshape")
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
