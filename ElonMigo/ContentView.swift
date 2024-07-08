//
//  ContentView.swift
//  ElonMigo
//
//  Created by Aaron Ma on 5/25/24.
//

import SwiftUI
import PhotosUI
import Combine

@MainActor
class UserPreferences: ObservableObject {
    static let shared = UserPreferences()
    
    @Published var somePreference: Bool {
        didSet {
            UserDefaults.standard.set(somePreference, forKey: "somePreference")
        }
    }
    
    @Published var apiKey: String {
        didSet {
            UserDefaults.standard.set(apiKey, forKey: "apiKey")
        }
    }
    
    @Published var selectedOption: String {
        didSet {
            UserDefaults.standard.set(selectedOption, forKey: "model")
        }
    }
    
    @Published var numberOfQuestions: Int {
        didSet {
            UserDefaults.standard.set(numberOfQuestions, forKey: "numberOfQuestions")
        }
    }
    
    @Published var geminiModel: String {
        didSet {
            UserDefaults.standard.set(geminiModel, forKey: "geminiModel")
        }
    }
    
    init() {
        self.somePreference = UserDefaults.standard.bool(forKey: "somePreference")
        self.apiKey = UserDefaults.standard.string(forKey: "apiKey") ?? ""
        self.selectedOption = UserDefaults.standard.string(forKey: "model") ?? "gemini-1.5-pro-latest"
        self.numberOfQuestions = UserDefaults.standard.integer(forKey: "numberOfQuestions")
        self.geminiModel = UserDefaults.standard.string(forKey: "geminiModel") ?? AppSettings.geminiModel
    }
}
struct ContentView: View {
    @EnvironmentObject var quizStorage: QuizStorage
    @EnvironmentObject var userPreferences: UserPreferences
    
    @AppStorage("apiKey") private var apiKey = ""
    
    // Gemini
    let geminiAPI = GeminiAPI.shared
    //@AppStorage("model") private var selectedOption = "gemini-1.5-pro-latest"
    let options = ["Gemini 1.5 Pro", "Gemini 1.5 Flash"]
    
    @State private var quiz: Quiz?
    @State private var showingQuizSheet = false
    @State private var showingQuizCustomizationSheet = false
    @State private var gemeniGeneratingQuiz = false
    @State private var showingGeminiAPIAlert = false
    @State private var showingGeminiFailAlert = false
    
    @State private var showQuiz = false
    @State private var showingSettingsSheet = false
    @State private var showingQuizResults = false
    @State private var showingClearHistoryActionSheet = false
    @State private var showingAllQuizzes = false
    
    @State private var userInput = ""
    //@AppStorage("numberOfQuestions") private var numberOfQuestions = 5
    
    // Settings
    //@AppStorage("geminiModel") private var geminiModel = AppSettings.geminiModel
    let geminiModels = ["1.5 Pro", "1.5 Flash"]
    
    // Web Search
    @State private var showingURLSheet = false
    @State private var links: [String] = []
    
    // Photos Picker
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedPhotosData: [Data] = []
    
    func decodeJSON(from jsonString: String) -> (quiz: Quiz?, error: String?) {
        let jsonData = jsonString.data(using: .utf8)!
        do {
            let quiz = try JSONDecoder().decode(Quiz.self, from: jsonData)
            return (quiz, nil)
        } catch let error {
            return (nil, error.localizedDescription)
        }
    }
    
    
    var body: some View {
        if showQuiz, let quiz = quiz {
            QuizView(quiz: quiz, showQuiz: $showQuiz)
                .environmentObject(quizStorage)
                .onAppear {
                    gemeniGeneratingQuiz = false
                }
        } else {
            NavigationStack {
                if !quizStorage.history.isEmpty {
                    ScrollView {
                        VStack {
                            
                            Text("Recent Quizzes")
                                .font(.title)
                                .bold()
                            Button(action: {
                                // Show action sheet to confirm clearing history
                                showingClearHistoryActionSheet = true
                            }) {
                                Label("Clear History", systemImage: "trash")
                            }
                            .actionSheet(isPresented: $showingClearHistoryActionSheet) {
                                ActionSheet(
                                    title: Text("Are you sure you want to clear history?"),
                                    buttons: [
                                        .destructive(Text("Clear"), action: {
                                            quizStorage.history.removeAll()
                                            Task {
                                                await quizStorage.save(history: [])
                                            }
                                        }),
                                        .cancel()
                                    ]
                                )
                            }
                            .foregroundColor(.red)
                            
                        }
                        .padding(.leading)
                        
                        //List {
                        ForEach(quizStorage.history.indices.prefix(3), id: \.self) { i in
                            Menu {
                                //share quiz
                                ShareLink(item: ExportableQuiz(quiz: quizStorage.history[i]), preview: SharePreview(quizStorage.history[i].quiz_title, icon: "square.and.arrow.up"))
                                Button(action: {
                                    //remove current quiz:
                                    quiz = quizStorage.history[i]
                                    withAnimation {
                                        showQuiz.toggle()
                                    }
                                    quizStorage.history.remove(at: i)
                                }) {
                                    Label("Take Quiz Again", systemImage: "arrow.clockwise")
                                }
                                Button(action: {
                                    DispatchQueue.main.async {
                                        quiz = quizStorage.history[i]
                                    }
                                    showingQuizResults.toggle()
                                }) {
                                    Label("View Past Results", systemImage: "text.book.closed")
                                }
                                
                                Button(action: {
                                    // Implement action to regenerate the quiz
                                }) {
                                    Label("Regenerate Quiz", systemImage: "gobackward")
                                }
                            } label: {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(quizStorage.history[i].quiz_title)
                                            .bold()
                                        
                                        Text("\(quizStorage.history[i].questions.count) Questions")
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    //                                        if quizStorage.history[i].userAnswers != nil {
                                    //                                            Text("\(quizStorage.history[i].userAnswers!.filter { $0.isCorrect == true }.count)/\(quizStorage.history[i].questions.count) (\(Int((Double(quizStorage.history[i].userAnswers!.filter { $0.isCorrect == true }.count) / Double(quizStorage.history[i].questions.count)) * 100))%)")
                                    //                                                .foregroundStyle(.secondary)
                                    //                                        }
                                    if let userAnswers = quizStorage.history[i].userAnswers {
                                        Text("\((userAnswers.filter { $0.isCorrect }.count))/\(quizStorage.history[i].questions.count) (\(String(format: "%.0f", (Double(userAnswers.filter { $0.isCorrect }.count) / Double(quizStorage.history[i].questions.count) * 100)))%)")
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                .padding()
                            }
                        }
                        //}
                        
                        if quizStorage.history.count > 3 {
                            Button(action: {
                                // Show all quizzes
                                showingAllQuizzes.toggle()
                            }) {
                                Text("Show All Quizzes")
                                    .font(.headline)
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .scrollDismissesKeyboard(.interactively)
                }
                    
                VStack(alignment: .leading) {
                    HStack {
                        TextField("What would you like to quiz yourself on?", text: $userInput, axis: .vertical)
                            .padding()
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                            .overlay(RoundedRectangle(cornerRadius: 15).stroke(.gray, lineWidth: 1))
                            //.padding(.horizontal)
                        Button {
                            gemeniGeneratingQuiz = true
                            print(userPreferences.apiKey)
                            print(userPreferences.geminiModel)
                            
                            // Create a DispatchGroup to handle multiple asynchronous tasks
                            let group = DispatchGroup()
                            
                            var websiteContent = ""
                            
                            // Use a regular Swift for loop to iterate over the links array
                            for link in links {
                                if let url = URL(string: link) {
                                    group.enter()
                                    
                                    DispatchQueue.global().async {
                                        do {
                                            let contents = try String(contentsOf: url)
                                            let atr = try! NSAttributedString(data: contents.data(using: .unicode)!, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
                                            let plainString = atr.string
                                            websiteContent += plainString
                                        } catch {
                                            // contents could not be loaded
                                        }
                                        group.leave()
                                    }
                                }
                            }
                            
                            group.notify(queue: .main) {
                                if apiKey != "" {
                                    let message = userInput + "Attached Website Content:" + websiteContent
                                    geminiAPI!.sendMessage(userInput: message, selectedPhotosData: selectedPhotosData, streamContent: false, generateQuiz: true) { response in
                                        //print(response)
                                        let (quiz, error) = decodeJSON(from: response)
                                        if let quiz = quiz {
                                            DispatchQueue.main.async {
                                                self.quiz = quiz
                                                self.showQuiz = true
                                            }
                                        } else {
                                            print("Failed to decode json: \(error ?? "Unknown error")")
                                            self.showingGeminiFailAlert = true
                                            gemeniGeneratingQuiz = false
                                        }
                                        
                                    }
                                } else {
                                    self.showingGeminiAPIAlert = true
                                    gemeniGeneratingQuiz = false
                                }
                            }
                        } label: {
                            if gemeniGeneratingQuiz {
                                ProgressView()
                                    //.foregroundStyle(.white)
                                    .frame(width: 30, height: 30)
                                    .padding(.trailing)
                                    //.background(Color.accentColor)
                                    //.clipShape(RoundedRectangle(cornerRadius: 15))
                            } else {
                                Image(systemName: "paperplane")
                                    //.foregroundStyle(.white)
                                    .frame(width: 30, height: 30)
                                    .padding(.trailing)
                                    //.background(Color.accentColor)
                                    //.clipShape(RoundedRectangle(cornerRadius: 15))
                            }
                        }
                        .disabled(gemeniGeneratingQuiz || (userInput.isEmpty && selectedPhotosData.count == 0 && links.count == 0))
                    }
                    
                    HStack {
                        Button {
                            showingQuizCustomizationSheet.toggle()
                        } label: {
                            Image(systemName: "slider.horizontal.3")
                        }
                        .buttonStyle(.bordered)
                        .clipShape(RoundedRectangle(cornerRadius: 100))
                        
                        PhotosPicker(selection: $selectedItems, maxSelectionCount: 5, matching: .images) {
                            if selectedItems.count == 1 {
                                Label("\(selectedItems.count != 0 ? "\(selectedItems.count) Selected" : "")", systemImage: "photo")
                            } else if selectedItems.count == 0 {
                                Image(systemName: "photo")
                            } else {
                                Label("\(selectedItems.count != 0 ? "\(selectedItems.count) Selected" : "")", systemImage: "photo")
                            }
                        }
                        .buttonStyle(.bordered)
                        .clipShape(RoundedRectangle(cornerRadius: 100))
                        .onChange(of: selectedItems) {
                            selectedPhotosData = []
                            
                            // Define the maximum allowed dimension for an image.
                            let largestImageDimension: CGFloat = 768.0
                            
                            // Use a concurrent loop to process images in parallel.
                            Task {
                                await withTaskGroup(of: Data?.self) { group in
                                    for item in selectedItems {
                                        group.addTask {
                                            return try? await item.loadTransferable(type: Data.self)
                                        }
                                    }
                                    
                                    // Process each image as it finishes loading.
                                    for await result in group {
                                        if let data = result, let image = UIImage(data: data) {
                                            // Check if the image fits within the largest allowed dimension.
                                            if image.size.fits(largestDimension: largestImageDimension) {
                                                // If it fits, use the original image data.
                                                await MainActor.run {
                                                    selectedPhotosData.append(data)
                                                }
                                            } else {
                                                // If it doesn't fit, resize the image.
                                                guard let resizedImage = image.preparingThumbnail(of: CGSize(width: largestImageDimension, height: largestImageDimension).aspectFit(largestDimension: largestImageDimension)) else {
                                                    continue
                                                }
                                                
                                                // Convert the resized image back to Data, if possible.
                                                if let resizedImageData = resizedImage.jpegData(compressionQuality: 1.0) {
                                                    // Append the resized image data to the selectedPhotosData array.
                                                    await MainActor.run {
                                                        selectedPhotosData.append(resizedImageData)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        Button {
                            showingURLSheet = true
                        } label: {
                            if links.count == 1 {
                                Label("\(links.count != 0 ? "\(links.count) Link" : "")", systemImage: "link.badge.plus")
                            } else if links.count == 0 {
                                Image(systemName: "link.badge.plus")
                            } else {
                                Label("\(links.count != 0 ? "\(links.count) Links" : "")", systemImage: "link.badge.plus")
                            }
                        }
                        .buttonStyle(.bordered)
                        .clipShape(RoundedRectangle(cornerRadius: 100.00))
                        
                    }
                    .padding([.bottom, .leading, .trailing])
                }
                .navigationTitle("ElonMigo")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showingSettingsSheet = true
                        } label: {
                            Label("Settings", systemImage: "gearshape")
                        }
                    }
                }
                .alert("To use ElonMigo, enter your API key!", isPresented: $showingGeminiAPIAlert) {
                    Button("Open Settings") {
                        showingSettingsSheet.toggle()
                    }
                }
                
                .alert("An unknown error occured while generating the quiz!", isPresented: $showingGeminiFailAlert) {}
                .sheet(isPresented: $showingQuizResults) {
                    if quiz != nil {
                        if quiz!.userAnswers != nil {
                            NavigationStack {
                                QuizResultsView(userAnswers: quiz!.userAnswers!)
                                    .navigationTitle(Text("\(quiz!.quiz_title) Results"))
                                    .navigationBarTitleDisplayMode(.inline)
                            }
                            .presentationDetents([.large, .medium])
                        }
                    }
                    
                }
                .sheet(isPresented: $showingQuizCustomizationSheet) {
                    NavigationStack {
                        Form {
                            Section {
                                Stepper("Number of Questions: \(userPreferences.numberOfQuestions)", value: $userPreferences.numberOfQuestions)
                            } header: {
                                Text("Customize Question Count")
                            } footer: {
                                Text("No guarantee, but we'll try to get Gemini to generate only ^[\(userPreferences.numberOfQuestions) question](inflect: true).")
                            }
                        }
                        .navigationTitle("Quiz Settings")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .topBarTrailing) {
                                Button("Done") {
                                    showingQuizCustomizationSheet = false
                                }
                            }
                        }
                    }
                    .presentationDetents([.large, .medium])
                }
                .onOpenURL { url in
                    // Handle the URL to load the quiz
                    Task {
                        await loadQuiz(from: url)
                    }
                }
                .sheet(isPresented: $showingURLSheet) {
                    NavigationStack {
                        Form {
                            Section {
                                ForEach(links.indices, id: \.self) { index in
                                    TextField("Enter URL #\(index + 1)", text: $links[index])
                                        .swipeActions(edge: .trailing) {
                                            Button(role: .destructive) {
                                                links.remove(at: index)
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                        }
                                }
                                .onMove(perform: { from, to in
                                    links.move(fromOffsets: from, toOffset: to)
                                })
                                .onDelete(perform: { offsets in
                                    links.remove(atOffsets: offsets)
                                })
                            }
                            
                            Section {
                                Button {
                                    links.append("")
                                } label: {
                                    Label("Add New Link", systemImage: "plus")
                                }
                                .disabled(links.count == 5)
                            }
                        }
                        .navigationTitle("Web Search")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .topBarLeading) {
                                EditButton()
                                    .disabled(links.isEmpty)
                            }
                            
                            ToolbarItem(placement: .topBarTrailing) {
                                Button("Done") {
                                    showingURLSheet = false
                                }
                            }
                        }
                    }
                    .presentationDetents([.medium, .large])
                }
                //show
                .sheet(isPresented: $showingAllQuizzes) {
                    NavigationStack {
                        List {
                            ForEach(quizStorage.history.indices, id: \.self) { i in
                                Menu {
                                    //share quiz
                                    ShareLink(item: ExportableQuiz(quiz: quizStorage.history[i]), preview: SharePreview(quizStorage.history[i].quiz_title, icon: "square.and.arrow.up"))
                                    Button(action: {
                                        //remove current quiz:
                                        quiz = quizStorage.history[i]
                                        withAnimation {
                                            showQuiz.toggle()
                                        }
                                        quizStorage.history.remove(at: i)
                                    }) {
                                        Label("Take Quiz Again", systemImage: "arrow.clockwise")
                                    }
                                    Button(action: {
                                        DispatchQueue.main.async {
                                            quiz = quizStorage.history[i]
                                        }
                                        showingQuizResults.toggle()
                                    }) {
                                        Label("View Past Results", systemImage: "text.book.closed")
                                    }
                                    
                                    Button(action: {
                                        // Implement action to regenerate the quiz
                                    }) {
                                        Label("Regenerate Quiz", systemImage: "gobackward")
                                    }
                                } label: {
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(quizStorage.history[i].quiz_title)
                                                .bold()
                                            
                                            Text("\(quizStorage.history[i].questions.count) Questions")
                                                .foregroundStyle(.secondary)
                                        }
                                        Spacer()
                                        //                                        if quizStorage.history[i].userAnswers != nil {
                                        //                                            Text("\(quizStorage.history[i].userAnswers!.filter { $0.isCorrect == true }.count)/\(quizStorage.history[i].questions.count) (\(Int((Double(quizStorage.history[i].userAnswers!.filter { $0.isCorrect == true }.count) / Double(quizStorage.history[i].questions.count)) * 100))%)")
                                        //                                                .foregroundStyle(.secondary)
                                        //                                        }
                                        if let userAnswers = quizStorage.history[i].userAnswers {
                                            Text("\((userAnswers.filter { $0.isCorrect }.count))/\(quizStorage.history[i].questions.count) (\(String(format: "%.0f", (Double(userAnswers.filter { $0.isCorrect }.count) / Double(quizStorage.history[i].questions.count) * 100)))%)")
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                }
                            }
                            // button to clear history
                            
                        }
                        .navigationTitle("All Quizzes")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement:
                                            .cancellationAction) {
                                Button("Done") {
                                    showingAllQuizzes = false
                                }
                            }
                            ToolbarItem(placement: .confirmationAction) {
                                Button("Clear All") {
                                    showingClearHistoryActionSheet = true
                                }
                                .foregroundColor(.red)
                                .actionSheet(isPresented: $showingClearHistoryActionSheet) {
                                    ActionSheet(
                                        title: Text("Are you sure you want to clear history?"),
                                        buttons: [
                                            .destructive(Text("Clear"), action: {
                                                quizStorage.history.removeAll()
                                                Task {
                                                    await quizStorage.save(history: [])
                                                }
                                                showingAllQuizzes = false
                                            }),
                                            .cancel()
                                        ]
                                    )
                                }
                            }
                        }
                    }
                }
                .sheet(isPresented: $showingSettingsSheet) {
                    NavigationStack {
                        Form {
                            Section {
                                SecureField("Top Secret Gemini API Key", text: $userPreferences.apiKey)
                                    .onChange(of: userPreferences.selectedOption) { newValue in
                                        print("Selected option changed to: \(newValue)")
                                    }
                            } header: {
                                Text("API Key")
                            } footer: {
                                Text("Grab one for free from [makersuite.google.com](https://makersuite.google.com/app/apikey)\n**Reminder: Never share API keys.**")
                            }
                            
                            Section {
                                Picker("Preferred Model", selection: $userPreferences.selectedOption) {
                                    ForEach(options, id: \.self) { option in
                                        HStack {
                                            if option == "Gemini 1.5 Flash" {
                                                Label(" \(option)", systemImage: "bolt.fill")
                                            } else {
                                                Label(" \(option)", systemImage: "brain.head.profile")
                                            }
                                        }
                                    }
                                }
                            } header: {
                                Text("Choose Model")
                            } footer: {
                                if userPreferences.selectedOption == "Gemini 1.5 Flash" {
                                    Text("You will receive a **faster response** but not necessarily a smarter, more accurate quiz.")
                                } else {
                                    Text("You will receive a **smarter response** but not necessarily in a short amount of time.")
                                }
                            }
                            .onChange(of: userPreferences.selectedOption) { newValue in
                                // Perform any additional actions when the selected option changes.
                                // This block can be used to trigger side effects of changing the option.
                                // If no additional action is needed, this `.onChange` modifier can be removed.
                            }
                            
                            Section("Privacy") {
                                Toggle("Save Quiz Results", isOn: .constant(true))
                                Toggle("Improve Gemini for Everyone", isOn: .constant(true))
                            }
                        }
                        .navigationTitle("Settings")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .topBarTrailing) {
                                Button("Done") {
                                    showingSettingsSheet = false
                                }
                            }
                        }
                    }
                    .presentationDetents([.medium, .large])
                }
                
            }
        }
    }
    func loadQuiz(from url: URL) async {
        do {
            print(url)
            let data = try Data(contentsOf: url)
            // Step 1: Deserialize the JSON data into a mutable structure
            if let fullQuizDictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               var quizDictionary = fullQuizDictionary["quiz"] as? [String: Any] {
                // Step 2: Remove the userAnswers field
                quizDictionary.removeValue(forKey: "userAnswers")
                
                // Step 3: Serialize the modified structure (without the quiz wrapper) back into JSON data
                let modifiedData = try JSONSerialization.data(withJSONObject: quizDictionary, options: [])
                
                // Step 4: Convert modified data to a pretty-printed string for verification
                if let prettyPrintedString = String(data: modifiedData, encoding: .utf8) {
                    print("Modified JSON:\n\(prettyPrintedString)")
                }
                
                // Step 5: Decode the modified JSON data into the Quiz object
                // Assuming the Quiz struct is designed to directly decode this modified structure
                let quiz1 = try JSONDecoder().decode(Quiz.self, from: modifiedData)
                // Assuming you have a way to update your quiz data
                self.quiz = quiz1
                showQuiz.toggle()
            } else {
                print("Could not deserialize JSON into a dictionary.")
            }
        } catch {
            print("Failed to load quiz: \(error.localizedDescription)")
        }
    }
}

struct QuizResultsView: View {
    let userAnswers: [UserAnswer]
    var body: some View {
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
                                Text(correctAnswer)
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    Group {
        @StateObject var quizStorage = QuizStorage()
        
        ContentView()
            .environmentObject(quizStorage)
    }
}
extension CGSize {
    func fits(largestDimension length: CGFloat) -> Bool {
        return width <= length && height <= length
    }
    
    func aspectFit(largestDimension length: CGFloat) -> CGSize {
        let aspectRatio = width / height
        if width > height {
            let width = min(self.width, length)
            return CGSize(width: width, height: round(width / aspectRatio))
        } else {
            let height = min(self.height, length)
            return CGSize(width: round(height * aspectRatio), height: height)
        }
    }
}
