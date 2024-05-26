//
//  QuizProgressBar.swift
//  ElonMigo
//
//  Created by Aaron Ma on 5/25/24.
//

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
