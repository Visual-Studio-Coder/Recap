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

struct SettingsBoxView: View {
    var icon: String
    var color: Color

    var body: some View {
        Image(systemName: icon)
            .font(.callout) // Adjust font size if needed
            .foregroundStyle(.white)
            .frame(width: 30, height: 30) // Consistent size
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: 7)) // Rounded corners
    }
}

#Preview {
    SettingsBoxView(icon: "gearshape.fill", color: .gray)
}
