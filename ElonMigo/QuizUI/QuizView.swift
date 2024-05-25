//
//  QuizView.swift
//  ElonMigo
//
//  Created by Vaibhav Satishkumar on 5/25/24.
//

import SwiftUI

struct QuizView: View {
  @State var quiz: Quiz
  @State private var selectedTab = 0

  var body: some View {
    VStack {
      TabView(selection: $selectedTab) {
        ForEach(0..<quiz.questions.count, id: \.self) { index in
          QuestionView(options: quiz.questions[index].options ?? [])
        }
      }
      .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))

      Button(action: {
        if selectedTab < quiz.questions.count - 1 {
          selectedTab += 1
        }
      }) {
        Text("Next")
      }
    }
  }
}
//#Preview {
  //  QuizView()
//}
