//
//  ConnectFourTitleVIew.swift
//  Test
//
//  Created by 岡山直也 on 2025/11/11.
//

import SwiftUI

struct ConnectFourTitleVIew: View {
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
//                Text("上から円盤を落とす。ア")
            }
        }
        .navigationTitle("Connect Four")
        .fullScreenCover(isPresented: $showGameSheet, onDismiss: {
        }, content: {
            ConnectFourView()
        })

    }
}
