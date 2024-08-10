import SwiftUI

struct RainbowTextModifier: ViewModifier {
    @State private var gradient = [Color.red, Color.orange, Color.yellow, Color.green, Color.blue, Color.purple]
    
    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(gradient: Gradient(colors: gradient), startPoint: .leading, endPoint: .trailing)
                    .mask(content)
            )
    }
}

extension View {
    func rainbowText() -> some View {
        self.modifier(RainbowTextModifier())
    }
}
