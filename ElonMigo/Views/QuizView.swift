//
//  QuizView.swift
//  ElonMigo
//
import SwiftUI

struct QuizView: View {
    let quiz: Quiz
    let geminiAPI = GeminiAPI.shared
    
    @State var selectedTab = 0
    
    @State private var selectedIndex = -1
    @State private var submittedQuestion = false
    
    @State private var geminiResponse = ""
    @State private var explanation = Explanation(question: "", choices: [])
    @State private var showExplanationSheet = false
    
    var body: some View {
        VStack {
            ScrollView {
                Text(quiz.questions[selectedTab].question)
                    .font(.largeTitle)
                    .bold()
                
                Spacer()
                
                if let arr = quiz.questions[selectedTab].options {
                    ForEach(Array(zip(arr.indices, arr)), id: \.0) { index, option in
                        if quiz.questions[selectedTab].type == "multiple_choice" {
                            Button {
                                selectedIndex = index
                            } label: {
                                HStack {
                                    if submittedQuestion {
                                        if option.correct ?? false {
                                            Image(systemName: "checkmark.circle")
                                                .foregroundStyle(.green)
                                        } else {
                                            Image(systemName: "xmark.circle")
                                                .foregroundStyle(.red)
                                        }
                                    }
                                    
                                    Text(option.text)
                                        .font(.title3)
                                    
                                    Spacer()
                                }
                                .padding(.leading, 15)
                            }
                            .disabled(submittedQuestion)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .background(index == selectedIndex ? .green : .secondary.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .padding(.vertical, 2)
                            .padding(.horizontal)
                            .opacity((submittedQuestion && index != selectedIndex) ? 0.6 : 1)
                        } else {
                            TextField("Your answer", text: .constant(""))
                                .padding()
                        }
                    }
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
            
            //            Button {
            //                let explanationPrompt = Explanation(question: "\(quiz.questions[selectedTab].question)", choices: [Explanation.UserChoice(answerOption: quiz.questions[selectedTab].userSelection, correct: quiz.questions[selectedTab].userSelection == quiz.questions[selectedTab].answer, explanation: "Insert the explanation here for why this is the correct or wrong answer.")])
            //
            //                let encoder = JSONEncoder()
            //                encoder.outputFormatting = .prettyPrinted
            //
            //                do {
            //                    let data = try encoder.encode(explanationPrompt)
            //                    let jsonString = String(data: data, encoding: .utf8)!
            //                    geminiResponse = ""
            //                    geminiAPI!.sendMessage(userInput: "Act as my teacher in this subject. Explain the reasoning of EACH answer is wrong or right and return the JSON back with the explanation values you add: \(jsonString). Do not use values that aren't in this JSON such as quiz_title", selectedPhotosData: nil, streamContent: true, generateQuiz: false, completion: { response in
            //                        let data = Data(response.utf8)
            //                        let decoder = JSONDecoder()
            //
            //                        do {
            //                            let partialExplanation = try decoder.decode(Explanation.self, from: data)
            //                            self.explanation = partialExplanation
            //                        } catch {
            //                            print(error)
            //                        }
            //
            //                        geminiResponse = String(response)
            //                    })
            //
            //                    showExplanationSheet = true
            //                } catch {
            //                    print(error)
            //                }
            //            } label: {
            //                Label("Explain", systemImage: "sparkles")
            //            }
            //            .symbolEffect(.bounce, value: showExplanationSheet)
            //            .buttonBorderShape(.capsule)
            //            .buttonStyle(.bordered)
            
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
            .sheet(isPresented: $showExplanationSheet) {
                NavigationStack {
                    VStack {
                        if explanation.choices.isEmpty {
                            ProgressView()
                                .controlSize(.extraLarge)
                            
                            Text("Loading...")
                                .padding(.top)
                        } else {
                            Form {
                                ForEach(explanation.choices, id: \.explanation) { i in
                                    Section {
                                        Label {
                                            Text(i.answer_option)
                                        } icon: {
                                            if i.correct {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundStyle(.green)
                                            } else {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundStyle(.red)
                                            }
                                        }
                                        
                                        Text(i.explanation)
                                    }
                                }
                            }
                        }
                    }
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Done") {
                                showExplanationSheet = false
                            }
                        }
                    }
                }
            }
            
            QuizProgressBar(current: Float(submittedQuestion ? selectedTab + 1 : selectedTab), total: Float(quiz.questions.count))
            
            Text("\(selectedTab) out of \(quiz.questions.count) answered")
        }
    }
}

#Preview {
    QuizView(quiz: Quiz(title: "Quiz 1", questions: [Question(type: "multiple_choice", question: "Select Elon Musk #1", options: [Option(text: "Elon Musk", correct: true), Option(text: "Elon Crust", correct: false), Option(text: "Jeff Bezos", correct: false), Option(text: "Mark Zuckerberg", correct: false)], answer: "Elon Musk"), Question(type: "multiple_choice", question: "Select Jeff Bezos #2", options: [Option(text: "Elon Musk", correct: false), Option(text: "Elon Crust", correct: false), Option(text: "Jeff Bezos", correct: true), Option(text: "Mark Zuckerberg", correct: false)], answer: "Elon Musk"), Question(type: "multiple_choice", question: "Select Elon Musk #3", options: [Option(text: "Elon Musk", correct: true), Option(text: "Elon Crust", correct: false), Option(text: "Jeff Bezos", correct: false), Option(text: "Mark Zuckerberg", correct: false)], answer: "Elon Musk")]))
}
