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

import Foundation

extension String {
    func isValidURL() -> Bool {
        guard self.count >= 10 else { return false } // http://a.a
        
        if let url = URLComponents(string: self) {
            if url.scheme != nil && !url.scheme!.isEmpty {
                let scheme = (url.scheme ?? "fail")
                return scheme == "http" || scheme == "https"
            }
        }
        
        return false
    }
}
