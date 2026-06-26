//
//  AnimalShogiTitleView.swift
//  AbstractGames
//
//  Created by 岡山直也 on 2025/11/30.
//


import SwiftUI

struct AnimalShogiTitleView: View {
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
//                Text("ルール説明：\n2人のプレイヤーがウサギ側と猟犬側に分かれて勝敗を競うアブストラクトゲームである。")
            }
        }
        .navigationTitle("Animal Shogi")
        .fullScreenCover(isPresented: $showGameSheet, onDismiss: {
        }, content: {
            AnimalShogiView()
        })
        
    }
}
