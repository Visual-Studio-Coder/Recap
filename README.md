# ElonMigo

## Made with 💖 & 😀 by [Aaron Ma](https://github.com/aaronhma) & [Vaibhav Satishkumar](https://github.com/Visual-Studio-Coder)

[View our DevPost submission ↗](https://devpost.com/software/elonmigo)

![AppIcon](https://github.com/aaronhma/ElonMigo/blob/master/ElonMigo/Assets.xcassets/AppIcon.appiconset/ElonMigo.png)

## What does it do?
- ElonMigo is your *free* amigo who will help quiz you on the __SPECIFIC concepts__ you are learning about
    - Most online resources don't cover exactly what you learn at school
    - How do you know if you have fully understood a concept or not? You for sure don't want to "wait and find out 😣"
- Input images, URLs, and plaintext and we will use Gemini 1.5 Pro/Flash to generate a beautiful quiz
    - This means that you can take photos of a specific page of your textbook.
- *This level* of personalization is an industry first, and the amount of resources you can input into the model is practically limitless. Quizlet probably wont be able to do what we're doing unless they ALSO switch to Gemini 1.5 Pro.
- ElonMigo also helps you understand what you're learning by having an `explain` button at the top right corner of a question.

## How does it work?
- As mentioned previously, we prompt Gemini with your input, and it returns a JSON with the quiz info, which we parse and put in a JSON. We then parse the JSON, rendering the quiz UI.

## Why us?
- We are the first quizzing iOS app to use Gemini's large context window to deliver you accurate quizzes.
- We are closing the financial gap by making this free to use more and more accessible than ever before.
- We care about your privacy

## Disclaimers
- In no way are we associated with Elon Musk or KhanMigo
- When inputting your personal API key, be aware of the fact that on a free account, your prompts are linked to your identity and are used to train their models.
- While we, ElonMigo, do not collect any data from our users, there's nothing stopping Google from collecting YOUR data, so be sure to read *their* privacy policies to be aware of what's going on. 

---

Why not download our previous app, [QR Share Pro](https://apps.apple.com/us/app/qr-share-pro/id6479589995)? It's 100% free, no ads, no in-app purchases, doesn't sell your data or track you, and is [open-source on GitHub](https://github.com/visual-studio-coder/qr-share-pro).
