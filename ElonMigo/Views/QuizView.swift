//
//  QuizView.swift
//  ElonMigo
//
import SwiftUI
import ConfettiSwiftUI

struct QuestionView: View {
    let question: Question
    let answerCallback: ([String], Bool) -> Void
    
    @State private var selectedOptions: [String] = []
    @Binding var hasAnswered: Bool?
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Text(question.question)
                    .bold()
                    .font(.title)
                    .padding([.leading, .trailing, .top])
                Spacer()
            }
            Divider()
                .padding(.horizontal)
            HStack {
                Text(question.type == "free_answer" ? "Enter a free response" : question.options?.filter({ $0.correct == true }).count ?? 0 > 1 ? "Select **multiple** answers" : "Select **one** answer")
                    .font(.subheadline)
                    .padding(.leading)
                Spacer()
            }
            ForEach(question.options ?? [], id: \.text) { option in
                Button(action: {
                    if !(hasAnswered ?? false) {
                        if question.options?.filter({ $0.correct == true }).count ?? 0 > 1 {
                            if selectedOptions.contains(option.text) {
                                selectedOptions.removeAll(where: { $0 == option.text })
                            } else {
                                selectedOptions.append(option.text)
                            }
                        } else {
                            selectedOptions = [option.text]
                            hasAnswered = true
                            let allCorrect = selectedOptions.allSatisfy { selectedOption in
                                question.options?.contains(where: { $0.text == selectedOption && $0.correct }) ?? false
                            } && question.options?.filter({ $0.correct }).allSatisfy { correctOption in
                                selectedOptions.contains(correctOption.text)
                            } ?? false
                            answerCallback(selectedOptions, allCorrect)
                        }
                    }
                }) {
                    HStack {
                        if question.options?.filter({ $0.correct == true }).count ?? 0 > 1 {
                            Image(systemName: selectedOptions.contains(option.text) ? "checkmark.square" : "square")
                                .padding(.trailing)
                        }
                        
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
                .onLongPressGesture(minimumDuration: 0, pressing: { inProgress in
                    if inProgress {
                        let generator = UIImpactFeedbackGenerator(style: .soft)
                        generator.impactOccurred()
                    }
                }, perform: {})
                .disabled(hasAnswered ?? false)
                .buttonStyle(.bordered)
                .background(selectedOptions.contains(option.text) ? Color.blue.opacity(0.2) : Color.clear)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal)
                .padding(.vertical, 5)
            }
            
            if question.options?.filter({ $0.correct == true }).count ?? 0 > 1 && !selectedOptions.isEmpty && !(hasAnswered ?? false) {
                Button(action: {
                    if !(hasAnswered ?? false) {
                        hasAnswered = true
                        let allCorrect = selectedOptions.allSatisfy { selectedOption in
                            question.options?.contains(where: { $0.text == selectedOption && $0.correct }) ?? false
                        } && question.options?.filter({ $0.correct }).allSatisfy { correctOption in
                            selectedOptions.contains(correctOption.text)
                        } ?? false
                        answerCallback(selectedOptions, allCorrect)
                    }
                }) {
                    Text("Submit")
                        .bold()
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .padding()
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
    @State private var confettiCounter = 0
    
    let quiz: Quiz
    @ObservedObject var chatService = GeminiAPI.shared!
    
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
                        showExplanation.toggle()
                        chatService.computerResponse = ""
                        self.explanation = Explanation(question: "", choices: [])
                        let explanationPrompt = Explanation(question: "\(quiz.questions[selectedTab].question)", choices: [Explanation.Choice(answer_option: selectedOptions[selectedTab] ?? "", correct: selectedOptions[selectedTab] == quiz.questions[selectedTab].answer, explanation: "Insert the explanation here for why this is the correct or wrong answer.")])
                        
                        let encoder = JSONEncoder()
                        encoder.outputFormatting = .prettyPrinted
                        
                        do {
                            let data = try encoder.encode(explanationPrompt)
                            let jsonString = String(data: data, encoding: .utf8)!
                            
                            chatService.sendMessage(userInput: "Act as my teacher in this subject. Explain the reasoning of EACH answer is wrong or right and return the JSON back with the explanation values you add: \(jsonString). Do not use values that aren't in this JSON such as quiz_title",selectedPhotosData: nil, streamContent: true, generateQuiz: false) { response in
                                DispatchQueue.main.async {
                                        let data = Data(chatService.computerResponse.utf8)
                                        let decoder = JSONDecoder()
                                        
                                        if let partialExplanation = try? decoder.decode(Explanation.self, from: data) {
                                            // If the response can be decoded into an Explanation, update explanation and break the loop
                                            self.explanation = partialExplanation
                                        } else {
                                            // If the response can't be decoded into an Explanation, show the raw JSON
                                            print(String(chatService.computerResponse))
                                        }
                                }
                            }
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
                        QuestionView(question: quiz.questions[selectedTab], answerCallback: { selectedOptions, isCorrect in
                            answeredQuestions += 1
                            
                            if isCorrect {
                                correctAnswers += 1
                                showPassMotivation = true
                            } else {
                                showFailMotivation = true
                            }
                            
                            userAnswers.append(UserAnswer(question: quiz.questions[selectedTab], userAnswer: selectedOptions, isCorrect: isCorrect))
                            
                            hasAnswered[selectedTab] = true
                        }, /*selectedOptions: $selectedOptions[selectedTab],*/ hasAnswered: $hasAnswered[selectedTab])
                    } else {
                        Text(quiz.questions[selectedTab].question)
                            .bold()
                            .font(.title)
                            .padding()
                        
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
                            
                            userAnswers.append(UserAnswer(question: quiz.questions[selectedTab], userAnswer: [userInput], isCorrect: true))
                            
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
                    .padding(.vertical)
                HStack {
                    Spacer()
                    Text("\(answeredQuestions) of \(quiz.questions.count) questions answered")
                        .bold()
                        .multilineTextAlignment(.center)
                    Spacer()
                }
                
                
            }
            .alert(Motivation.correctMotivation, isPresented: $showPassMotivation) {}
            .alert(Motivation.wrongMotivation, isPresented: $showFailMotivation) {}
            .sheet(isPresented: $showExplanation) {
                NavigationStack {
                    VStack {
                        if let explanationUnwrapped = explanation, !explanationUnwrapped.question.isEmpty {
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
                            .navigationTitle(explanationUnwrapped.question)
                            .navigationBarTitleDisplayMode(.inline)
                        } else if !chatService.computerResponse.isEmpty {
                            Text(quiz.questions[selectedTab].question)
                                .font(.headline)
                                .padding()
                                Form {
                                    Text("**Parsing Response from Gemini...**")
                                    Text(chatService.computerResponse)
                                }
                                .onChange(of: chatService.computerResponse, { oldValue, newValue in
                                    let generator = UIImpactFeedbackGenerator(style: .light)
                                    generator.impactOccurred()
                                })
                        } else {
                            VStack {
                                Text(quiz.questions[selectedTab].question)
                                    .font(.headline)
                                    .padding()
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
            //ScrollView {
            VStack {
                Text("🎉")
                    .font(.system(size: 60))
                
                Text("\(100 * correctAnswers / answeredQuestions)%")
                    .font(.system(size: 100))
                    .bold()
                
                Text("\(correctAnswers) out of \(answeredQuestions) correct")
                //button to share results:
                Button {
                    //use sharelink in swiftui
                } label: {
                    Spacer()
                    
                    Text("Share Results")
                        .bold()
                        .padding(6)
                    
                    Spacer()
                }                
                //make it so i can see ALL the answers, which one I selected, and which one's were correct
                Form {
                    ForEach(userAnswers, id: \.question.question) { userAnswer in
                        Section {
                            VStack {
                                HStack {
                                    //did they get it correct or incorrect
                                    if userAnswer.isCorrect {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(.green)
                                        Text("You got this question correct!")
                                        .bold()
                                        .foregroundStyle(.secondary)
                                        .font(.footnote)
                                        .multilineTextAlignment(.leading)
                                    } else {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundStyle(.red)
                                        Text("You got this question incorrect.")
                                        .bold()
                                        .foregroundStyle(.secondary)
                                        .font(.footnote)
                                        .multilineTextAlignment(.leading)
                                    }
                                    Spacer()
                                    Text("Question \(userAnswers.firstIndex(where: { $0.question.question == userAnswer.question.question })! + 1)")
                                        .bold()
                                        .foregroundStyle(.secondary)
                                        .font(.footnote)
                                        .multilineTextAlignment(.leading)
                                }
                                HStack {
                                    Text(userAnswer.question.question)
                                        .bold()
                                        .multilineTextAlignment(.leading)
                                    Spacer()
                                }
                                .padding(.vertical)
                            }
                            if userAnswer.question.type == "multiple_choice" {
                                ForEach(userAnswer.question.options ?? [], id: \.text) { option in
                                    HStack {
                                        Text(option.text)
                                        Spacer()
                                        if userAnswer.userAnswer.contains(option.text) {
                                            if option.correct {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundStyle(.green)
                                            } else {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundStyle(.red)
                                            }
                                        } else if option.correct {
                                            Image(systemName: "checkmark.circle")
                                                .foregroundStyle(.green)
                                        } else {
                                            Image(systemName: "circle")
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                }
                            } else {
                                Text(userAnswer.userAnswer.joined(separator: ", "))
                            }
                        }
                    }
                }
                
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
            .confettiCannon(counter: $confettiCounter)
        //}
        }
    }
}

#Preview {
    QuizView(quiz: Quiz(quiz_title: "Long Quiz Title Long Quiz Title", questions: [Question(type: "free_answer", question: "Explain how Elon Musk bought X.", options: [], answer: ""), Question(type: "multiple_choice", question: "Select Elon Musk #1", options: [Option(text: "Elon Musk", correct: true), Option(text: "Elon Crust", correct: false), Option(text: "Jeff Bezos", correct: false), Option(text: "Mark Zuckerberg", correct: false)], answer: "Elon Musk"), Question(type: "multiple_choice", question: "Select Jeff Bezos #2", options: [Option(text: "Elon Musk", correct: false), Option(text: "Elon Crust", correct: false), Option(text: "Jeff Bezos", correct: true), Option(text: "Mark Zuckerberg", correct: false)], answer: "Elon Musk"), Question(type: "multiple_choice", question: "Select Elon Musk #3", options: [Option(text: "Elon Musk", correct: true), Option(text: "Elon Crust", correct: false), Option(text: "Jeff Bezos", correct: false), Option(text: "Mark Zuckerberg", correct: false)], answer: "Elon Musk")]), showQuiz: .constant(true))
}
