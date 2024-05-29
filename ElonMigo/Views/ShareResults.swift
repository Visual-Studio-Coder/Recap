//
//  ShareResults.swift
//  ElonMigo
//
//  Created by Vaibhav Satishkumar on 5/28/24.
//

import SwiftUI

struct ShareResults: View {
    let quizTitle: String
    let correctCount: Double
    let totalCount: Double
    var body: some View {
        VStack {
            ZStack {
                RoundedRectangle(cornerRadius: 30)
                    .fill(.white)
                    .frame(width: 200 * 1.618, height: 200)
                RoundedRectangle(cornerRadius: 30)
                    .fill(LinearGradient(colors: [.brown.opacity(0.2), .brown.opacity(0.3), .brown.opacity(0.4), .brown.opacity(0.5), .brown.opacity(0.6), .brown.opacity(0.7), .brown.opacity(0.8), .brown.opacity(0.9), .brown.opacity(1), .brown], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 200 * 1.618, height: 200)
                    .overlay {
                        HStack {
                            VStack {
                                HStack {
                                    Text("\(Int(correctCount / totalCount * 100))%")
                                        .font(.largeTitle)
                                        .bold()
                                    Spacer()
                                }
                                HStack {
                                    Text(quizTitle)
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                }
                            }
                            Divider()
                            VStack {
                                HStack {
                                    VStack {
                                        HStack {
                                            Text("Correct")
                                                .foregroundStyle(.secondary)
                                                .font(.caption)
                                            Spacer()
                                        }
                                        HStack {
                                            Text(String(Int(correctCount)))
                                            //.multilineTextAlignment(.leading)
                                            Spacer()
                                        }
                                    }
                                    Spacer()
                                }
                                Divider()
                                HStack {
                                    Text("Incorrect")
                                        .foregroundStyle(.secondary)
                                        .font(.caption)
                                    Spacer()
                                }
                                HStack {
                                    Text(String(Int(totalCount)))
                                    //.multilineTextAlignment(.leading)
                                    Spacer()
                                }
                            }
                        }
                        .foregroundColor(.white)
                        .padding()
                    }
                    .padding()
                    //.padding([.leading, .trailing, .top])
            }
            
            Label {
                Text("Download ElonMigo Today!")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding([.leading, .trailing, .bottom])
            } icon: {
                Image(uiImage: #imageLiteral(resourceName: "AppIcon"))
                    .resizable()
                    .frame(width: 30, height: 30)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }

        }
        .background(LinearGradient(colors: [.blue.opacity(0.2), .blue.opacity(0.3), .blue.opacity(0.4), .blue.opacity(0.5), .blue.opacity(0.6), .blue.opacity(0.7), .blue.opacity(0.8), .blue.opacity(0.9), .blue.opacity(1), .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
        
    }
}

#Preview {
    ShareResults(quizTitle: "Spanish Quiz", correctCount: 5, totalCount: 10)
}
