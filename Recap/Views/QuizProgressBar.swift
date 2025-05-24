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

struct QuizProgressBar: View {
    var current: Float
    var total: Float
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .trailing) {
                RoundedRectangle(cornerRadius: 45)
                    .fill(.gray)
                
                LinearGradient(colors: [.blue, .green], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .mask {
                        HStack {
                            RoundedRectangle(cornerRadius: 45)
                                .frame(width: CGFloat(current / total) * geo.size.width)
                            
                            if current != total {
                                Spacer()
                            }
                        }
                    }
                    .animation(.easeInOut)
            }
        }
        .frame(height: 10)
        .padding(.horizontal)
    }
}

#Preview {
    QuizProgressBar(current: 4, total: 4)
}
