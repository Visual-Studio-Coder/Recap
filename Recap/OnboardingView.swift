import SwiftUI

struct OnboardingView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject var userPreferences: UserPreferences
    
    @State private var currentTab = 0
    @State private var showApiKeyInfo = false
    @FocusState private var apiKeyFocused: Bool
    
    // Update Gemini version references
    let options = ["gemini-2.0-pro-exp-02-05", "gemini-2.0-flash"]
    
    // Brown gradient colors
    let gradientColors = [
        Color(red: 0.6, green: 0.4, blue: 0.2), // Warm brown
        Color(red: 0.8, green: 0.6, blue: 0.4), // Light tan
        Color(red: 0.4, green: 0.2, blue: 0.1)  // Deep chocolate
    ]
    
    var body: some View {
        ZStack {
            // Rich brown gradient background
            LinearGradient(
                gradient: Gradient(colors: gradientColors),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .opacity(0.8)
            
            // Add a subtle pattern overlay
            Color.white.opacity(0.05)
                .ignoresSafeArea()
            
            TabView(selection: $currentTab) {
                // Welcome page
                pageContainer(content: welcomeContent, buttonText: "Get Started") {
                    withAnimation {
                        currentTab = 1
                    }
                }
                .tag(0)
                
                // API Key page
                pageContainer(content: apiKeyContent, buttonText: "Next", buttonDisabled: userPreferences.apiKey.isEmpty) {
                    withAnimation {
                        currentTab = 2
                        apiKeyFocused = false
                    }
                }
                .tag(1)
                
                // Model selection page
                pageContainer(content: modelSelectionContent, buttonText: "Next") {
                    withAnimation {
                        currentTab = 3
                    }
                }
                .tag(2)
                
                // Safety settings page
                pageContainer(content: safetySettingsContent, buttonText: "Get Started") {
                    // Initialize Gemini with user preferences
                    GeminiAPI.initialize(
                        with: userPreferences.apiKey,
                        modelName: userPreferences.selectedOption,
                        selectedLanguage: userPreferences.selectedLanguage,
                        safetySettings: userPreferences.safetySettings,
                        numberOfQuestions: userPreferences.numberOfQuestions
                    )
                    
                    // Complete onboarding
                    dismiss()
                }
                .tag(3)
            }
            .tabViewStyle(
                PageTabViewStyle(indexDisplayMode: .never) // Properly hide the dots
            )
            .animation(.easeInOut, value: currentTab)
            .transition(.slide)
        }
    }
    
    // Fix: Changed from generic to concrete View parameter
    private func pageContainer(content: some View, buttonText: String, buttonDisabled: Bool = false, action: @escaping () -> Void) -> some View {
        VStack(spacing: 0) {
            // Content in ScrollView
            ScrollView {
                content
                    .padding()
                    // Add padding at bottom to ensure content can scroll above button
                    .padding(.bottom, 80)
            }
            
            // Fixed button at bottom - removed background
            VStack {
                Button(action: action) {
                    Text(buttonText)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .font(.headline)
                }
                .buttonStyle(BrownButtonStyle())
                .padding(.horizontal, 20)
                .padding(.vertical, 15)
                .disabled(buttonDisabled)
                .opacity(buttonDisabled ? 0.5 : 1)
            }
        }
    }
    
    // Break down the page content to be used within containers
    private var welcomeContent: some View {
        VStack(spacing: 20) { // Reduced spacing
            Spacer(minLength: 10) // Reduced minimum spacing
            
            Image(systemName: "brain.head.profile")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 120, height: 120)
                .foregroundColor(.white)
                .padding()
                .background(
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [gradientColors[1], gradientColors[0]]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
                )
            
            Text("Welcome to Recap AI")
                .font(.system(size: 38, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .shadow(color: Color.black.opacity(0.2), radius: 2)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            
            // Removed "Your personal quiz generator..." text
            
            Spacer(minLength: 5) // Reduced spacing
            
            VStack(alignment: .leading, spacing: 20) { // Reduced spacing
                featureRow(icon: "brain.head.profile", title: "Create Personalized Quizzes", description: "Generate quizzes based solely on your notes from class")
                
                featureRow(icon: "dollarsign.arrow.circlepath", title: "Education Free of Charge", description: "AI-powered quizzes without any ads")
                
                featureRow(icon: "doc", title: "Attach Anything", description: "Add images, URLs, PDFs, YouTube videos, and text")
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.15))
                    .shadow(color: Color.black.opacity(0.2), radius: 10)
            )
            .padding(.horizontal)
            
            Spacer()
        }
    }
    
    private var apiKeyContent: some View {
        VStack(spacing: 25) {
            Spacer(minLength: 20)
            
            Image(systemName: "key.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .foregroundColor(.white)
                .padding()
                .background(
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [gradientColors[1], gradientColors[0]]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
                )
            
            Text("API Key Required")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .shadow(color: Color.black.opacity(0.2), radius: 2)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            
            Text("Recap uses Google Gemini to power its AI features")
                .font(.title3)
                .multilineTextAlignment(.center)
                .foregroundColor(.white.opacity(0.9))
                .padding(.horizontal)
                .fixedSize(horizontal: false, vertical: true)
            
            VStack(spacing: 15) {
                // Updated text field styling with transparent background
                SecureField("Enter your Gemini API key", text: $userPreferences.apiKey)
                    .onChange(of: userPreferences.apiKey) {
                        GeminiAPI.initialize(with: userPreferences.apiKey, modelName: userPreferences.selectedOption, selectedLanguage: userPreferences.selectedLanguage, safetySettings: userPreferences.safetySettings, numberOfQuestions: userPreferences.numberOfQuestions)
                    }
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(10)
                    .foregroundColor(.white)
                    .accentColor(.white)
                    .focused($apiKeyFocused)
                    .submitLabel(.done)
                
                // Always show the API key info
                VStack(alignment: .leading) {
                    Text("Get your free API key from Google AI Studio:")
                        .font(.callout)
                        .foregroundColor(.white)
                        //.fixedSize(horizontal: false, vertical: true)
                    
                    // Button instead of Link
                    Button {
                        if let url = URL(string: "https://makersuite.google.com/app/apikey") {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        HStack {
                            Text("Get API Key")
                                .foregroundColor(.white)
                                .fontWeight(.semibold)
                            
                            Image(systemName: "arrow.up.right")
                                .font(.footnote.bold())
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [gradientColors[1], gradientColors[0]]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                    }
                }
                //.padding(.vertical, 5)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.15))
                    .shadow(color: Color.black.opacity(0.2), radius: 10)
            )
            .padding(.horizontal)
            
            Spacer()
        }
        // .onAppear {
        //     // Auto-focus the API key field
        //     DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        //         apiKeyFocused = true
        //     }
        // }
    }
    
    private var modelSelectionContent: some View {
        VStack(spacing: 25) {
            Spacer(minLength: 20)
            
            Image(systemName: "cpu.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .foregroundColor(.white)
                .padding()
                .background(
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [gradientColors[1], gradientColors[0]]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
                )
            
            Text("Choose Your Model")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .shadow(color: Color.black.opacity(0.2), radius: 2)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            
            Text("Select which Gemini model you'd like to use")
                .font(.title3)
                .multilineTextAlignment(.center)
                .foregroundColor(.white.opacity(0.9))
                .padding(.horizontal)
                .fixedSize(horizontal: false, vertical: true)
            
            VStack(spacing: 20) {
                // Update model names to Gemini 2.0
                modelOptionCard(
                    option: "gemini-2.0-pro-exp-02-05",
                    title: "Gemini 2.0 Pro",
                    description: "Prioritize accuracy over speed",
                    icon: "brain.head.profile"
                )
                
                modelOptionCard(
                    option: "gemini-2.0-flash",
                    title: "Gemini 2.0 Flash",
                    description: "Prioritize faster response over accuracy",
                    icon: "bolt.fill"
                )
            }
            .padding(.horizontal)
            
            Spacer()
        }
    }
    
    private var safetySettingsContent: some View {
        VStack(spacing: 25) {
            Spacer(minLength: 20)
            
            Image(systemName: "checkmark.shield.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .foregroundColor(.white)
                .padding()
                .background(
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [gradientColors[1], gradientColors[0]]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
                )
            
            Text("Safety Settings")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .shadow(color: Color.black.opacity(0.2), radius: 2)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            
            Text("Would you like to enable content filtering?")
                .font(.title3)
                .multilineTextAlignment(.center)
                .foregroundColor(.white.opacity(0.9))
                .padding(.horizontal)
                .fixedSize(horizontal: false, vertical: true)
            
            VStack(alignment: .leading, spacing: 20) {
                Toggle("Enable Safety Settings", isOn: $userPreferences.safetySettings)
                    .foregroundColor(.white)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.2))
                    )
                
                if userPreferences.safetySettings {
                    Text("Content which contains high amounts of harassment, hate speech, sexually explicit, or dangerous content will be blocked.")
                        .font(.callout)
                        .foregroundColor(.white.opacity(0.9))
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    Text("No content filtering will be applied. Note that this may result in inappropriate content being generated.")
                        .font(.callout)
                        .foregroundColor(.white.opacity(0.9))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.15))
                    .shadow(color: Color.black.opacity(0.2), radius: 10)
            )
            .padding(.horizontal)
            
            Spacer()
        }
    }
    
    // Helper views
    private func featureRow(icon: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .bold))
                .frame(width: 32)
                .foregroundColor(.white)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                    .fixedSize(horizontal: false, vertical: true)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
    
    private func modelOptionCard(option: String, title: String, description: String, icon: String) -> some View {
        Button {
            userPreferences.selectedOption = option
        } label: {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.white)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
                
                if userPreferences.selectedOption == option {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 22))
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                userPreferences.selectedOption == option ? gradientColors[0] : Color.white.opacity(0.1),
                                userPreferences.selectedOption == option ? gradientColors[0].opacity(0.7) : Color.white.opacity(0.2)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(userPreferences.selectedOption == option ? Color.white : Color.clear, lineWidth: 2)
                    )
                    .shadow(color: Color.black.opacity(0.2), radius: 5)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Custom brown button style
struct BrownButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.7, green: 0.5, blue: 0.3),
                        Color(red: 0.5, green: 0.3, blue: 0.1)
                    ]),
                    startPoint: configuration.isPressed ? .bottomTrailing : .topLeading,
                    endPoint: configuration.isPressed ? .topLeading : .bottomTrailing
                )
            )
            .cornerRadius(15)
            .shadow(color: Color.black.opacity(0.3), radius: configuration.isPressed ? 2 : 5)
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}
