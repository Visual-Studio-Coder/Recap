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

import Splash
import SwiftUI

struct TextOutputFormat: OutputFormat {
    private let theme: Theme
    
    init(theme: Theme) {
        self.theme = theme
    }
    
    func makeBuilder() -> Builder {
        Builder(theme: self.theme)
    }
    
    struct Builder: OutputBuilder {
        private let theme: Theme
        private var accumulatedText: [Text]
        
        init(theme: Theme) {
            self.theme = theme
            self.accumulatedText = []
        }
        
        mutating func addToken(_ token: String, ofType type: TokenType) {
            let color = self.theme.tokenColors[type] ?? self.theme.plainTextColor
            self.accumulatedText.append(Text(token).foregroundStyle(Color(color)))
        }
        
        mutating func addPlainText(_ text: String) {
            self.accumulatedText.append(
                Text(text).foregroundStyle(Color(self.theme.plainTextColor))
            )
        }
        
        mutating func addWhitespace(_ whitespace: String) {
            self.accumulatedText.append(Text(whitespace))
        }
        
        func build() -> Text {
            self.accumulatedText.reduce(Text(""), +)
        }
    }
}
