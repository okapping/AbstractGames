//
//  XoGameTitleView.swift
//  Test
//
//  Created by 岡山直也 on 2025/11/09.
//


import SwiftUI

struct XoGameTitleView: View {
    @State private var cellSize: Int = 3
    @State private var showGameSheet: Bool = false
    var body: some View {
        List{
//            Section(
//                header: Text("マス目の数を選択（最大6マス）")
//            ){
//                Stepper(value: $cellSize, in: 3...6) {      // 設定できる体重の範囲を指定
//                    Text("\(cellSize)")
//                }
//            }
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
//                Text("ルール説明：\n丸か罰か、勝つのは二人に一つ！")
            }
        }
        .navigationTitle("Tic tac toe")
        .fullScreenCover(isPresented: $showGameSheet, onDismiss: {
        }, content: {
            XoGameView()
        })
    }
}

#Preview {
    XoGameTitleView()
}
