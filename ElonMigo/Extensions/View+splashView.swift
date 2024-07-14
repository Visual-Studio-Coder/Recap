//
//  View+splashView.swift
//  ElonMigo
//
//  Created by Aaron Ma on 7/14/24.
//

import SwiftUI

extension View {
    func splashView<SplashContent: View>(@ViewBuilder splashContent: @escaping () -> SplashContent) -> some View {
        self.modifier(SplashView(splashContent: splashContent))
    }
}
