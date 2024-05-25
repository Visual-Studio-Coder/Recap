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
    
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedPhotosData: [Data] = []
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    SecureField("Top Secret API Key", text: $apiKey)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                HStack {
                    PhotosPicker(selection: $selectedItems, maxSelectionCount: 1, matching: .images) {
                        Label("Select Photos", systemImage: "photo.on.rectangle.angled")
                    }
                }
                .buttonStyle(.bordered)
                .onChange(of: selectedItems) { _ in
//                    selectedItems
                }
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
