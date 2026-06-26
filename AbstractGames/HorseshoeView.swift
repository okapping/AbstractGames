//
//  HorseshoeView.swift
//  AbstractGames
//
//  Created by 岡山直也 on 2025/11/29.
//



import SwiftUI

enum HSPieceStatus{
    case first,second
    //マークの集合(Set)。別に配列でもいい。
    static let statuses:Set<Self> = [.first, .second]
    //コマの色
    //    static let color = {(piece:Self)->Color in
    //        switch piece{
    //        case .first:.gray
    //        case .second:.white
    //        case .hole :.black
    //        }
    //    }
    var color: Color {
        switch self {
        case .first:
            return .red
        case .second:
            return .blue
        }
    }
    
    var anotherPiece: Self {
        switch self {
        case .first: return .second
        case .second:return .first
        }
    }
}

struct HSPiece: Hashable, Identifiable {
    var id = UUID()
    var status: HSPieceStatus
    var name: String
}

struct HorseshoeCell:View {
    var piece:HSPiece? = nil
    var showCell: Bool = true
    @Environment(NamespaceWrapper.self) var namespaceWrapper
        
    var body: some View{
        ZStack{
            Circle()
//                .fill(.black)
                .scaleEffect(0.5)
        }
        .overlay{
            if let p = piece{
                Circle()
                    .fill(p.status.color)
                    .scaleEffect(0.4)
//                    .transition(.move(edge: .top).combined(with: .opacity))
                    .matchedGeometryEffect(id: p.name, in: namespaceWrapper.namespace)
            }
        }
        .animation(.easeInOut, value: piece)
        .opacity(showCell ? 1 : 0)
        .scaledToFit()
        
        
    }
}

@Observable class HorseshoeManager{
    var undo: UndoManager?
    var player:HSPieceStatus = .first
    
    var finishFlg: Bool = false
    var showResult: Bool = false
    var resultState: ResultState = .none

    var turnCount: Int = 1
    
    var winPlayer: HSPieceStatus? = nil
    
    // 各マスが移動できる場所を設定
    let movableCells: [Cell: [(y: Int, x: Int)]] = [
        Cell(y: 0, x: 0): [(0, 2), (1, 1), (2, 0)],
        Cell(y: 0, x: 2): [(0, 0), (1, 1), (2, 2)],
        Cell(y: 1, x: 1): [(0, 0), (0, 2), (2, 0), (2, 2)],
        Cell(y: 2, x: 0): [(0, 0), (1, 1)],
        Cell(y: 2, x: 2): [(0, 2), (1, 1)],
    ]
    
    var cells:[[HorseshoeCell]] = []
    init(){
        setUp()
    }
    
    public func setUp(){
        player = .first

        finishFlg = false
        showResult = false
        resultState = .none
        winPlayer = nil
        turnCount = 1
        
        withAnimation{
            //            cells = [[HorseshoeCell]](repeating: [HorseshoeCell](repeating: HorseshoeCell(), count: 5), count: 3)
            cells = (0..<3).map { y in
                (0..<3).map { x in
                    HorseshoeCell()
                }
            }
            // 非表示セルの設定
            cells[0][1].showCell = false
            cells[1][0].showCell = false
            cells[1][2].showCell = false
            cells[2][1].showCell = false
            
            // 初期コマの配置
            cells[0][0].piece = HSPiece(status: .second, name: "second1")
            cells[0][2].piece = HSPiece(status: .second, name: "second2")
            cells[2][0].piece = HSPiece(status: .first, name: "first1")
            cells[2][2].piece = HSPiece(status: .first, name: "first2")
        }
    }
    public func getEmptyCell() -> (y:Int,x:Int)?{
        for y in 0..<3{
            for x in 0..<3{
                if cells[y][x].showCell && cells[y][x].piece == nil {
                    return (y, x)
                }
            }
        }
        return nil
    }
    public func getplayerCells(_ player: HSPieceStatus) -> [(y:Int,x:Int)]{
        let tmpCells: [(y: Int, x: Int)] = (0..<3).flatMap { y in
            (0..<3).compactMap { x in
                cells[y][x].piece?.status == player ? (y, x) : nil
            }
        }
        
        return tmpCells
    }
    private func checkWin() -> Bool{
        
        // 次のプレイヤーの移動可能なコマがあるか確認する
        
        let emptyCell: (y:Int,x:Int)? = getEmptyCell()
        let nextPlayerCells: [(y:Int,x:Int)] = getplayerCells(player.anotherPiece)
        
        if let emptyCell = emptyCell{
            for cell in nextPlayerCells{
                if let moveCells = movableCells[Cell(y: cell.y, x: cell.x)] {
                    if moveCells.contains(where: { $0 == emptyCell }){
                        return false
                    }
                }
            }
        }
        
        finishFlg = true
        showResult = true
        resultState = .win
        winPlayer = player
        return true
    }

    private func changePlayer(){
        player = player.anotherPiece
    }

    public func progressGame(_ y:Int,_ x:Int){
        print("TAP in Horseshoe \(Date())")
        
        let tapCell: (y:Int,x:Int) = (y, x)
        let emptyCell: (y:Int,x:Int)? = getEmptyCell()
//        print("emptyCell = \(emptyCell)")
//
        if cells[tapCell.y][tapCell.x].piece?.status == player.anotherPiece {return}
        
        if let emptyCell = emptyCell{
            let wrappedtapCell: Cell = Cell(y: tapCell.y, x: tapCell.x)
            if let moveCells = movableCells[wrappedtapCell]{
                if moveCells.contains(where: {$0 == emptyCell }) {
                    // 移動可能セル内に空白のセルがあれば移動
                    // コマの移動
                    undo?.registerUndo(withTarget: self) { me in
                        me.cells[tapCell.y][tapCell.x].piece = me.cells[emptyCell.y][emptyCell.x].piece
                        me.cells[emptyCell.y][emptyCell.x].piece = nil
                        me.changePlayer()
                        me.turnCount -= 1
                        me.undo?.registerUndo(withTarget: self) { me in
                            me.progressGame(tapCell.y, tapCell.x)
                        }
                    }
                    cells[emptyCell.y][emptyCell.x].piece = cells[tapCell.y][tapCell.x].piece
                    cells[tapCell.y][tapCell.x].piece = nil
                    // 勝敗判定
                    if checkWin() {
                        //
                    } else {
                        // プレイヤー交代
                        changePlayer()
                        // ターン経過
                        turnCount += 1
                    }
                }
            }
        } else {
            
        }
    }
}

struct HorseshoeView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.undoManager) private var undo
    @State var HSManager = HorseshoeManager()
    @Namespace private var namespace
    
    @State  var cellPoints: [[CGPoint]] = [[CGPoint]](repeating: [CGPoint](repeating: CGPoint(), count: 3), count: 3)
    

    var body: some View {
        ZStack{
            // 背景の線
            ZStack{
                Path { path in
                    path.addLines([
                        cellPoints[2][0],
                        cellPoints[0][0],
                        cellPoints[0][2],
                        cellPoints[2][2],
                    ])
//                    path.closeSubpath()
                    path.addLines([
                        cellPoints[0][0],
                        cellPoints[2][2],
                    ])
                    path.addLines([
                        cellPoints[0][2],
                        cellPoints[2][0],
                    ])
                }
                .stroke(lineWidth: 6)
                .fill(Color.primary)
            }
            .ignoresSafeArea()
            
            VStack(spacing: 0.0){
                ForEach(0..<3, id:\.self){y in
                    HStack(spacing: 0.0){
                        ForEach(0..<3, id:\.self){x in
                            HSManager.cells[y][x]
                                .environment(NamespaceWrapper(namespace))
                                .onTapGesture {
                                    if !HSManager.finishFlg{
                                        withAnimation{
                                            HSManager.progressGame(y, x)
                                        }
                                    }
                                }
                                .background() {
                                    GeometryReader { geometry in
                                        Path { path in
                                            let pointX = geometry.frame(in: .global).midX
                                            let pointY = geometry.frame(in: .global).midY
                                            let point = CGPoint(x: pointX, y: pointY)
                                            DispatchQueue.main.async {
                                                if self.cellPoints[y][x] != point {
                                                    self.cellPoints[y][x] = point
                                                }
                                            }
                                        }
                                    }
                                }
                                .overlay{
                                    // index座標表示
                                    //                                            Text("y:\(y)\nx:\(x)").foregroundStyle(.black).fontWeight(.black)
                                    // 位置座標表示
                                    //                                            Text("\(cellPoints[y][x])").foregroundStyle(.pink).fontWeight(.black)
                                }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .overlay{
            VStack{
                HStack(alignment: .top){
                    // 左上の表示
                    VStack{
                        HStack(alignment: .lastTextBaseline, spacing: 4){
                            Text("Turn")
                                .font(.system(.headline, design: .rounded))
                            Text("\(HSManager.turnCount)")
                                .font(.system(.title2, design: .rounded))
                                .fontWeight(.bold)
                                .contentTransition(.numericText(value: Double(HSManager.turnCount)))
                            
                        }
                        Circle()
                            .frame(width: 30, height: 30)
                            .foregroundStyle(HSManager.player.color)
                    }
                    .padding()
                    .glassEffect(.regular.tint(.secondary.opacity(0.5)).interactive(), in: .rect(cornerRadius: 16.0))
                    .padding()
                    Spacer()
                    // 右上の表示
                    Menu{
                        Button {
                            undo?.removeAllActions()
                            HSManager.setUp()
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
                        .disabled(HSManager.finishFlg)
                    }
                    .padding()
                }
                
            }
        }

        .sheet(isPresented: $HSManager.showResult) {
            ZStack{
                Button{
                    HSManager.showResult = false
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
                    HStack(alignment: .lastTextBaseline){
                        Text("Win")
                        if let p = HSManager.winPlayer {
                            Image(systemName: "circle.fill")
                                .foregroundStyle(p.color)
                        }
                    }
                    .font(.largeTitle)
                    
                    Button {
                        undo?.removeAllActions()
                        HSManager.setUp()
                        HSManager.showResult = false
                    } label: {
                        Label("Restart", systemImage: "arrow.trianglehead.counterclockwise")
                    }
                    // 終了ボタン
                    Button {
                        undo?.removeAllActions()
                        HSManager.showResult = false
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Label("End game", systemImage: "xmark.circle")
                    }
                }
                .buttonStyle(.glassProminent)
            }
            .presentationDetents([.large, .medium, .height(200)])
        }

        .onAppear { HSManager.undo = undo }
    }
}

#Preview {
    HorseshoeView()
}
