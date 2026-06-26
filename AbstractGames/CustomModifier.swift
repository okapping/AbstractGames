//
//  CustomModifier.swift
//  AbstractGames
//
//  Created by 岡山直也 on 2025/12/07.
//

import SwiftUI

extension View {
    func modifier(@ViewBuilder _ closure: (Self) -> some View) -> some View {
        closure(self)
    }
}

struct GameMenuButton: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.title2)
            .buttonStyle(.bordered)
            .glassEffect()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
    }
}
extension View {
    func gameMenuButtonStyle() -> some View {
        self.modifier(GameMenuButton())
    }
}
struct GameUndoRedoButton: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.title2)
            .buttonStyle(.bordered)
            .glassEffect()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            
        // 以下旧タイプ
//            .padding()
//            .background(Color.secondary.opacity(0.25))
//            .clipShape(RoundedRectangle(cornerRadius: 10))
//            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)

    }
}
extension View {
    func gameUndoRedoButtonStyle() -> some View {
        self.modifier(GameUndoRedoButton())
    }
}
