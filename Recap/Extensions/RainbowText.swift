// Copyright 2024-2025 Vaibhav Satishkumar
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

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
