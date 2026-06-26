//
//  ContentView.swift
//  AbstractGames
//
//  Created by 岡山直也 on 2025/12/17.
//

import SwiftUI
import SwiftData

struct Cell: Hashable {
    let y: Int
    let x: Int
    
    init(y: Int, x: Int){
        self.y = y
        self.x = x
    }
    init(_ cell:(y:Int, x:Int)) {
        self.y = cell.y
        self.x = cell.x
    }
}

@Observable class NamespaceWrapper{
    var namespace: Namespace.ID
    
    init(_ namespace: Namespace.ID) {
        self.namespace = namespace
    }
}

enum ResultState {
    case none, win, draw
}


struct ContentView: View {
    
    var body: some View {
        NavigationSplitView {
            List{
                Section(
//                    header: Text("Abstract Games")
                ) {
                    NavigationLink {
                        XoGameTitleView()
                    } label: {
                        Label("Tic tac toe", systemImage: "grid")
//                            .tint(.red)
                    }
                    NavigationLink{
                        ConnectFourTitleVIew()
                    } label: {
                        Label("Connect Four", systemImage: "square.grid.4x3.fill")
                            .tint(.blue)
                    }
                    //                    NavigationLink{
                    //                        //
                    //                    } label: {
                    //                        Label("５目並べ", systemImage: "circle.grid.3x3")
                    //                            .tint(.secondary)
                    //                    }
                    NavigationLink{
                        ReversiTitleView()
                    } label: {
                        Label("Reversi", systemImage: "circle.grid.2x1.left.filled")
                            .tint(.primary)
                    }
//                    NavigationLink{
//                        CheckersTitleView()
//                    } label: {
//                        Label("Checkers", systemImage: "rectangle.pattern.checkered")
//                            .symbolRenderingMode(.hierarchical)
//                            .tint(.red)
//                    }
                    NavigationLink{
                        HareAndHoundsTitleView()
                    } label: {
                        Label("Hare And Hounds", systemImage: "hare.fill")
                            .tint(.primary)
                    }
                    //                    NavigationLink{
                    //
                    //                    } label: {
                    //                        Label("Nine Men's Morris", systemImage: "dot.squareshape.split.2x2")
                    //                    }
                    //                    NavigationLink{
                    //                        NoccaNoccaTitleView()
                    //                    } label: {
                    //                        Label("NoccaNocca", systemImage: "square.3.layers.3d.top.filled")
                    //                            .symbolRenderingMode(.hierarchical)
                    //                            .tint(.green)
                    //                    }
                    //                    NavigationLink{
                    //                        OstleTitleView()
                    //                    } label: {
                    //                        Label("Ostle", systemImage: "flame")
                    //                            .tint(.red)
                    //                    }
                    NavigationLink{
                        HorseshoeTitleView()
                    } label: {
                        Label("Horseshoe", systemImage: "bookmark")
                            .tint(.blue)
                    }
                    //                    NavigationLink{
                    //                        AnimalShogiTitleView()
                    //                    } label: {
                    //                        Label("Animal Shogi", systemImage: "pawprint.fill")
                    //                            .tint(.orange)
                    //                    }
                    //                    NavigationLink{
                    //                        //
                    //                    } label: {
                    //                        Label("ドット&ボックス", systemImage: "square.and.pencil")
                    //                            .tint(.secondary)
                    //                    }
                    //                    NavigationLink{
                    //                        //
                    //                    } label: {
                    //                        Label("マンカラ", systemImage: "inset.filled.oval")
                    //                            .tint(.secondary)
                    //                    }
                    //                    NavigationLink{
                    //                        //
                    //                    } label: {
                    //                        Label("ゴブレット", systemImage: "grid.circle")
                    //                            .tint(.secondary)
                    //                    }
                    //                    NavigationLink{
                    //                        //
                    //                    } label: {
                    //                        Label("5五将棋", systemImage: "pentagon.lefthalf.filled")
                    //                            .tint(.secondary)
                    //                    }
                    //                    NavigationLink{
                    //                        //
                    //                    } label: {
                    //                        Label("ヘックス", systemImage: "circle.hexagongrid")
                    //                            .tint(.secondary)
                    //                    }
                    //                    NavigationLink{
                    //                        QuoridorTitleView()
                    //                    } label: {
                    //                        Label("コリドール", systemImage: "square.and.line.vertical.and.square")
                    //                            .tint(.secondary)
                    //                    }
                }
            }
            .navigationTitle("Abstract Games")
        } detail: {
            Text("Select a Game")
        }
    }
    
}

#Preview {
    ContentView()
    //        .modelContainer(for: Item.self, inMemory: true)
}
