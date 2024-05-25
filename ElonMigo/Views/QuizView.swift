//
//  QuizView.swift
//  ElonMigo
//
import SwiftUI

struct QuizView: View {
    let quiz: Quiz
    @State private var selectedTab = 0
    
    var body: some View {
        VStack {
            TabView(selection: $selectedTab) {
                ForEach(0..<quiz.questions.count, id: \.self) { index in
                    QuestionView(question: quiz.questions[index])
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
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

#Preview {
    QuizView(quiz: Quiz(title: "Quiz 1", questions: [Question(questionType: "MCQ", question: "Select Elon Musk #1", options: [QuestionOption(text: "Elon Musk", correct: true), QuestionOption(text: "Elon Crust", correct: false), QuestionOption(text: "Jeff Bezos", correct: false), QuestionOption(text: "Mark Zuckerberg", correct: false)], answer: "Elon Musk"), Question(questionType: "MCQ", question: "Select Elon Musk #2", options: [QuestionOption(text: "Elon Musk", correct: true), QuestionOption(text: "Elon Crust", correct: false), QuestionOption(text: "Jeff Bezos", correct: false), QuestionOption(text: "Mark Zuckerberg", correct: false)], answer: "Elon Musk"), Question(questionType: "MCQ", question: "Select Elon Musk #3", options: [QuestionOption(text: "Elon Musk", correct: true), QuestionOption(text: "Elon Crust", correct: false), QuestionOption(text: "Jeff Bezos", correct: false), QuestionOption(text: "Mark Zuckerberg", correct: false)], answer: "Elon Musk")]))
}
