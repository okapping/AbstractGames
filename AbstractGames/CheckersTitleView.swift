//
//  CheckersTitleView.swift
//  AbstractGames
//
//  Created by 岡山直也 on 2025/12/08.
//

import SwiftUI

struct CheckersTitleView: View {
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
                Text("")
            }
        }
        .navigationTitle("Checkers")
        .fullScreenCover(isPresented: $showGameSheet, onDismiss: {
        }, content: {
            CheckersView()
        })
        
    }
}
