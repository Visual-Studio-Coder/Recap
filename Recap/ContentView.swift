//
//  ContentView.swift
//  Recap
//
//  Created by Aaron Ma on 5/25/24.
//

import SwiftUI
import PhotosUI
import MarkdownUI
import Splash
import LinkPresentation

@MainActor
class UserPreferences: ObservableObject {
    static let shared = UserPreferences()
    
    @Published var somePreference: Bool {
        didSet {
            UserDefaults.standard.set(somePreference, forKey: "somePreference")
        }
    }
    
    @Published var chatGPTAPIKey: String {
        didSet {
            UserDefaults.standard.set(chatGPTAPIKey, forKey: "chatGPTAPIKey")
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
    
    @Published var gptModel: String {
        didSet {
            UserDefaults.standard.set(gptModel, forKey: "gptModel")
        }
    }
    
    init() {
        self.somePreference = UserDefaults.standard.bool(forKey: "somePreference")
        self.chatGPTAPIKey = UserDefaults.standard.string(forKey: "chatGPTAPIKey") ?? ""
        self.apiKey = UserDefaults.standard.string(forKey: "apiKey") ?? ""
        self.selectedOption = UserDefaults.standard.string(forKey: "model") ?? "gemini-1.5-pro-latest"
        self.numberOfQuestions = UserDefaults.standard.integer(forKey: "numberOfQuestions")
        self.geminiModel = UserDefaults.standard.string(forKey: "geminiModel") ?? AppSettings.geminiModel
        self.gptModel = UserDefaults.standard.string(forKey: "gptModel") ?? AppSettings.gptModel
    }
}
struct ContentView: View {
    @EnvironmentObject var quizStorage: QuizStorage
    @EnvironmentObject var userPreferences: UserPreferences
    @Environment(\.colorScheme) private var colorScheme
    
    @FocusState private var focus: FocusField?
    
    enum FocusField: Hashable {
        case api, quizPrompt
    }
    
    @AppStorage("apiKey") private var apiKey = ""
    
    // Gemini
    let geminiAPI = GeminiAPI.shared
    //@AppStorage("model") private var selectedOption = "gemini-1.5-pro-latest"
    let options = ["gemini-1.5-pro-latest", "gemini-1.5-flash"]
    let gptOptions = ["gpt-3.5-turbo", "gpt-4-turbo", "gpt-4o"]
    
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
        //        if showQuiz, let quiz = quiz {
        //            QuizView(quiz: quiz, showQuiz: $showQuiz)
        //                .environmentObject(quizStorage)
        //                .onAppear {
        //                    gemeniGeneratingQuiz = false
        //                }
        //        } else {
        NavigationStack {
            ZStack {
                //                if !quizStorage.history.isEmpty {
                //                    ScrollView {
                //                        VStack {
                //
                //                            Text("Recent Quizzes")
                //                                .font(.title)
                //                                .bold()
                //                            Button(action: {
                //                                // Show action sheet to confirm clearing history
                //                                showingClearHistoryActionSheet = true
                //                            }) {
                //                                Label("Clear History", systemImage: "trash")
                //                            }
                //                            .actionSheet(isPresented: $showingClearHistoryActionSheet) {
                //                                ActionSheet(
                //                                    title: Text("Are you sure you want to clear history?"),
                //                                    buttons: [
                //                                        .destructive(Text("Clear"), action: {
                //                                            quizStorage.history.removeAll()
                //                                            Task {
                //                                                await quizStorage.save(history: [])
                //                                            }
                //                                        }),
                //                                        .cancel()
                //                                    ]
                //                                )
                //                            }
                //                            .foregroundStyle(.red)
                //
                //                        }
                //                        .padding(.leading)
                //
                //                        //List {
                //                        ForEach(quizStorage.history.indices.reversed().prefix(3), id: \.self) { i in
                //                            Menu {
                //                                //share quiz
                //                                ShareLink(item: ExportableQuiz(quiz: quizStorage.history[i]), preview: SharePreview(quizStorage.history[i].quiz_title, icon: "square.and.arrow.up"))
                //                                Button(action: {
                //                                    //remove current quiz:
                //                                    quiz = quizStorage.history[i]
                //                                    withAnimation {
                //                                        showQuiz.toggle()
                //                                    }
                //                                    quizStorage.history.remove(at: i)
                //                                }) {
                //                                    Label("Take Quiz Again", systemImage: "arrow.clockwise")
                //                                }
                //                                Button(action: {
                //                                    DispatchQueue.main.async {
                //                                        quiz = quizStorage.history[i]
                //                                    }
                //                                    showingQuizResults.toggle()
                //                                }) {
                //                                    Label("View Past Results", systemImage: "text.book.closed")
                //                                }
                //
                //                                Button(action: {
                //                                    // Implement action to regenerate the quiz
                //                                }) {
                //                                    Label("Regenerate Quiz", systemImage: "gobackward")
                //                                }
                //                            } label: {
                //                                HStack {
                //                                    VStack(alignment: .leading) {
                //                                        Text(quizStorage.history[i].quiz_title)
                //                                            .bold()
                //
                //                                        Text("\(quizStorage.history[i].questions.count) Questions")
                //                                            .foregroundStyle(.secondary)
                //                                    }
                //                                    Spacer()
                //                                    //                                        if quizStorage.history[i].userAnswers != nil {
                //                                    //                                            Text("\(quizStorage.history[i].userAnswers!.filter { $0.isCorrect == true }.count)/\(quizStorage.history[i].questions.count) (\(Int((Double(quizStorage.history[i].userAnswers!.filter { $0.isCorrect == true }.count) / Double(quizStorage.history[i].questions.count)) * 100))%)")
                //                                    //                                                .foregroundStyle(.secondary)
                //                                    //                                        }
                //                                    if let userAnswers = quizStorage.history[i].userAnswers {
                //                                        Text("\((userAnswers.filter { $0.isCorrect }.count))/\(quizStorage.history[i].questions.count) (\(String(format: "%.0f", (Double(userAnswers.filter { $0.isCorrect }.count) / Double(quizStorage.history[i].questions.count) * 100)))%)")
                //                                            .foregroundStyle(.secondary)
                //                                    }
                //                                }
                //                                .padding()
                //                            }
                //                        }
                //                        //}
                //
                //                        if quizStorage.history.count > 3 {
                //                            Button(action: {
                //                                // Show all quizzes
                //                                showingAllQuizzes.toggle()
                //                            }) {
                //                                Text("Show All Quizzes")
                //                                    .font(.headline)
                //                                    .foregroundStyle(.blue)
                //                            }
                //                        }
                //                    }
                //                    .scrollDismissesKeyboard(.interactively)
                //                }
                ScrollView {
                    Spacer()
                }
                .scrollDismissesKeyboard(.interactively)
                VStack(alignment: .leading) {
                    Spacer()
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            if !userInput.isEmpty {
                                ZStack(alignment: .topTrailing) {
                                    VStack {
                                        Image(systemName: "text.quote")
                                            .interpolation(.none)
                                            .resizable()
                                            .frame(width: 40, height: 40)
                                            .padding([.top, .bottom], 5)
                                        
                                        Text(userInput)
                                            .lineLimit(1)
                                            .padding(.horizontal, 2)
                                    }
                                    .frame(width: 100, height: 100)
                                    .background(Color.accentColor.opacity(0.4))
                                    .cornerRadius(16)
                                    //.clipShape(RoundedRectangle(cornerRadius: 16))
                                    
                                    Button {
                                        userInput = ""
                                    } label: {
                                        Image(systemName: "xmark")
                                            .font(.system(size: 13, weight: .bold)) // Make the X mark bold
                                            .foregroundStyle(.white)
                                            .padding(2)
                                            .background(Color.gray)
                                            .clipShape(Circle())
                                            .overlay(
                                                Circle()
                                                    .stroke(Color.white, lineWidth: 2) // Add a white outline
                                            )
                                    }
                                    .padding(3)
                                }
                            }
                            
                            ForEach(selectedPhotosData, id: \.self) { photoData in
                                if let image = UIImage(data: photoData) {
                                    ZStack(alignment: .topTrailing) {
                                        Image(uiImage: image)
                                            .resizable()
                                            .frame(width: 100, height: 100)
                                            .cornerRadius(16.0)
                                        
                                        Button {
                                            if let index = selectedPhotosData.firstIndex(of: photoData) {
                                                selectedPhotosData.remove(at: index)
                                            }
                                            
                                            //                                                if let index = selectedItems.flatMap({
                                            //                                                    if let data = try? await $0.loadTransferable(type: Data.self) {
                                            //                                                        data
                                            //                                                    }
                                            //                                                }).firstIndex(of: photoData) {
                                            //                                                    selectedItems.remove(at: index)
                                            //                                                }
                                        } label: {
                                            Image(systemName: "xmark")
                                                .font(.system(size: 13, weight: .bold)) // Make the X mark bold
                                                .foregroundStyle(.white)
                                                .padding(2)
                                                .background(Color.gray)
                                                .clipShape(Circle())
                                                .overlay(
                                                    Circle()
                                                        .stroke(Color.white, lineWidth: 2) // Add a white outline
                                                )
                                        }
                                        .padding(3)
                                    }
                                }
                            }
                            
                            ForEach(links.indices, id: \.self) { i in
                                if links[i].isValidURL(), let url = URL(string: links[i]) {
                                    ZStack(alignment: .topTrailing) {
                                        VStack {
                                            //                                        AsyncImage(url: URL(string: "https://icons.duckduckgo.com/ip3/\(url.host!).ico")) { image in
                                            //                                            image
                                            //                                                .interpolation(.none)
                                            //                                                .resizable()
                                            //                                                .frame(width: 40, height: 40)
                                            //                                        } placeholder: {
                                            //                                            ProgressView()
                                            //                                        }
                                            LinkPreview(url: url)
                                                .frame(maxHeight: 100)
                                                
                                            
                                            
                                            
                                            //                                        Text(url.host!)
                                            //                                            .lineLimit(1)
                                            //                                            .padding(.horizontal, 2)
                                        }
                                        // .frame(width: 100, height: 100)
                                        .background(Color.accentColor.opacity(0.4))
                                        .cornerRadius(16)
                                        //.clipShape(RoundedRectangle(cornerRadius: 16))
                                        
                                        Button {
                                            links.remove(at: i)
                                        } label: {
                                            Image(systemName: "xmark")
                                                .font(.system(size: 13, weight: .bold)) // Make the X mark bold
                                                .foregroundStyle(.white)
                                                .padding(2)
                                                .background(Color.gray)
                                                .clipShape(Circle())
                                                .overlay(
                                                    Circle()
                                                        .stroke(Color.white, lineWidth: 2) // Add a white outline
                                                )
                                            
                                        }
                                        .padding(3)
                                    }
                                }
                            }
                            Spacer()
                        }
                    }
                    .mask {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white) // or any other background color
                    }
                    .padding(.horizontal)
                    
                    HStack {
                        TextField("What would you like to quiz yourself on?", text: $userInput, axis: .vertical)
                            .autocorrectionDisabled()
                            .focused($focus, equals: .quizPrompt)
                            .padding()
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                            .overlay(RoundedRectangle(cornerRadius: 15).stroke(.gray, lineWidth: 1))
                            .padding(.horizontal)
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
                                        if url.host?.contains("youtube") == true || url.host?.contains("youtu.be") == true {
                                            // Handle YouTube links
                                            let videoId = extractYouTubeVideoID(from: url)
                                            if let videoId = videoId {
                                                Task {
                                                    do {
                                                        let transcript = try await YouTubeTranscript.fetchTranscript(for: videoId)
                                                        websiteContent += transcript
                                                    } catch {
                                                        print("Failed to fetch YouTube transcript for video ID \(videoId): \(error)")
                                                    }
                                                    group.leave()
                                                }
                                            } else {
                                                group.leave()
                                            }
                                        } else {
                                            // Handle regular web links
                                            do {
                                                let contents = try String(contentsOf: url)
                                                let atr = try! NSAttributedString(data: contents.data(using: .unicode)!, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
                                                let plainString = atr.string
                                                websiteContent += plainString
                                            } catch {
                                                print("Failed to load contents of URL \(url): \(error)")
                                            }
                                            group.leave()
                                        }
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
                .navigationTitle("Recap")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showingSettingsSheet = true
                        } label: {
                            Label("Settings", systemImage: "gearshape")
                        }
                    }
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            showingAllQuizzes = true
                        } label: {
                            Label("History", systemImage: "clock.arrow.circlepath")
                        }
                    }
                }
                .alert("To use Recap, enter your API key!", isPresented: $showingGeminiAPIAlert) {
                    Button("Open Settings") {
                        showingSettingsSheet.toggle()
                        focus = .api
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
                    if apiKey != "" {
                        Task {
                            await loadQuiz(from: url)
                        }
                    } else {
                        showingGeminiAPIAlert = true
                    }
                }
                .sheet(isPresented: $showingURLSheet) {
                    NavigationStack {
                        Form {
                            Section {
                                ForEach(links.indices, id: \.self) { index in
                                    TextField("Enter URL #\(index + 1)", text: $links[index])
                                        .autocorrectionDisabled()
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
                            } header: {
                                if links.count >= 1 {
                                    Text("Add up to 5 URLs")
                                }
                            }
                            
                            Section {
                                // Button {
                                //     links.append("")
                                // } label: {
                                //     Label("Add New Link", systemImage: "plus")
                                // }
                                // .disabled(links.count == 5)
                                Menu {
                                    //use clipboard
                                    Button {
                                        if let clipboard = UIPasteboard.general.string {
                                            links.append(clipboard)
                                        }
                                    } label: {
                                        Label("Paste from Clipboard", systemImage: "doc.on.clipboard")
                                    }
                                    .disabled(links.count == 5)
                                    
                                } label: {
                                    Label("Add New Link", systemImage: "plus")
                                        .foregroundStyle((links.count == 5) ? .secondary : .primary)
                                } primaryAction: {
                                    links.append("")
                                }
                                .disabled(links.count == 5)
                                
                            } footer: {
                                Markdown("Tip: Long press on the `Add New Link` button in order to paste a URL.")
                            }
                        }
                        .navigationTitle("Scan URLs")
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
                            ForEach(quizStorage.history.indices.reversed(), id: \.self) { i in
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
                                    .primaryAction) {
                                        Button("Done") {
                                            showingAllQuizzes = false
                                        }
                                    }
                            ToolbarItem(placement: .destructiveAction) {
                                Button("Clear All") {
                                    showingClearHistoryActionSheet = true
                                }
                                .foregroundStyle(.red)
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
                .fullScreenCover(isPresented: $showQuiz, content: {
                    if let quiz = quiz {
                        QuizView(quiz: quiz, showQuiz: $showQuiz)
                            .environmentObject(quizStorage)
                            .onAppear {
                                gemeniGeneratingQuiz = false
                            }
                    }
                })
                .sheet(isPresented: $showingSettingsSheet) {
                    NavigationStack {
                        Form {
                            Section("AI Model") {
                                Toggle(isOn: .constant(true)) {
                                    Label("Use Gemini", systemImage: "cpu")
                                }
                            }
                            
                            Section("App Details") {
                                DisclosureGroup {
                                    Markdown("""
                                # Privacy Policy
                                
                                ## User Data
                                We do not collect any data from our users. All quizzes are saved locally on your device, and we do not access or store:
                                - Images
                                - URLs
                                - Notes you add to your quizzes
                                
                                Additionally, we do not collect any analytics. Please continue reading to understand the terms and conditions Google's Gemini and OpenAI's ChatGPT impose on your data.
                                
                                ## Third-Party Services
                                We integrate with Google's Gemini and OpenAI's ChatGPT to provide multi-modal models for quiz generation. When you use these services, we provide them with the following user information:
                                - Images
                                - URLs
                                - Text-based notes (anything you input to make a quiz)
                                
                                This information is necessary for the models to generate quizzes. However, please be aware that:
                                - You should not enter any sensitive information into these models, as we cannot guarantee that OpenAI or ChatGPT will collect and keep this data for training models.
                                - If you are using the free API key from Google, they may train models on your prompts and you may be susceptible to rate limits.
                                - If you are using ChatGPT's API key, their privacy policy claims that your requests will not be logged, but you should still exercise caution.
                                
                                Please review the terms of service and privacy policies for these third-party services:
                                - Google Gemini: [ai.google.dev/gemini-api/terms](https://ai.google.dev/gemini-api/terms)
                                - OpenAI's ChatGPT: [openai.com/policies/privacy-policy/](https://openai.com/policies/privacy-policy/)
                                """)
                                    
                                } label: {
                                    Label("Privacy Policy", systemImage: "hand.raised.circle.fill")
                                }
                                
                            }
                            
                            Section {
                                NavigationLink {
                                    Form {
                                        Section {
                                            SecureField("Top Secret Gemini API Key", text: $userPreferences.apiKey)
                                                .focused($focus, equals: .api)
                                                .onChange(of: userPreferences.selectedOption) {
                                                    print("Selected option changed to: \(userPreferences.selectedOption)")
                                                }
                                        } header: {
                                            Text("API Key")
                                        } footer: {
                                            Text("Get a free API key from [makersuite.google.com](https://makersuite.google.com/app/apikey).\n**Reminder: Never share API keys.**")
                                        }
                                        
                                        Section {
                                            Picker("Preferred Model", selection: $userPreferences.selectedOption) {
                                                ForEach(options, id: \.self) { option in
                                                    HStack {
                                                        if option == "gemini-1.5-pro-latest" {
                                                            Label(" Gemini 1.5 Pro", systemImage: "bolt.fill")
                                                        } else {
                                                            Label(" Gemini 1.5 Flash", systemImage: "brain.head.profile")
                                                        }
                                                    }
                                                }
                                            }
                                        } header: {
                                            Text("Choose Model")
                                        } footer: {
                                            if userPreferences.selectedOption == "gemini-1.5-flash" {
                                                Text("Prioritize **faster response** over accuracy.")
                                            } else {
                                                Text("Prioritize **accuracy** over speed.")
                                            }
                                        }
                                        .onChange(of: userPreferences.selectedOption) {
                                            // Perform any additional actions when the selected option changes.
                                            // This block can be used to trigger side effects of changing the option.
                                            // If no additional action is needed, this `.onChange` modifier can be removed.
                                        }
                                        
                                        Section("Privacy") {
                                            Toggle("Save Quiz Results", isOn: .constant(true))
                                            Toggle("Improve Gemini for Everyone", isOn: .constant(true))
                                        }
                                    }
                                    .navigationTitle("Gemini")
                                } label: {
                                    Text("Gemini")
                                }
                                
                                NavigationLink {
                                    Form {
                                        Section {
                                            SecureField("Top Secret OpenAI API Key", text: $userPreferences.chatGPTAPIKey)
                                                .focused($focus, equals: .api)
                                                .onChange(of: userPreferences.selectedOption) {
                                                    print("Selected option changed to: \(userPreferences.selectedOption)")
                                                }
                                        } header: {
                                            Text("API Key")
                                        } footer: {
                                            Text("Get an API key from [platform.openai.com](https://platform.openai.com/playground).\n**Reminder: Never share API keys.**")
                                        }
                                        
                                        Section {
                                            Picker("Preferred Model", selection: $userPreferences.selectedOption) {
                                                ForEach(gptOptions, id: \.self) { option in
                                                    HStack {
                                                        if option == "gpt-3.5-turbo" {
                                                            Label(" GPT 3.5 Turbo", systemImage: "bolt.fill")
                                                        } else if option == "gpt-4-turbo" {
                                                            Label(" GPT 4 Turbo", systemImage: "brain.head.profile")
                                                        } else {
                                                            Label(" GPT 4o", systemImage: "brain.head.profile")
                                                        }
                                                    }
                                                }
                                            }
                                        } header: {
                                            Text("Choose Model")
                                        } footer: {
                                            if userPreferences.selectedOption == "gpt-3.5-turbo" {
                                                Text("Prioritize **speed** over accuracy. (in: $0.5, out: $1.5)")
                                            } else if userPreferences.selectedOption == "gpt-4-turbo" {
                                                Text("Prioritize **speed** over accuracy. (in: $10, out: $30)")
                                            } else {
                                                Text("Prioritize **accuracy** over speed. (in: $5, out: $15)")
                                            }
                                        }
                                    }
                                    .navigationTitle("ChatGPT")
                                } label: {
                                    Text("ChatGPT")
                                }
                            } header: {
                                Text("AI Model Configurations")
                            } footer: {
                                Text("Add your API keys and configure how you want the AI to respond.")
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
            //        }
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
    // Helper function to extract YouTube video ID from URL
    func extractYouTubeVideoID(from url: URL) -> String? {
        if let host = url.host, host.contains("youtube.com") {
            return URLComponents(url: url, resolvingAgainstBaseURL: false)?
                .queryItems?
                .first(where: { $0.name == "v" })?
                .value
        } else if let host = url.host, host.contains("youtu.be") {
            return url.lastPathComponent
        }
        return nil
    }
}


struct LinkPreview: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> LPLinkView {
        let linkView = LPLinkView(url: url)
        let provider = LPMetadataProvider()
        
        provider.startFetchingMetadata(for: url) { metadata, error in
            if let metadata = metadata {
                DispatchQueue.main.async {
                    // Create a new metadata object with only the icon
                    let iconOnlyMetadata = LPLinkMetadata()
                    iconOnlyMetadata.iconProvider = metadata.iconProvider
                    iconOnlyMetadata.title = metadata.title
                    iconOnlyMetadata.originalURL = nil
                    iconOnlyMetadata.url = metadata.originalURL
                    iconOnlyMetadata.imageProvider = nil
                    iconOnlyMetadata.remoteVideoURL = nil
                    iconOnlyMetadata.videoProvider = nil
                    
                    linkView.metadata = iconOnlyMetadata
                }
            }
        }
        
        return linkView
    }
    
    func updateUIView(_ uiView: LPLinkView, context: Context) {
        // No update needed
    }
}

struct QuizResultsView: View {
    @Environment(\.colorScheme) private var colorScheme
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

#Preview {
    @Previewable @StateObject var quizStorage = QuizStorage()
    
    Group {
        ContentView()
            .environmentObject(quizStorage)
    }
}
