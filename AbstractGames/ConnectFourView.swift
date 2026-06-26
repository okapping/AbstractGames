//
//  ConnectFourView.swift
//  Test
//
//  Created by 岡山直也 on 2025/11/11.
//

import SwiftUI

enum CFDisc{
    case first,second,none
    //コマの色
    static let color = {(disc:Self)->Color in
        switch disc{
        case .first:.yellow
        case .second:.red
        case .none :.clear
        }
    }

    static let opposedMark = {(disc:Self)->Self in
        switch disc {
        case .first:.second
        case .second:.first
        case .none :fatalError()
        }
    }
}

struct ConnectFourCell:View {
    var disc:CFDisc = .none
    var isAligned = false
    let yCount: CGFloat
    
    init(y: Int){
        yCount = CGFloat(y)
    }
    @State private var cellSize: CGSize = CGSize()
    
    var body: some View{
        ZStack(){
            Rectangle()
                .foregroundStyle(.clear)
            // コマ
            if disc != .none{
                Circle()
                    .padding(4)
                    .foregroundStyle(CFDisc.color(disc))
//                    .transition(.move(edge: .top))
                    .transition(.asymmetric(
//                        insertion: .move(edge: .top),
//                        insertion: .offset(x: 0, y: -200),
                        insertion: .offset(x: 0, y: -(cellSize.height * (yCount + 1))),
                        removal: .move(edge: .bottom).combined(with: .opacity))
                    )
                    .animation(.linear.speed(1.0 + ((5 - yCount) * 0.2)))

            }
            if isAligned{
                Circle()
                    .stroke(lineWidth: 10)
                    .fill(.white)
                    .padding(4)
                    .opacity(0.8)
//                    .transition(.opacity)
            }

        }
        .scaledToFit()
        .background() {
            GeometryReader { geometry in
                Path { path in
                    let size = geometry.size
                    DispatchQueue.main.async {
                        if self.cellSize != size {
                            self.cellSize = size
                        }
                    }
                }
            }
        }

    }
}
@Observable class ConnectFourManager{
    var player:CFDisc = .first
    var finishFlg: Bool = false
    var showResult: Bool = false
    var resultState: ResultState = .none
    
    var undo: UndoManager?

    var cells:[[ConnectFourCell]] = []
    init(){
        setUp()
    }
    public func setUp(){
        player = .first
        finishFlg = false
        showResult = false
        resultState = .none
        undo?.removeAllActions()
        
        withAnimation{
            cells = (0..<6).map { y in
                (0..<7).map { x in
                    ConnectFourCell(y: y) // y座標を引数として渡す
                }
            }
        }
    }
    public func removeDisc(_ x:Int,_ disc:CFDisc){
        // 巻き戻し時の石除外処理
        for y in Array(0..<6) {
            if cells[y][x].disc != .none{
                cells[y][x].disc = .none
                
                changePlayer()
                
                undo?.registerUndo(withTarget: self) { me in
                    me.progressGame(x)
                    //                    print("undo?.registerUndo")
                }
                return
            }
        }

    }
    public func dropDisc(_ x:Int,_ disc:CFDisc){
        for y in Array(0..<6).reversed() {
            if cells[y][x].disc == .none{
                cells[y][x].disc = disc
                undo?.registerUndo(withTarget: self) { me in
                    me.removeDisc(x, disc)
//                    print("undo?.registerUndo")
                }

                return
            }
        }
    }
        
    public func checkVictory() -> Bool {
        
        // 横の確認
        for y in 0..<6 {
            for x in 0...(cells[y].count - 4) {
                //要素が四つずつ揃っているか確認する
                let checkCells = Array(cells[y][x..<(x + 4)])
                if checkCells.allSatisfy({ $0.disc == player }) {
                    for i in 0..<4 {
                        withAnimation{
                            cells[y][x + i].isAligned = true
                        }
                    }
                    return true
                }
            }
        }
        // 縦の確認
        for x in 0..<7 {
            for y in 0...(cells.count - 4) {
                let checkCells = (0..<4).map { cells[y + $0][x] }
                if checkCells.allSatisfy({ $0.disc == player }) {
                    for i in 0..<4 {
                        withAnimation{
                            cells[y + i][x].isAligned = true
                        }
                    }
                    return true
                }
            }
        }
        //斜めの確認（左上から右下）
        for y in 0...(cells.count - 4) {
            for x in 0...(cells[y].count - 4) {
                let checkCells = (0..<4).map { cells[y + $0][x + $0] }
                if checkCells.allSatisfy({ $0.disc == player }) {
                    for i in 0..<4 {
                        withAnimation{
                            cells[y + i][x + i].isAligned = true
                        }
                    }
                    return true
                }
            }
        }
        //斜めの確認（右上から左下）
        for y in 0...(cells.count - 4) {
            for x in 0...(cells[y].count - 4) {
                let checkCells = (0..<4).map { cells[y + $0][3 + x - $0] }
                if checkCells.allSatisfy({ $0.disc == player }) {
                    for i in 0..<4 {
                        withAnimation{
                            cells[y + i][3 + x - i].isAligned = true
                        }
                    }
                    return true
                }
            }
        }

        return false
    }
    
    public func checkDraw() -> Bool {
        for y in 0..<6 {
            for x in 0..<7 {
                if cells[y][x].disc == .none {
                    return false
                }
            }
        }
        return true
    }
    
    public func progressGame(_ x:Int){
        print("TAP in connect four \(Date())")
        //ディスクを置くことができない
        if((0..<6).allSatisfy{ cells[$0][x].disc != .none }){return}
        // ディスクを置く
        dropDisc(x, player)
        // 決着がついているか
        if checkVictory(){
            // 決着
            finishFlg = true
//            winFlg = true
            resultState = .win
            showResult = true
            return
        }
        // 置く場所が存在するか確認
        if checkDraw(){
            finishFlg = true
//            drawFlg = true
            resultState = .draw
            showResult = true
            return
        }
        changePlayer()
    }
    
    private func changePlayer(){
        player = .opposedMark(player)
    }

}

struct ConnectFourView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.undoManager) private var undo
    
    @State var connectFourManager = ConnectFourManager()
    
    var body: some View {
            ZStack{
                VStack(spacing: 0.0){
                    ForEach(0..<6, id:\.self){y in
                        HStack(spacing: 0.0){
                            ForEach(0..<7, id:\.self){x in
                                connectFourManager.cells[y][x]
                            }
                        }
                    }
                }
                .padding(8)
                
                // 真ん中が空いた枠
                VStack(spacing: 0.0){
                    ForEach(0..<6, id:\.self){y in
                        HStack(spacing: 0.0){
                            ForEach(0..<7, id:\.self){x in
                                Circle()
                                    .blendMode(.destinationOut)
                                    .padding(4)
                                    .scaledToFit()
                                    .onTapGesture {
                                        if !connectFourManager.finishFlg{
                                            withAnimation{
                                                connectFourManager.progressGame(x)
                                            }
                                        }
                                    }
                            }
                        }
                    }
                }
                .padding(8)
                .background(.blue)
                .border(Color.blue, width: 8)
                .compositingGroup()
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
//            .background{
//                // グラデーション背景
//                TimelineView(.periodic(from: .now, by: 5)) { _ in
//                    let location = 0.5 + CGFloat.random(in: -0.4...0.4)
//                    LinearGradient(
//                        stops: [
//                            .init(color: .green.opacity(0.75), location: 0.0),
//                            .init(color: .yellow.opacity(0.5), location: location),
//                            .init(color: .blue.opacity(0.75), location: 1.0)
//                        ],
//                        startPoint: .topLeading,
//                        endPoint: .bottomTrailing
//                    )
//                    .animation(.linear(duration: 5), value: location)
//                }
//                .ignoresSafeArea()
//            }
            .overlay{
                VStack{
                    HStack(alignment: .top){
                        // 左上の表示
                        VStack{
                            Text("Turn")
                                .font(.headline)
                            Circle()
                                .fill(CFDisc.color(connectFourManager.player))
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                        }
                        .padding()
                        .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 16.0))
                        .padding()
                        Spacer()
                        // 右上の表示
                        Menu{
                            Button {
                                undo?.removeAllActions()
                                connectFourManager.setUp()
                            } label: {
                                Label("Restart", systemImage: "arrow.trianglehead.counterclockwise")
                            }
                            // 閉じるボタン
                            Button {
                                undo?.removeAllActions()
                                presentationMode.wrappedValue.dismiss()
                            } label: {
                                Label("End game", systemImage: "xmark.circle")
                            }
                        } label: {
                            Image(systemName: "menucard")
                                .padding()
                        }
                        .buttonStyle(.plain)
                        .glassEffect(.regular.interactive(), in: .circle)
                        .padding()
                    }
                    Spacer()
                    HStack(alignment: .bottom){
                        // 左下の表示
                        Spacer()
                        // 右下の表示
                        GlassEffectContainer(spacing: 40.0) {
                            HStack() {
                                Button{
                                    withAnimation{
                                        undo?.undo()
                                    }
                                } label: {
                                    Image(systemName: "arrow.uturn.backward")
                                        .padding()
                                }
                                .disabled(undo?.canUndo == false)
                                .glassEffect(.regular.interactive())
                                Button{
                                    withAnimation{
                                        undo?.redo()
                                    }
                                } label: {
                                    Image(systemName: "arrow.uturn.forward")
                                        .padding()
                                }
                                .disabled(undo?.canRedo == false)
                                .glassEffect(.regular.interactive())
                            }
                            .disabled(connectFourManager.finishFlg)
                        }
                        .padding()
                    }
                    
                }
            }
        .sheet(isPresented: $connectFourManager.showResult) {
            ZStack{
                Button{
                    connectFourManager.showResult = false
                } label: {
                    Image(systemName: "xmark")
                        .padding()
                        .foregroundStyle(.primary)
                }
                .buttonStyle(.plain)
                .glassEffect(.regular)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .padding()

                VStack{
                    switch connectFourManager.resultState {
                    case .win:
                        HStack{
                            Text("Win")
                            Image(systemName: "circle.fill")
                                .foregroundStyle(CFDisc.color(connectFourManager.player))
                        }
                        .font(.largeTitle)
                    case .draw:
                        HStack{
                            Text("Draw")
                        }
                        .font(.largeTitle)
                    case .none:
                        HStack{
                            Text("Error")
                        }
                        .font(.largeTitle)
                    }
                    
                    Button {
                        undo?.removeAllActions()
                        connectFourManager.setUp()
                        connectFourManager.showResult = false
                    } label: {
                        Label("Restart", systemImage: "arrow.trianglehead.counterclockwise")
                    }
                    // 終了ボタン
                    Button {
                        undo?.removeAllActions()
                        connectFourManager.showResult = false
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Label("End game", systemImage: "xmark.circle")
                    }
                }
                .buttonStyle(.glassProminent)
            }
            .presentationDetents([.large, .medium, .height(200)]) // ⬅︎
        }
        .onAppear { connectFourManager.undo = undo }
    }
}

#Preview {
    ConnectFourView()
}
