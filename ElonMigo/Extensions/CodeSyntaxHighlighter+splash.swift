//
//  CodeSyntaxHighlighter+splash.swift
//  ElonMigo
//
//  Created by Aaron Ma on 7/14/24.
//

import Splash
import MarkdownUI

extension CodeSyntaxHighlighter where Self == SplashCodeSyntaxHighlighter {
  static func splash(theme: Splash.Theme) -> Self {
    SplashCodeSyntaxHighlighter(theme: theme)
  }
}
