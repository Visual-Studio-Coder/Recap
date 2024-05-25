//
//  SwiftUIView.swift
//  ElonMigo
//
//  Created by Vaibhav Satishkumar on 5/25/24.
//

import SwiftUI

struct QuestionView: View {
    var options: [QuestionOption]
    var body: some View {
        Text("Hello, World!")
        ForEach(options, id: \.text) { option in
            Button {
                
            } label: {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
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
