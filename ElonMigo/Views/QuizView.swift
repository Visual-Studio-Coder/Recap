//
//  QuizView.swift
//  ElonMigo
//
import SwiftUI

struct QuestionView: View {
    let question: Question
    let answerCallback: (String, Bool) -> Void
    
    @Binding var selectedOption: String?
    @Binding var hasAnswered: Bool?
    
    var body: some View {
        VStack {
            Spacer()
            
            Text(question.question)
                .bold()
                .font(.title)
                .padding()
            
            ForEach(question.options ?? [], id: \.text) { option in
                Button(action: {
                    if !(hasAnswered ?? false) {
                        selectedOption = option.text
                        hasAnswered = true
                        let correctOption = question.options?.first(where: { $0.correct == true })
                        answerCallback(selectedOption ?? "", selectedOption == correctOption?.text)
                    }
                }) {
                    HStack {
                        Text(option.text)
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                        
                        if hasAnswered ?? false {
                            if option.correct == true {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            } else if option.correct == false {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    .padding()
                }
                .disabled(hasAnswered ?? false)
                .buttonStyle(.bordered)
                .background(selectedOption == option.text ? Color.blue.opacity(0.2) : Color.clear)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal)
                .padding(.vertical, 5)
            }
            
            Spacer()
        }
    }
}

struct QuizView: View {
    @EnvironmentObject var quizStorage: QuizStorage
    
    @State private var selectedTab = 0
    @State private var correctAnswers = 0
    @State private var answeredQuestions = 0
    @State private var selectedOptions = [Int: String]()
    @State private var hasAnswered = [Int: Bool]()
    @State private var userAnswers = [UserAnswer]()
    @State private var showExplanation = false
    @State private var explanation: Explanation?
    @State private var userInput = ""
    @State private var computerResponse = ""
    @State private var isGenerating = false
    @State private var showPassMotivation = false
    @State private var showFailMotivation = false
    
    let quiz: Quiz
    let chatService = GeminiAPI.shared
    
    @Binding var showQuiz: Bool
    
    var body: some View {
        if selectedTab < quiz.questions.count {
            VStack(alignment: .leading) {
                HStack {
                    Text(quiz.quiz_title)
                        .bold()
                        .padding()
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Button {
                        let explanationPrompt = Explanation(question: "\(quiz.questions[selectedTab].question)", choices: [Explanation.Choice(answer_option: selectedOptions[selectedTab] ?? "", correct: selectedOptions[selectedTab] == quiz.questions[selectedTab].answer, explanation: "Insert the explanation here for why this is the correct or wrong answer.")])
                        
                        let encoder = JSONEncoder()
                        encoder.outputFormatting = .prettyPrinted
                        
                        do {
                            let data = try encoder.encode(explanationPrompt)
                            let jsonString = String(data: data, encoding: .utf8)!
                            
                            computerResponse = ""
                            
                            chatService!.sendMessage(userInput: "Act as my teacher in this subject. Explain the reasoning of EACH answer is wrong or right and return the JSON back with the explanation values you add: \(jsonString). Do not use values that aren't in this JSON such as quiz_title",selectedPhotosData: nil, streamContent: false, generateQuiz: false, completion: { response in
                                let data = Data(response.utf8)
                                let decoder = JSONDecoder()
                                
                                do {
                                    let partialExplanation = try decoder.decode(Explanation.self, from: data)
                                    
                                    self.explanation = partialExplanation
                                } catch {
                                    print(error)
                                }
                                
                                computerResponse = String(response)
                            })
                            
                            showExplanation.toggle()
                        } catch {
                            print(error)
                        }
                    } label: {
                        Label("Explain", systemImage: "sparkle")
                    }
                    .symbolEffect(.bounce, value: showExplanation)
                    .buttonBorderShape(.capsule)
                    .buttonStyle(.bordered)
                    .padding(.horizontal)
                }
                
                ScrollView {
                    if quiz.questions[selectedTab].type == "multiple_choice" {
                        QuestionView(question: quiz.questions[selectedTab], answerCallback: { userAnswer, isCorrect in
                            answeredQuestions += 1
                            
                            if isCorrect {
                                correctAnswers += 1
                                showPassMotivation = true
                            } else {
                                showFailMotivation = true
                            }
                            
                            userAnswers.append(UserAnswer(question: quiz.questions[selectedTab], userAnswer: userAnswer, isCorrect: isCorrect))
                            
                            hasAnswered[selectedTab] = true
                        }, selectedOption: $selectedOptions[selectedTab], hasAnswered: $hasAnswered[selectedTab])
                    } else {
                        Text(quiz.questions[selectedTab].question)
                            .bold()
                            .font(.title)
                        
                        TextField("Click here to answer...", text: $userInput)
                            .padding(.horizontal)
                            .onChange(of: userInput) {
                                hasAnswered[selectedTab] = !userInput.isEmpty
                            }
                    }
                }
                
                Button {
                    withAnimation {
                        if quiz.questions[selectedTab].type != "multiple_choice" {
                            correctAnswers += 1
                            answeredQuestions += 1
                            
                            userAnswers.append(UserAnswer(question: quiz.questions[selectedTab], userAnswer: userInput, isCorrect: true))
                            
                            showPassMotivation = true
                        }
                        
                        selectedTab += 1
                    }
                } label: {
                    Spacer()
                    
                    Text("Next")
                        .bold()
                        .padding(6)
                    
                    Spacer()
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal)
                .disabled(hasAnswered[selectedTab] == nil)
                
                QuizProgressBar(current: Float(answeredQuestions), total: Float(quiz.questions.count))
                    .frame(height: 10)
            }
            .alert(Motivation.correctMotivation, isPresented: $showPassMotivation) {}
            .alert(Motivation.wrongMotivation, isPresented: $showFailMotivation) {}
            .sheet(isPresented: $showExplanation) {
                VStack {
                    VStack {
                        if let explanationUnwrapped = explanation {
                            Text(explanationUnwrapped.question)
                                .font(.headline)
                                .padding()
                            Form {
                                ForEach(explanationUnwrapped.choices, id: \.answer_option) { choice in
                                    Section {
                                        Label {
                                            Text("\(choice.answer_option)")
                                        } icon: {
                                            if choice.correct {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundStyle(.green)
                                            } else {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundStyle(.red)
                                            }
                                        }
                                        
                                        Text(choice.explanation)
                                    }
                                }
                            }
                        } else {
                            ScrollView {
                                ProgressView()
                                    .controlSize(.extraLarge)
                                    .padding(.top, 25)
                                
                                Text("Generating explanation...")
                                    .bold()
                                    .padding(.top)
                            }
                        }
                    }
                    
                }
                .presentationDetents([.medium, .large])
            }
        } else {
            VStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                    .font(.system(size: 200))
                
                Text("🎉")
                    .font(.system(size: 60))
                
                Text("\(100 * correctAnswers / answeredQuestions)%")
                    .font(.system(size: 100))
                    .bold()
                
                Text("\(correctAnswers) out of \(answeredQuestions) correct")
                
                Spacer()
                
                Button {
                    withAnimation {
                        quizStorage.history.append(quiz)
                        showQuiz = false
                    }
                } label: {
                    Spacer()
                    
                    Text("Done")
                        .bold()
                        .padding(6)
                    
                    Spacer()
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal)
            }
        }
    }
}

#Preview {
    QuizView(quiz: Quiz(quiz_title: "Long Quiz Title Long Quiz Title", questions: [Question(type: "free_answer", question: "Explain how Elon Musk bought X.", options: [], answer: ""), Question(type: "multiple_choice", question: "Select Elon Musk #1", options: [Option(text: "Elon Musk", correct: true), Option(text: "Elon Crust", correct: false), Option(text: "Jeff Bezos", correct: false), Option(text: "Mark Zuckerberg", correct: false)], answer: "Elon Musk"), Question(type: "multiple_choice", question: "Select Jeff Bezos #2", options: [Option(text: "Elon Musk", correct: false), Option(text: "Elon Crust", correct: false), Option(text: "Jeff Bezos", correct: true), Option(text: "Mark Zuckerberg", correct: false)], answer: "Elon Musk"), Question(type: "multiple_choice", question: "Select Elon Musk #3", options: [Option(text: "Elon Musk", correct: true), Option(text: "Elon Crust", correct: false), Option(text: "Jeff Bezos", correct: false), Option(text: "Mark Zuckerberg", correct: false)], answer: "Elon Musk")]), showQuiz: .constant(true))
}
