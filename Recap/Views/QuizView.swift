import SwiftUI
import ConfettiSwiftUI
import MarkdownUI
import Splash
import Shimmer

struct QuestionView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    let question: Question
    let answerCallback: ([String], Bool) -> Void
    
    @State private var selectedOptions: [String] = []
    @Binding var hasAnswered: Bool?
    @Binding var userDidGetAnswerCorrect: Bool?
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Markdown(question.question.replacingOccurrences(of: "<`>", with: "```"))
                    .markdownCodeSyntaxHighlighter(.splash(theme: self.theme))
                    .bold()
                    .font(.title)
                    .padding([.leading, .trailing, .top])
                Spacer()
            }
            Divider()
                .padding(.horizontal)
            HStack {
                if hasAnswered ?? false {
                    if userDidGetAnswerCorrect ?? false {
                        Label("You got this question correct", systemImage: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                            .padding(.horizontal)
                    } else {
                        Label("You got this question incorrect", systemImage: "checkmark.circle.fill")
                            .foregroundStyle(.red)
                            .padding(.horizontal)
                    }
                } else {
                    Text(question.type == "free_answer" ? "Enter a free response" : question.options?.filter({ $0.correct == true }).count ?? 0 > 1 ? "Select **multiple** answers" : "Select **one** answer")
                        .font(.subheadline)
                        .padding(.leading)
                }
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
                        
                        Markdown(option.text.replacingOccurrences(of: "<`>", with: "```"))
                            .markdownCodeSyntaxHighlighter(.splash(theme: self.theme))
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                        
                        if hasAnswered ?? false {
                            if option.correct == true {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                            } else if option.correct == false {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.red)
                            }
                        }
                    }
                    .padding()
                }
                .onLongPressGesture(minimumDuration: 0, pressing: { inProgress in
                    if inProgress {
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                    }
                }, perform: {})
                .disabled(hasAnswered ?? false)
                .buttonStyle(.bordered)
                .background(selectedOptions.contains(option.text) ? Color.blue.opacity(0.2) : Color.clear)
                //                .clipShape(RoundedRectangle(cornerRadius: 10))
                .cornerRadius(10)
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
                        .background(Color.accentColor)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .padding()
            }
            
            Spacer()
        }
        .transition(.slide)
    }
    private var theme: Splash.Theme {
        // NOTE: We are ignoring the Splash theme font
        switch self.colorScheme {
        case .dark:
            return .wwdc17(withFont: .init(size: 16))
        default:
            return .sunset(withFont: .init(size: 16))
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
    @State private var userDidGetAnswerCorrect = [Int: Bool]()
    @State private var userAnswers = [UserAnswer]()
    @State private var showExplanation = false
    @State private var explanation: Explanation?
    @State private var feedback: Feedback?
    @State private var difficultyScore = 1
    @State private var gradingResult: GradingResult?
    @State private var generatingFeedback = false
    @State private var userInput = ""
    @State private var isGradingInProgress = false
    @State private var computerResponse = ""
    @State private var isGenerating = false
    @State private var showPassMotivation = false
    @State private var showFailMotivation = false
    @State private var confettiCounter = 0
    @State private var renderedImage = Image(systemName: "photo")
    @State private var showFullFeedback = false
    @State private var showFullExpectedAnswer = false
    @State private var gradingCompleted: Bool = false // Add this state variable
    @State private var showingGeminiQuotaLimit = false
    @State private var isShowingResults = false
    
    @Environment(\.displayScale) var displayScale
    @Environment(\.colorScheme) private var colorScheme
    
    let quiz: Quiz
    @ObservedObject var chatService = GeminiAPI.shared!
    
    @Binding var showQuiz: Bool
    let userPrompt: String
    let userLinks: [String]
    let userPhotos: [Data]
    
    var body: some View {
        if selectedTab < quiz.questions.count {
            VStack(alignment: .leading) {
                HStack {
                    //show quiz title in menu on tap
                    Menu {
                        Section(quiz.quiz_title) {
                            Button(role: .destructive) {
                                withAnimation {
                                    chatService.clearChat()
                                    showQuiz = false
                                }
                                
                                // Add the quiz to the history and save it asynchronously
                                Task {
                                    await quizStorage.addQuiz(quiz, userAnswers: userAnswers, userPrompt: userPrompt, userLinks: userLinks, userPhotos: userPhotos)
                                }
                            } label: {
                                Label("Exit Quiz", systemImage: "rectangle.portrait.and.arrow.forward")
                            }
                        }
                    } label: {
                        HStack(spacing: 2) {
                            Image(systemName: "chevron.backward")
                                .foregroundStyle(.primary)
                                .bold()
                            
                            Text(quiz.quiz_title)
                                .foregroundStyle(.primary)
                                .lineLimit(1)
                        }
                        .padding([.leading, .top, .bottom])
                    }
                    
                    Spacer()
                    
                    Button {
                        showExplanation.toggle()
                        chatService.computerResponse = ""
                        self.explanation = Explanation(question: "", choices: [])
                        
                        // Collect all options for the current question
                        let currentQuestion = quiz.questions[selectedTab]
                        
                        // Safely unwrap options
                        guard let options = currentQuestion.options else {
                            print("Options are nil")
                            return
                        }
                        
                        let choices = options.map { (option: Option) in
                            Explanation.Choice(
                                answer_option: option.text, // Assuming 'text' is the property containing the string value
                                correct: option.correct, // Assuming 'answer' is a string
                                explanation: "Insert the explanation here for why this is the \(option.correct ? "correct" : "wrong") answer."
                            )
                        }
                        
                        let explanationPrompt = Explanation(question: currentQuestion.question, choices: choices)
                        
                        let encoder = JSONEncoder()
                        encoder.outputFormatting = .prettyPrinted
                        
                        do {
                            let data = try encoder.encode(explanationPrompt)
                            let jsonString = String(data: data, encoding: .utf8)!
                            
                            // Debug print to verify JSON string
                            print("JSON String being sent: \(jsonString)")
                            
                            chatService.sendMessage(userInput: "Act as my teacher in this subject. Explain the reasoning of EACH answer is wrong or right and return this exact JSON (with the same properties and ordering) back with the explanation values you add: \(jsonString). Do not use values that aren't in this JSON such as quiz_title", selectedPhotosData: nil, streamContent: true, generateQuiz: false) { response in
                                DispatchQueue.main.async {
                                    let data = Data(chatService.computerResponse.utf8)
                                    let decoder = JSONDecoder()
                                    
                                    if let partialExplanation = try? decoder.decode(Explanation.self, from: data) {
                                        // If the response can be decoded into an Explanation, update explanation
                                        self.explanation = partialExplanation
                                    } else {
                                        // If the response can't be decoded into an Explanation, show the raw JSON
                                        print("Raw JSON response: \(String(chatService.computerResponse))")
                                    }
                                }
                            }
                        } catch {
                            print("Error encoding JSON: \(error)")
                        }
                    } label: {
                        Label("Explain", systemImage: "sparkle")
                    }
                    .disabled(quiz.questions[selectedTab].type == "free_answer")
                    .symbolEffect(.bounce, value: showExplanation)
                    .buttonBorderShape(.capsule)
                    .buttonStyle(.bordered)
                    .padding(.horizontal)
                }
                
                ScrollView {
                    if quiz.questions[selectedTab].type == "multiple_choice" {
                        if let options = quiz.questions[selectedTab].options {
                            if options.filter({$0.correct}).count > 1 {
                                QuestionView(question: quiz.questions[selectedTab], answerCallback: { selectedOptions, isCorrect in
                                    answeredQuestions += 1
                                    
                                    if isCorrect {
                                        correctAnswers += 1
                                        showPassMotivation = true
                                    } else {
                                        showFailMotivation = true
                                    }
                                    
                                    userAnswers.append(UserAnswer(question: quiz.questions[selectedTab], userAnswer: selectedOptions, isCorrect: isCorrect, correctAnswer: nil))
                                    
                                    userDidGetAnswerCorrect[selectedTab] = isCorrect
                                    hasAnswered[selectedTab] = true
                                }, /*selectedOptions: $selectedOptions[selectedTab],*/ hasAnswered: $hasAnswered[selectedTab], userDidGetAnswerCorrect: $userDidGetAnswerCorrect[selectedTab])
                            } else {
                                QuestionView(question: quiz.questions[selectedTab], answerCallback: { selectedOptions, isCorrect in
                                    answeredQuestions += 1
                                    
                                    if isCorrect {
                                        correctAnswers += 1
                                        showPassMotivation = true
                                    } else {
                                        showFailMotivation = true
                                    }
                                    
                                    userAnswers.append(UserAnswer(question: quiz.questions[selectedTab], userAnswer: selectedOptions, isCorrect: isCorrect, correctAnswer: nil))
                                    
                                    userDidGetAnswerCorrect[selectedTab] = isCorrect
                                    hasAnswered[selectedTab] = true
                                }, /*selectedOptions: $selectedOptions[selectedTab],*/ hasAnswered: $hasAnswered[selectedTab], userDidGetAnswerCorrect: $userDidGetAnswerCorrect[selectedTab])
                                .transition(.slide)
                            }
                        }
                    } else {
                        HStack {
                            Markdown(quiz.questions[selectedTab].question)
                                .markdownCodeSyntaxHighlighter(.splash(theme: self.theme))
                                .bold()
                            //                                .font(.title)
                                .padding()
                            Spacer()
                        }
                        .transition(.slide)
                        
                        TextField("Click here to answer...", text: $userInput, axis: .vertical)
                            .transition(.slide)
                            .padding(.horizontal)
                            .onChange(of: userInput) {
                                hasAnswered[selectedTab] = !userInput.isEmpty
                            }
                            .disabled(isGradingInProgress || gradingResult != nil)
                            .scrollDismissesKeyboard(.interactively)
                        if hasAnswered[selectedTab] == true {
                            if let gradingResult = gradingResult {
                                //use a groupbox in swiftui please
                                GroupBox {
                                    VStack(alignment: .leading) {
                                        Label {
                                            Text("Expected Answer:")
                                                .bold()
                                        } icon: {
                                            Image(systemName: "chevron.right")
                                                .rotationEffect(showFullExpectedAnswer ? .degrees(90) : .degrees(0))
                                        }
                                        .onTapGesture {
                                            withAnimation(.spring()) {
                                                showFullExpectedAnswer.toggle()
                                            }
                                        }
                                        .foregroundStyle(.secondary)
                                        if showFullExpectedAnswer {
                                            Markdown("\(gradingResult.expectedAnswer.replacingOccurrences(of: "<`>", with: "```"))")
                                                .markdownCodeSyntaxHighlighter(.splash(theme: self.theme))
                                                .opacity(showFullExpectedAnswer ? 1 : 0)
                                                .animation(.easeInOut)
                                                .onTapGesture {
                                                    withAnimation(.spring()) {
                                                        showFullExpectedAnswer.toggle()
                                                    }
                                                }
                                        } else {
                                            Markdown("\(gradingResult.expectedAnswer.replacingOccurrences(of: "<`>", with: "```"))")
                                                .markdownCodeSyntaxHighlighter(.splash(theme: self.theme))
                                                .lineLimit(showFullExpectedAnswer ? nil : 3)
                                                .truncationMode(.tail)
                                            //.opacity(showFullExpectedAnswer ? 1 : 0)
                                                .animation(.easeInOut)
                                                .onTapGesture {
                                                    withAnimation(.spring()) {
                                                        showFullExpectedAnswer.toggle()
                                                    }
                                                }
                                        }
                                        Divider()
                                        Label {
                                            Text("Feedback:")
                                                .bold()
                                        } icon: {
                                            Image(systemName: "chevron.right")
                                                .rotationEffect(showFullFeedback ? .degrees(90) : .degrees(0))
                                        }
                                        .foregroundStyle(.secondary)
                                        .onTapGesture {
                                            withAnimation(.spring()) {
                                                showFullFeedback.toggle()
                                            }
                                        }
                                        if showFullFeedback {
                                            Markdown("\(gradingResult.feedback.replacingOccurrences(of: "<`>", with: "```"))")
                                                .markdownCodeSyntaxHighlighter(.splash(theme: self.theme))
                                                .opacity(showFullFeedback ? 1 : 0)
                                                .animation(.easeInOut)
                                                .onTapGesture {
                                                    withAnimation(.spring()) {
                                                        showFullFeedback.toggle()
                                                    }
                                                }
                                        } else {
                                            Markdown("\(gradingResult.feedback.replacingOccurrences(of: "<`>", with: "```"))")
                                                .markdownCodeSyntaxHighlighter(.splash(theme: self.theme))
                                                .lineLimit(showFullFeedback ? nil : 3)
                                                .truncationMode(.tail)
                                            //.opacity(showFullFeedback ? 1 : 0)
                                                .animation(.easeInOut)
                                                .onTapGesture {
                                                    withAnimation(.spring()) {
                                                        showFullFeedback.toggle()
                                                    }
                                                }
                                        }
                                        
                                    }
                                } label: {
                                    Label("\(gradingResult.isCorrect ? "Correct!" : "Wrong")", systemImage: "\(gradingResult.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")")
                                        .font(.subheadline)
                                        .foregroundStyle(gradingResult.isCorrect ? .green : .red)
                                }
                                .padding()
                                .animation(.easeInOut)
                                .transition(.slide)
                                .id(gradingResult.feedback) // Add an identifier to the GroupBox to trigger animation when gradingResult changes
                                
                            }
                        }
                    }
                    
                }
                Spacer()
                VStack {
                    Button {
                        withAnimation {
                            if quiz.questions.count-1 < selectedTab {
                                
                            } else if quiz.questions[selectedTab].type == "free_answer" && !gradingCompleted {
                                // If it's a free response question and grading hasn't been completed, start grading
                                gradeFreeResponse()
                            } else {
                                // For other question types, or if grading is completed, proceed to the next question
                                selectedTab += 1
                                gradingCompleted = false // Reset grading completion state
                                gradingResult = nil
                                userInput = ""
                                selectedOptions = [:] // Reset selected options after moving to the next question
                            }
                        }
                    } label: {
                        if isGradingInProgress && quiz.questions[selectedTab].type == "free_answer" {
                            ProgressView() // Show progress view if grading is in progress
                        } else {
                            Spacer()
                            Text(gradingCompleted ? "Next" : (quiz.questions[selectedTab].type == "free_answer") ? "Submit Answer" : "Next")
                                .bold()
                                .padding(6)
                            Spacer()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.horizontal)
                    .disabled(hasAnswered[selectedTab] == nil || (quiz.questions[selectedTab].type == "free_answer" && isGradingInProgress))
                    .transition(.slide)
                    // .ignoresSafeArea(.keyboard)
                    // Spacer()
                    QuizProgressBar(current: Float(answeredQuestions), total: Float(quiz.questions.count))
                        .frame(height: 10)
                        .padding(.vertical)
                        .ignoresSafeArea(.keyboard)
                    HStack {
                        Spacer()
                        Text("\(answeredQuestions) of \(quiz.questions.count) questions answered")
                            .bold()
                            .multilineTextAlignment(.center)
                        Spacer()
                    }
                    .ignoresSafeArea(.keyboard)
                    .transition(.slide)
                }
                .ignoresSafeArea(.keyboard)
                
                
                
            }
            .alert(Motivation.correctMotivation, isPresented: $showPassMotivation) {}
            .alert(Motivation.wrongMotivation, isPresented: $showFailMotivation) {}
            .sheet(isPresented: $showExplanation) {
                NavigationStack {
                    VStack {
                        if let explanationUnwrapped = explanation, !explanationUnwrapped.question.isEmpty {
                            // Markdown(explanationUnwrapped.question.replacingOccurrences(of: "<`>", with: "```"))
                            //     .markdownCodeSyntaxHighlighter(.splash(theme: self.theme))
                            //     .font(.headline)
                            //     .padding()
                            Form {
                                ForEach(explanationUnwrapped.choices, id: \.answer_option) { choice in
                                    Section {
                                        Label {
                                            Markdown("\(choice.answer_option.replacingOccurrences(of: "<`>", with: "```"))")
                                                .markdownCodeSyntaxHighlighter(.splash(theme: self.theme))
                                        } icon: {
                                            if choice.correct {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundStyle(.green)
                                            } else {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundStyle(.red)
                                            }
                                        }
                                        
                                        Markdown(choice.explanation.replacingOccurrences(of: "<`>", with: "```"))
                                            .markdownCodeSyntaxHighlighter(.splash(theme: self.theme))
                                    }
                                }
                            }
                        } else if !chatService.computerResponse.isEmpty {
                            // Markdown(quiz.questions[selectedTab].question.replacingOccurrences(of: "<`>", with: "```"))
                            //     .markdownCodeSyntaxHighlighter(.splash(theme: self.theme))
                            //     .font(.headline)
                            //     .padding()
                            Form {
                                Text("**Receiving Response from Gemini...**")
                                Markdown(chatService.computerResponse.replacingOccurrences(of: "<`>", with: "```"))
                                    .foregroundStyle(.brown)
                                    .redacted(reason: .placeholder)
                                //rainbow gradient
                                    .shimmering()
                                    .markdownCodeSyntaxHighlighter(.splash(theme: self.theme))
                            }
                            .onChange(of: chatService.computerResponse, { oldValue, newValue in
                                let generator = UIImpactFeedbackGenerator(style: .light)
                                generator.impactOccurred()
                            })
                        } else {
                            VStack {
                                // Markdown(quiz.questions[selectedTab].question.replacingOccurrences(of: "<`>", with: "```"))
                                //     .markdownCodeSyntaxHighlighter(.splash(theme: self.theme))
                                // //.font(.headline)
                                //     .padding()
                                ProgressView()
                                    .controlSize(.extraLarge)
                                    .padding(.top, 25)
                                
                                Text("Generating explanation...")
                                    .bold()
                                    .padding(.top)
                                Spacer()
                            }
                        }
                    }
                    .navigationTitle(quiz.questions[selectedTab].question)
                    .navigationBarTitleDisplayMode(.inline)
                }
                .presentationDetents([.medium, .large])
            }
        } else {
            ScrollView {
                VStack {
                    Spacer()
                    Text("🎉")
                        .font(.system(size: 60))
                        .confettiCannon(counter: $confettiCounter)
                    
                    Text("\(100 * correctAnswers / answeredQuestions)%")
                        .font(.system(size: 100))
                        .bold()
                    
                    Text("\(correctAnswers) out of \(answeredQuestions) correct")
                    //button to share results:
                    //ShareLink(item: <#T##URL#>, subject: <#T##Text?#>, message: <#T##Text?#>, label: <#T##() -> View#>)
                    ShareLink("Share Results", item: renderedImage, preview: SharePreview(Text("I got a \(correctAnswers) out of \(quiz.questions.count) on Recap!"), image: renderedImage))
                    
                        .onAppear {
                            confettiCounter += 1
                        }
                    
                    GroupBox(label: Label("Performance Feedback", systemImage: "bubble.left.and.text.bubble.right")
                    ) {
                        Divider()
                        if let feedback = feedback {
                            Markdown(feedback.feedback)
                                .markdownCodeSyntaxHighlighter(.splash(theme: self.theme))
                        } else {
                            if chatService.computerResponse.isEmpty {
                                ProgressView()
                                    .controlSize(.large)
                            } else {
                                Text(chatService.computerResponse)
                                    .redacted(reason: .placeholder)
                                    .shimmering()
                            }
                        }
                    }
                    .onAppear {
                        chatService.computerResponse = ""
                        func sendFeedbackRequest() {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                chatService.sendMessage(userInput: """
                                Based on the user's responses here: \(userAnswers), state what the user seemed to be struggling on, ways for them to improve, and what they should re-review. Also, provide a difficulty score of this quiz based on your questions and the user's performance. Return only a SINGULAR JSON, and make sure not to include multiple JSONS or add keys that don't exist like "expectedAnswer" "isCorrect" or "feedback":
                                
                                {
                                    "feedback": "Your feedback here in a consice bulleted list",
                                    "difficultyScore": (something between 1 and 5)
                                }
                                """, selectedPhotosData: nil, streamContent: true, generateQuiz: false, completion: { response in
                                    chatService.computerResponse = ""
                                    let data = Data(response.utf8)
                                    let decoder = JSONDecoder()
                                    
                                    DispatchQueue.main.async {
                                        do {
                                            let result = try decoder.decode(Feedback.self, from: data)
                                            
                                            print(response)
                                            
                                            self.feedback = result
                                            print("Decoded feedback result: \(result)")
                                        } catch let DecodingError.dataCorrupted(context) {
    print("Data corrupted: \(context.debugDescription)")
    print("Coding Path: \(context.codingPath)")
} catch let DecodingError.keyNotFound(key, context) {
    print("Key '\(key)' not found: \(context.debugDescription)")
    print("Coding Path: \(context.codingPath)")
} catch let DecodingError.valueNotFound(value, context) {
    print("Value '\(value)' not found: \(context.debugDescription)")
    print("Coding Path: \(context.codingPath)")
} catch let DecodingError.typeMismatch(type, context) {
    print("Type '\(type)' mismatch: \(context.debugDescription)")
    print("Coding Path: \(context.codingPath)")
} catch {
    print("Failed to decode feedback result: \(error.localizedDescription)")
    print("Raw response: \(response)")
}

                                    }
                                })
                            }
                        }
                        
                        sendFeedbackRequest()
                    }
                    .padding()
                    .sheet(isPresented: $isShowingResults, content: {
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
                                            Markdown(userAnswer.question.question.replacingOccurrences(of: "<`>", with: "```"))
                                                .markdownCodeSyntaxHighlighter(.splash(theme: self.theme))
                                            //.bold()
                                                .multilineTextAlignment(.leading)
                                            //                                    if userAnswer.question.type == "multiple_choice" {
                                            //                                        Spacer()
                                            //                                    }
                                            Spacer()
                                        }
                                        //                                .padding(.vertical)
                                    }
                                    if userAnswer.question.type == "multiple_choice" {
                                        ForEach(userAnswer.question.options ?? [], id: \.text) { option in
                                            HStack {
                                                Markdown(option.text.replacingOccurrences(of: "<`>", with: "```"))
                                                    .markdownCodeSyntaxHighlighter(.splash(theme: self.theme))
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
                                        VStack(alignment: .leading) {
                                            Text("Your Answer:")
                                                .bold()
                                                .foregroundStyle(.secondary)
                                            Text(userAnswer.userAnswer.joined(separator: ","))
                                        }
                                        VStack(alignment: .leading) {
                                            Text("Expected Answer:")
                                                .bold()
                                                .foregroundStyle(.secondary)
                                            if let correctAnswer = userAnswer.correctAnswer {
                                                Markdown(correctAnswer.replacingOccurrences(of: "<`>", with: "```"))
                                                    .markdownCodeSyntaxHighlighter(.splash(theme: self.theme))
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    })
                    
                    Spacer()
                }
                .transition(.slide)
                .onChange(of: correctAnswers) {
                    render(quizTitle: quiz.quiz_title, correctCount: Double(correctAnswers), wrongCount: Double(quiz.questions.count))
                }
                .onAppear { render(quizTitle: quiz.quiz_title, correctCount: Double(correctAnswers), wrongCount: Double(quiz.questions.count)) }
            }
            //toggle show results
            VStack {
                Button("Show My Responses", action: {
                    isShowingResults.toggle()
                })
                .padding()
                Button {
                    withAnimation {
                        chatService.clearChat()
                        showQuiz = false
                    }
                    
                    // Add the quiz to the history and save it asynchronously
                    Task {
                        await quizStorage.addQuiz(quiz, userAnswers: userAnswers, userPrompt: userPrompt, userLinks: userLinks, userPhotos: userPhotos)
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
    // Assuming gradingResult, correctAnswers, answeredQuestions, and userAnswers are @State properties or are properly managed to reflect UI updates.
    
    func gradeFreeResponse() {
        guard quiz.questions[selectedTab].type == "free_answer" else { return }
        
        isGradingInProgress = true
        
        let sampleJSON = """
        {
          "expectedAnswer": "Example expected answer",
          "isCorrect": true,
          "feedback": "Example feedback"
        }
        """
        
        let gradingPrompt = "Question: \(quiz.questions[selectedTab].question). The user's response is: \(userInput). Grade this free response, keeping the answers as short as humanly possible, and only output **THIS JSON STRUCTURE** and nothing else: \(sampleJSON). DO NOT RETURN ANY QUIZ INFORMATION OR GENERATE ANY QUIZZES. ONLY GRADE THIS ANSWER. THERE SHOULD BE ONLY ONE JSON"
        
        chatService.sendMessage(userInput: gradingPrompt, selectedPhotosData: nil, streamContent: false, generateQuiz: false) { response in
            print("Grading response received: \(response)") // This prints the raw response
            
            DispatchQueue.main.async {
                let data = Data(response.utf8)
                let decoder = JSONDecoder()
                
                do {
                    let result = try decoder.decode(GradingResult.self, from: data)
                    // Directly update the @State property
                    self.gradingResult = result
                    print("Decoded grading result asdasdasd: \(result)")
                    
                    if result.isCorrect {
                        self.correctAnswers += 1
                        self.showPassMotivation = true
                        //gradingResult = nil
                    } else {
                        self.showFailMotivation = true
                    }
                    self.answeredQuestions += 1
                    
                    self.userAnswers.append(UserAnswer(question: self.quiz.questions[self.selectedTab], userAnswer: [self.userInput], isCorrect: result.isCorrect, correctAnswer: result.expectedAnswer))
                    
                    // Optionally, show feedback to the user based on gradingResult.feedback
                    
                    //self.selectedTab += 1
                    //self.userInput = ""
                    DispatchQueue.main.async {
                        self.gradingCompleted = true
                        self.isGradingInProgress = false
                    }
                } catch {
                    // If the response can't be decoded into a GradingResult, print the error and the raw response
                    showingGeminiQuotaLimit.toggle()
                    print("Failed to decode grading result: \(error)")
                    print("Raw response 1234: \(response)")
                    self.isGradingInProgress = false
                }
            }
        }
    }
    private var theme: Splash.Theme {
        // NOTE: We are ignoring the Splash theme font
        switch self.colorScheme {
        case .dark:
            return .wwdc17(withFont: .init(size: 16))
        default:
            return .sunset(withFont: .init(size: 16))
        }
    }
    @MainActor func render(quizTitle: String, correctCount: Double, wrongCount: Double) {
        //let renderer = ImageRenderer(content: RenderView(text: text))
        let renderer = ImageRenderer(content: ShareResults(quizTitle: quizTitle, correctCount: correctCount, totalCount: wrongCount))
        
        // make sure and use the correct display scale for this device
        renderer.scale = displayScale
        
        if let uiImage = renderer.uiImage {
            renderedImage = Image(uiImage: uiImage)
        }
    }
}

//#Preview {
//    QuizView(quiz: Quiz(quiz_title: "Long Quiz Title Long Quiz Title", questions: [Question(type: "free_answer", question: "Explain how Elon Musk bought X.", options: [], answer: ""), Question(type: "multiple_choice", question: "Select Elon Musk #1", options: [Option(text: "Elon Musk", correct: true), Option(text: "Elon Crust", correct: false), Option(text: "Jeff Bezos", correct: false), Option(text: "Mark Zuckerberg", correct: false)], answer: "Elon Musk"), Question(type: "multiple_choice", question: "Select Jeff Bezos #2", options: [Option(text: "Elon Musk", correct: false), Option(text: "Elon Crust", correct: false), Option(text: "Jeff Bezos", correct: true), Option(text: "Mark Zuckerberg", correct: false)], answer: "Elon Musk"), Question(type: "multiple_choice", question: "Select Elon Musk #3", options: [Option(text: "Elon Musk", correct: true), Option(text: "Elon Crust", correct: false), Option(text: "Jeff Bezos", correct: false), Option(text: "Mark Zuckerberg", correct: false)], answer: "Elon Musk")]), showQuiz: .constant(true))
//}
