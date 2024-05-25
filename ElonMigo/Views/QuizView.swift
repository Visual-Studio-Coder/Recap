//
//  QuizView.swift
//  ElonMigo
//
import SwiftUI

struct QuizView: View {
    let quiz: Quiz
    
    @State var selectedTab = 0
    
    @State private var selectedIndex = -1
    @State private var submittedQuestion = false
    
    var body: some View {
        VStack {
            ScrollView {
                Text(quiz.questions[selectedTab].question)
                    .font(.largeTitle)
                    .bold()
                
                Spacer()
                
                ForEach(Array(zip(quiz.questions[selectedTab].options.indices, quiz.questions[selectedTab].options)), id: \.0) { index, option in
                    Button {
                        selectedIndex = index
                    } label: {
                        if submittedQuestion {
                            Image(systemName: option.correct ? "checkmark" : "xmark")
                        }
                        
                        Text(option.text)
                            .font(.title)
                            .foregroundStyle(.white)
                    }
                    .disabled(submittedQuestion)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(index == selectedIndex ? .green : .secondary)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding(.vertical, 2)
                    .padding(.horizontal)
                    .opacity((submittedQuestion && index != selectedIndex) ? 0.6 : 1)
                }
            }
            
            //            if submittedQuestion {
            //                Button {
            //                    selectedIndex = -1
            //                    submittedQuestion = false
            //                } label: {
            //                    Label("Try again", systemImage: "arrow.circlepath")
            //                }
            //            }
            
            Button {
                let encoder = JSONEncoder()
                encoder.outputFormatting = .prettyPrinted
                
                do {
//                    let data = try encoder.encode(explanationPrompt)
                } catch {
                    print(error)
                }
            } label: {
                Label("Explain", systemImage: "sparkles")
            }
            .symbolEffect(.bounce, value: true)
            .buttonBorderShape(.capsule)
            .buttonStyle(.bordered)
            
            Button {
                let encoder = JSONEncoder()
                encoder.outputFormatting = .prettyPrinted
                
                do {} catch {
                    print(error)
                }
            } label: {
                Label("Get a Hint", systemImage: "lightbulb")
            }
            .symbolEffect(.bounce, value: true)
            .buttonBorderShape(.capsule)
            .buttonStyle(.bordered)
            
            Button {
                if submittedQuestion {
                    selectedTab += 1
                    selectedIndex = -1
                    submittedQuestion = false
                } else {
                    submittedQuestion = true
                }
            } label: {
                Text(submittedQuestion ? "Next" : "Submit")
                    .foregroundStyle(.white)
                    .opacity(selectedIndex == -1 ? 0.3 : 1)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedIndex == -1 ? Color.accentColor.opacity(0.7) : Color.accentColor)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    QuizView(quiz: Quiz(title: "Quiz 1", questions: [Question(questionType: "MCQ", question: "Select Elon Musk #1", options: [QuestionOption(text: "Elon Musk", correct: true), QuestionOption(text: "Elon Crust", correct: false), QuestionOption(text: "Jeff Bezos", correct: false), QuestionOption(text: "Mark Zuckerberg", correct: false)], answer: "Elon Musk"), Question(questionType: "MCQ", question: "Select Jeff Bezos #2", options: [QuestionOption(text: "Elon Musk", correct: false), QuestionOption(text: "Elon Crust", correct: false), QuestionOption(text: "Jeff Bezos", correct: true), QuestionOption(text: "Mark Zuckerberg", correct: false)], answer: "Elon Musk"), Question(questionType: "MCQ", question: "Select Elon Musk #3", options: [QuestionOption(text: "Elon Musk", correct: true), QuestionOption(text: "Elon Crust", correct: false), QuestionOption(text: "Jeff Bezos", correct: false), QuestionOption(text: "Mark Zuckerberg", correct: false)], answer: "Elon Musk")]))
}
