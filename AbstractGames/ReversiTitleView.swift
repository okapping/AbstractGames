//
//  ReversiTitleView.swift
//  AbstractGames
//
//  Created by 岡山直也 on 2026/01/14.
//


//
//  ReversiTitleView.swift
//  AbstractGames
//
//  Created by 岡山直也 on 2025/11/20.
//

import SwiftUI

struct ReversiTitleView: View {
    @State private var showGameSheet: Bool = false
    var body: some View {
        List{
            Section(){
                Button{
                    showGameSheet = true
                } label: {
                    Label("Game Start", systemImage:"flag.filled.and.flag.crossed")
                }
            }
            Section(
                header: Text("Rule")
            ){
//                Text("白確とかはっきりつけよう。")
            }
        }
        .navigationTitle("Reversi")
        .fullScreenCover(isPresented: $showGameSheet, onDismiss: {
        }, content: {
            ReversiView()
        })
        
    }
}
