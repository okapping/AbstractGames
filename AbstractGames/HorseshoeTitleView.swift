//
//  HorseshoeTitleView.swift
//  AbstractGames
//
//  Created by 岡山直也 on 2025/11/29.
//


import SwiftUI

struct HorseshoeTitleView: View {
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
//                Text("ルール説明：\n各プレーヤー自分の色を選択し、交互に着手します。\n駒は、ボード上の線に沿って、空いている目まで移動できます。\nパスはできません。")
            }
        }
        .navigationTitle("Horseshoe")
        .fullScreenCover(isPresented: $showGameSheet, onDismiss: {
        }, content: {
            HorseshoeView()
        })
        
    }
}
