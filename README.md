![Frame 1 (2)](https://github.com/user-attachments/assets/95b148f2-c73a-44b2-857e-35ed897aff4c)

## Features
<details>

<summary>🤖 AI powered quiz generation based on user notes</summary>

- 🖼️, 🔗, 📝: Input images, URLs, and plain text
  - YouTube integration: Input URLs to videos with a transcript
- Supported question formats include multiple choice, multi-select, and free-response (AI-powered grading)
</details>
<details>

<summary>💬 Evaluate your understanding with AI-feedback</summary>

- We offer an `Explain` button, allowing users to understand why each option in a question is correct/incorrect
- Free Response evaluates whether a user's response is correct, and it offers ways to improve their response, reguardless of whether they got it correct or not.
- Performance feedback at the end of a quiz means that Recap can recommend reading material and concepts to work on based on the user's performance.
</details>

<details>

<summary>🕰️ Recap includes quiz history</summary>

- View list of past quizzes
- Share the quiz file with friends
- Retake the quiz (or even regenerate it!)
- View past results
</details>

## Why Recap?
TL;DR
> Recap is _the best_ way to ensure you understand a concept. Most online resources and practice don't cover _exactly_ what you learn at school. How do you know if you have fully understood a concept or not? You for sure don't want to "wait and find out 😣".

<details>
    <summary>More information:</summary>

- **Impact**: We are the first quizzing iOS app to use Gemini's large context window to deliver accurate quizzes. Our solution is designed to be easy and enjoyable for everyone, including people with disabilities. SwiftUI provides robust accessibility features out-of-the-box, such as VoiceOver, Dynamic Type, and support for various input methods. By choosing SwiftUI, we ensure that our app is accessible to a wider audience, including those with visual, auditory, and motor impairments. Additionally, we have localized the app to Spanish, making it accessible to a broader user base. Our app has the potential to contribute meaningfully to improving people's lives by providing personalized learning experiences.

- **Remarkability**: Our approach is surprising both to those well-versed and not well-versed in Large Language Models (LLM). The use of Gemini 1.5 Pro for personalized quizzing is unprecedented. This innovative use of LLM technology sets our app apart from existing solutions and showcases the potential of advanced AI in educational tools.

- **Creativity**: Recap differs from existing applications in both functionality and user experience. We use creative problem-solving approaches to offer a unique and personalized quizzing experience. Our app supports input from various resources like images, URLs, and plaintext, which is not commonly found in other quizzing apps. This flexibility allows users to create quizzes tailored to their specific learning materials.

- **Usefulness**: We have a well-defined target user persona—students who need personalized quizzes to reinforce their learning. Our solution addresses specific user needs by allowing input from various resources like images, URLs, and plaintext. The app's design ensures that it meets these needs effectively, helping users to better understand and retain the concepts they are studying.

- **Execution**: The solution is well-designed and adheres to software engineering practices. The LLM component is also well-designed and follows Machine Learning (ML)/LLM best practices. By leveraging SwiftUI, we ensure that our app is not only visually appealing but also highly accessible and inclusive. The app's architecture and code quality are robust, modular, and maintainable, ensuring that it can be easily extended and updated in the future. We follow best practices such as code reviews and continuous integration to maintain high standards of code quality and reliability.

</details>

## How to generate a quiz using Recap
1. Install [Recap](https://apps.apple.com/us/app/recap-ai/id6602897472) from the App Store.
- You can also follow these [installation instructions](#installation) to install it from GitHub
2. Complete the Onboarding process and input your [API key](https://aistudio.google.com/app/apikey)
> [!CAUTION]
> Be sure not to share your API key with anybody else!
3. Add attachments using the buttons marked for images and URLs, and add text-based attachments to the textfield.
4. Click the plane icon to start generating the quiz! Enjoy!
  <details>

<summary>Prompting Instructions:</summary>

- No need to use phrases such as "quiz me on [...]." We've already instructed Gemini to generate you a quiz. Just simply add attachments relating to whatever you'd like to be quizzed on.
- Free users have a 32K input limit on the Gemini 1.5 Pro model, so this means you should not exceed the limit by adding too much content. Switch to `1.5 Flash` to have a significantly larger input limit.
</details>

> [!TIP]
> Try to only generate quizzes on a singular topic (eg. Cats) rather than multiple topics (eg. Cats, Math, Java etc.)

> [!TIP]
> If you'd like to choose how many of each you want or add further customizations, add those instructions to the prompt (the textfield). Ex: In the quiz, put two multiple choice questions about [...], one multi-select, and three free response questions.

## How It Works
As mentioned previously, we prompt Gemini with your input, and it returns a JSON with the quiz info, which we parse and put in a JSON. We then parse the JSON, rendering the quiz UI.


## Disclaimers
> [!WARNING]
> While we, Recap, do not collect any data from our users, there's nothing stopping Google from collecting YOUR data, so be sure to read *their* privacy policies to be aware of what's going on. Read our [`Privacy Policy`](https://github.com/TopGApps/Recap/blob/master/Privacy.md) for more information about this

> [!CAUTION]
> When inputting your personal API key, be aware of the fact that on a free account, your prompts are linked to your identity and are used to train their models.

## Installation
To get started with Recap, follow these steps:

```sh
# Clone the repository
git clone https://github.com/TopGApps/Recap

# Navigate to the project directory
cd recap

# Open the project in Xcode
open Recap.xcodeproj
```

## Usage
To use Recap, follow these steps:

1. Open the project in Xcode.
2. Select your target device or simulator.
3. Click the "Run" button or press `Cmd + R` to build and run the app.


## Contributing
We welcome contributions from the community. Please read our [contributing guidelines](CONTRIBUTING.md) for more information.

## License
This project is licensed under the Apache Version 2 License - see the [`LICENSE`](https://github.com/TopGApps/Recap/blob/master/LICENSE) file for details.

## Authors and Acknowledgments
- **Aaron Ma** - [GitHub](https://github.com/aaronhma)
- **Vaibhav Satishkumar** - [GitHub](https://github.com/Visual-Studio-Coder)

## Contact
For any inquiries, please contact [vsdev@duck.com](mailto:vsdev@duck.com).

---

Why not download our previous app, [QR Share Pro](https://apps.apple.com/us/app/qr-share-pro/id6479589995)? It's 100% free, no ads, no in-app purchases, doesn't sell your data or track you, and is [open-source on GitHub](https://github.com/visual-studio-coder/qr-share-pro).
