//
//  SwiftUIView.swift
//  ElonMigo
//
//  Created by Vaibhav Satishkumar on 5/25/24.
//
import SwiftUI

struct QuestionView: View {
    var options: [QuestionOption]
    @State private var selectedIndex: Int?

    var body: some View {
        Text("Hello, World!")
        ForEach(Array(zip(options.indices, options)), id: \.0) { index, option in
            Button {
                selectedIndex = index
                //You can do something here based on the selected option
            } label: {
                HStack {
                    if selectedIndex == index {
                        Image(systemName: "checkmark.circle.fill")
                    }
                    Spacer()
                    Text(option.text)
                }
            }
        }
    }
}




//#Preview {
//    SwiftUIView()
//}
