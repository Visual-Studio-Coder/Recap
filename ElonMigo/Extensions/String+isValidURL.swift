//
//  String+isValidURL.swift
//  ElonMigo
//
//  Created by Aaron Ma on 7/14/24.
//

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
