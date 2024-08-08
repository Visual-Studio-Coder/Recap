//import UIKit
//import UIOnboarding
//
//struct UIOnboardingHelper {
//    static func setUpIcon() -> UIImage {
//        return Bundle.main.appIcon ?? .init(named: "onboarding-icon")!
//    }
//    
//    static func setUpFirstTitleLine() -> NSMutableAttributedString {
//        .init(string: "Welcome to", attributes: [.foregroundColor: UIColor.label])
//    }
//    
//    static func setUpSecondTitleLine() -> NSMutableAttributedString {
//        .init(string: Bundle.main.displayName ?? "Recap", attributes: [
//            .foregroundColor: UIColor.systemBrown
//        ])
//    }
//    
//    static func setUpFeatures() -> Array<UIOnboardingFeature> {
//        return .init([
//            .init(icon: UIImage(systemName: "brain.head.profile")!,
//                  title: "Create Personalized Quizzes",
//                  description: "Generate a quiz based solely on your notes from class."),
//            .init(icon: UIImage(systemName: "dollarsign.arrow.circlepath")!,
//                  title: "Education Free of Charge",
//                  description: "Powered by Google Gemini, get access to free AI-powered quizzes without any ads."),
//            .init(icon: UIImage(systemName: "doc")!,
//                  title: "Attach Anything",
//                  description: "Add images, links to webpages/articles/PDFs/YouTube videos, and text, and we'll feed it to the AI for you!")
//        ])
//    }
//    
//    static func setUpNotice() -> UIOnboardingTextViewConfiguration {
//        return .init(icon: UIImage(systemName: "hammer.fill"),
//                     text: "Designed and developed by \nVaibhav Satishkumar and Aaron Ma.",
//                     tint: .init(named: "camou") ?? .init(red: 0.654, green: 0.618, blue: 0.494, alpha: 1.0))
//    }
//    
//    static func setUpButton() -> UIOnboardingButtonConfiguration {
//        return .init(title: "Continue",
//                     backgroundColor: .init(named: "camou") ?? .init(red: 0.654, green: 0.618, blue: 0.494, alpha: 1-0))
//    }
//}
//
//extension UIOnboardingViewConfiguration {
//    static func setUp() -> UIOnboardingViewConfiguration {
//        return .init(appIcon: UIOnboardingHelper.setUpIcon(),
//                     firstTitleLine: UIOnboardingHelper.setUpFirstTitleLine(),
//                     secondTitleLine: UIOnboardingHelper.setUpSecondTitleLine(),
//                     features: UIOnboardingHelper.setUpFeatures(),
//                     textViewConfiguration: UIOnboardingHelper.setUpNotice(),
//                     buttonConfiguration: UIOnboardingHelper.setUpButton())
//    }
//}
//
//import SwiftUI
//import UIOnboarding
//
//struct OnboardingView: UIViewControllerRepresentable {
//    typealias UIViewControllerType = UIOnboardingViewController
//    
//    class Coordinator: NSObject, UIOnboardingViewControllerDelegate {
//        func didFinishOnboarding(onboardingViewController: UIOnboardingViewController) {
//            onboardingViewController.dismiss(animated: true, completion: nil)
//        }
//    }
//    
//    func makeUIViewController(context: Context) -> UIOnboardingViewController {
//        let onboardingController: UIOnboardingViewController = .init(withConfiguration: .setUp())
//        onboardingController.delegate = context.coordinator
//        return onboardingController
//    }
//    
//    func updateUIViewController(_ uiViewController: UIOnboardingViewController, context: Context) {}
//    
//    func makeCoordinator() -> Coordinator {
//        return .init()
//    }
//}
