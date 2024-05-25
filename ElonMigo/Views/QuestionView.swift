//
//  SwiftUIView.swift
//  ElonMigo
//
import SwiftUI

struct QuestionView: View {
    var question: Question
    
    @State private var selectedIndex = -1
    @State private var submittedQuestion = false
    
    var body: some View {
        VStack {
            ScrollView {
                Text(question.question)
                    .font(.largeTitle)
                    .bold()
                
                Spacer()
                
                ForEach(Array(zip(question.options.indices, question.options)), id: \.0) { index, option in
                    Button {
                        selectedIndex = index
                    } label: {
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
                if submittedQuestion {
                    // move on
                } else {
                    // check correct
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
    QuestionView(question: Question(questionType: "MCQ", question: "Select Elon Musk #1", options: [QuestionOption(text: "Elon Musk", correct: true), QuestionOption(text: "Elon Crust", correct: false), QuestionOption(text: "Jeff Bezos", correct: false), QuestionOption(text: "Mark Zuckerberg", correct: false)], answer: "Elon Musk"))
}
