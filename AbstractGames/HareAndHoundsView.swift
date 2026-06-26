//
//  HAHPieceStatus.swift
//  AbstractGames
//
//  Created by 岡山直也 on 2025/12/21.
//


//
//  HareAndHoundsView.swift
//  AbstractGames
//
//  Created by 岡山直也 on 2025/11/27.
//

import SwiftUI

enum HAHPieceStatus{
    case hounds,hare

    static let pieces:Set<Self> = [.hounds, .hare]
    var symbolName: String{
        switch self {
        case .hounds:
            return "dog"
        case .hare:
            return "hare"
        }
    }
    var color: Color {
        switch self {
        case .hounds:
            return .black
        case .hare:
            return .white
        }
    }
    var anotherPiece: Self {
        switch self {
        case .hounds: return .hare
        case .hare:return .hounds
        }
    }
}

struct HAHPiece: Hashable, Identifiable {
    var id = UUID()
    var status: HAHPieceStatus
    var isActive: Bool = false
    var name: String
}

struct HareAndHoundsCell:View {
    var piece:HAHPiece? = nil
    var showCell: Bool = true
    @Environment(NamespaceWrapper.self) var namespaceWrapper
    
    var canMove: Bool = false
    var body: some View{
        ZStack{
            Circle()
                .fill(piece?.isActive == true ? .yellow : .green)
                .scaleEffect(0.8)
            Circle()
                .stroke(lineWidth: 4)
                .scaleEffect(0.8)
        }
        .overlay{
            if let p = piece{
                Image(systemName: p.status.symbolName)
                    .resizable()
                    .scaledToFit()
                    .symbolVariant(.fill)
                    .foregroundStyle(p.status.color)
                    .scaleEffect(0.55)
                    .matchedGeometryEffect(id: p.name, in: namespaceWrapper.namespace)
                    .transition(.scale(scale: 1))
                    .scaleEffect(x: p.status == .hare ? -1 : 1, y: 1)
            }
        }
        .overlay{
            if canMove {
                Circle()
                    .fill(.yellow.opacity(0.75))
                    .scaleEffect(0.4)
                    .transition(.opacity)
            }
            
        }
        .opacity(showCell ? 1 : 0)
        .scaledToFit()


    }
}

@Observable class HareAndHoundsManager{
    var undo: UndoManager?
    
    var player:HAHPieceStatus = .hounds
    var finishFlg: Bool = false
    var showResult: Bool = false

    var turnCount: Int = 1
    
    var winPlayer: HAHPieceStatus? = nil
    
    // 各マスが移動できる場所を設定
    let movableCells: [Cell: [(y: Int, x: Int)]] = [
        Cell(y: 0, x: 1): [(0, 2), (1, 2), (1, 1), (1, 0)],
        Cell(y: 0, x: 2): [(0, 1), (0, 3), (1, 2)],
        Cell(y: 0, x: 3): [(0, 2), (1, 2), (1, 3), (1, 4)],
        Cell(y: 1, x: 0): [(0, 1), (1, 1), (2, 1)],
        Cell(y: 1, x: 1): [(0, 1), (1, 0), (1, 2), (2, 1)],
        Cell(y: 1, x: 2): [(0, 1), (0, 2), (0, 3), (1, 1), (1, 3), (2, 1), (2, 2), (2, 3)],
        Cell(y: 1, x: 3): [(0, 3), (1, 2), (1, 4), (2, 3)],
        Cell(y: 1, x: 4): [(0, 3), (1, 3), (2, 3)],
        Cell(y: 2, x: 1): [(1, 0), (1, 1), (1, 2), (2, 2)],
        Cell(y: 2, x: 2): [(1, 2), (2, 1), (2, 3)],
        Cell(y: 2, x: 3): [(1, 2), (1, 3), (1, 4), (2, 2)],
    ]

    var cells:[[HareAndHoundsCell]] = []
    init(){
        setUp()
    }
    
    public func setUp(){
        player = .hounds
        finishFlg = false
//        drawFlg = false
        winPlayer = nil
        turnCount = 1
        
        undo?.removeAllActions()
        withAnimation{
//            cells = [[HareAndHoundsCell]](repeating: [HareAndHoundsCell](repeating: HareAndHoundsCell(), count: 5), count: 3)
            cells = (0..<3).map { y in
                (0..<5).map { x in
                    HareAndHoundsCell() // y座標を引数として渡す
                }
            }
            // 非表示セルの設定
            cells[0][0].showCell = false
            cells[0][4].showCell = false
            cells[2][0].showCell = false
            cells[2][4].showCell = false
            
            // 初期コマの配置
            cells[0][1].piece = HAHPiece(status: .hounds, name: "hound1")
            cells[1][0].piece = HAHPiece(status: .hounds, name: "hound2")
            cells[2][1].piece = HAHPiece(status: .hounds, name: "hound3")
            cells[1][4].piece = HAHPiece(status: .hare, name: "hare1")
        }
    }
    public func getActiveCell() -> (y:Int,x:Int)?{
        for y in 0..<3{
            for x in 0..<5{
                if cells[y][x].piece?.isActive == true {
                    return (y, x)
                }
            }
        }
        return nil
    }
    public func getAnimalCells(_ animal: HAHPieceStatus) -> [(y:Int,x:Int)]{
        let tmpCells: [(y: Int, x: Int)] = (0..<3).flatMap { y in
            (0..<5).compactMap { x in
                cells[y][x].piece?.status == animal ? (y, x) : nil
            }
        }

        return tmpCells
    }
    public func setActiveStatus(_ y:Int,_ x:Int){
        cells[y][x].piece?.isActive = true
    }
    public func resetActiveStatus(){
        for y in 0..<3{
            for x in 0..<5{
                cells[y][x].piece?.isActive = false
            }
        }
    }
    private func setMoveCells(_ tapCell: (y:Int,x:Int)){
        
        let cell = Cell(tapCell)
//        print("move cells \(cell)")
//        movableCells[cell]
//        print("move cells \(movableCells[cell])")
        if let moveCells = movableCells[cell] {
            for cell in moveCells {
                print("can move cell = \(cell)")
                // 既にコマ配置済みの場所には置けない
                if cells[cell.y][cell.x].piece != nil {continue}
                // 犬の場合、後ろには置けない
                if cells[tapCell.y][tapCell.x].piece?.status == .hounds {
                    if cell.x < tapCell.x {continue}
                }
                cells[cell.y][cell.x].canMove = true
            }
        }
//        for cell in movableCells[Cell(y: tapCell.y, x: tapCell.x)]{
//            print("moce cells \(cell)")
//        }
    }
    private func resetMoveCells(){
        for y in 0..<3{
            for x in 0..<5{
                cells[y][x].canMove = false
            }
        }
    }
    private func changePlayer(){
        player = player.anotherPiece
    }
    private func movePiece(_ tapCell: (y:Int,x:Int), _ activeCell: (y:Int,x:Int)){
        undo?.registerUndo(withTarget: self) { me in
            me.removePiece(tapCell, activeCell)
        }
        cells[tapCell.y][tapCell.x].piece = cells[activeCell.y][activeCell.x].piece
        cells[activeCell.y][activeCell.x].piece = nil
    }
    private func removePiece(_ tapCell: (y:Int,x:Int), _ activeCell: (y:Int,x:Int)){
            self.resetMoveCells()
            self.resetActiveStatus()
            self.cells[activeCell.y][activeCell.x].piece = self.cells[tapCell.y][tapCell.x].piece
            self.cells[tapCell.y][tapCell.x].piece = nil
            self.changePlayer()
            self.turnCount -= 1
            self.undo?.registerUndo(withTarget: self) { me in
                me.resetMoveCells()
                me.resetActiveStatus()
                me.movePiece(tapCell, activeCell)
                me.changePlayer()
                me.turnCount += 1
            }
    }
    private func checkWin() -> Bool{
        // 勝利条件（wikiより）
        // ①ウサギが全ての猟犬より後ろ（進行方向と逆）の点に移動した場合、ウサギ側の勝利となる。
        // ②ウサギが移動できる全ての頂点を猟犬によって塞がれ、ウサギが移動できなくなった場合、猟犬側の勝利となる。
        // ③千日手（一般的なゲームにおいては20手で勝敗が決しなかった状態）になった場合、ウサギ側の勝利となる。

        // ①ウサギが全ての猟犬より後ろ（進行方向と逆）の点に移動した場合、ウサギ側の勝利となる。
        let houndsCells = getAnimalCells(.hounds)
//        print("hound Cells = \(houndsCells)")
        let hareCells = getAnimalCells(.hare)
//        print("hare Cells = \(hareCells)")
        if houndsCells.allSatisfy({ $0.x > hareCells[0].x }) {
            finishFlg = true
            showResult = true
            winPlayer = .hare
            return true
        }
        // ②ウサギが移動できる全ての頂点を猟犬によって塞がれ、ウサギが移動できなくなった場合、猟犬側の勝利となる。
        let wrappedHareCell: Cell = Cell(hareCells[0])
        if let moveCells = movableCells[wrappedHareCell] {
            if moveCells.allSatisfy({ cells[$0.y][$0.x].piece != nil }) {
                finishFlg = true
                showResult = true
                winPlayer = .hounds
                return true
            }
        }
        // ③千日手（一般的なゲームにおいては20手で勝敗が決しなかった状態）になった場合、ウサギ側の勝利となる。
        if turnCount == 20 {
            finishFlg = true
            showResult = true
            winPlayer = .hare
            return true
        }
        return false
    }
    public func progressGame(_ y:Int,_ x:Int){
        print("TAP in progressGame \(Date())")

        let tapCell: (y:Int,x:Int) = (y, x)
        let activeCell: (y:Int,x:Int)? = getActiveCell()

        // アクティブかどうか
        if let activeCell = activeCell {
            if tapCell == activeCell {
                // アクティブ状態を戻す
                resetActiveStatus()
                resetMoveCells()
            } else {
                if cells[tapCell.y][tapCell.x].canMove == false {return}
                
                // コマの移動
                movePiece(tapCell, activeCell)
                
                // コマのステータス変更
                resetActiveStatus()
                resetMoveCells()
                
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
            
        } else {
//            // アクティブでない場合
            if let _ = cells[y][x].piece {
                if cells[y][x].piece?.status == player.anotherPiece {return}
                //                changeCellsStatus(true, y, x)
                setActiveStatus(y, x)
                setMoveCells(tapCell)
                
            }
//            
        }
    }
}


struct HareAndHoundsView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.undoManager) private var undo
    @Environment(\.colorScheme)var colorScheme
    
    @State var HAHManager = HareAndHoundsManager()
    @Namespace private var namespace
    
    @State  var cellPoints: [[CGPoint]] = [[CGPoint]](repeating: [CGPoint](repeating: CGPoint(), count: 5), count: 3)
    
    init(){
//        cellPoints = [[CGPoint]](repeating: [CGPoint](repeating: CGPoint(), count: 5), count: 3)
    }
    var body: some View {
        ZStack{
            // 背景の線
            ZStack{
                Path { path in
                    path.addLines([
                        cellPoints[1][0],
                        cellPoints[0][1],
                        cellPoints[0][3],
                        cellPoints[1][4],
                        cellPoints[2][3],
                        cellPoints[2][1],
                    ])
                    path.closeSubpath()
                    path.addLines([
                        cellPoints[1][0],
                        cellPoints[1][4],
                    ])
                    path.addLines([
                        cellPoints[0][1],
                        cellPoints[2][1],
                    ])
                    path.addLines([
                        cellPoints[0][2],
                        cellPoints[2][2],
                    ])
                    path.addLines([
                        cellPoints[0][3],
                        cellPoints[2][3],
                    ])
                    path.addLines([
                        cellPoints[0][1],
                        cellPoints[2][3],
                    ])
                    path.addLines([
                        cellPoints[0][3],
                        cellPoints[2][1],
                    ])
                }
                .stroke(lineWidth: 4)
                .fill(Color.primary)
            }
            .ignoresSafeArea()

            VStack(spacing: 0.0){
                ForEach(0..<3, id:\.self){y in
                    HStack(spacing: 0.0){
                        ForEach(0..<5, id:\.self){x in
                            HAHManager.cells[y][x]
                                .environment(NamespaceWrapper(namespace))
                                .onTapGesture {
                                    if !HAHManager.finishFlg{
                                        withAnimation{
                                            HAHManager.progressGame(y, x)
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
//                                    Text("y:\(y)\nx:\(x)").foregroundStyle(.pink).fontWeight(.black)
                                    // 位置座標表示
//                                    Text("\(cellPoints[y][x])").foregroundStyle(.pink).fontWeight(.black)
                                }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
            
        }
//        .background{
            // グラデーション背景
//            Image(colorScheme == .light ? "nature.ground.light":"nature.ground.dark")
//                .resizable()
//                .scaledToFill()
//            TimelineView(.periodic(from: .now, by: 5)) { _ in
//                let location = 0.5 + CGFloat.random(in: -0.2...0.2)
//                LinearGradient(
//                    stops: [
//                        .init(color: .blue.opacity(0.75), location: 0.0),
//                        .init(color: .brown.opacity(0.5), location: location),
//                        .init(color: .green.opacity(0.75), location: 1.0)
//                    ],
//                    startPoint: .topLeading,
//                    endPoint: .bottomTrailing
//                )
//                .animation(.linear(duration: 5), value: location)
//            }
//            .ignoresSafeArea()
//        }
        .overlay{
            VStack{
                HStack(alignment: .top){
                    // 左上の表示
                    VStack{
                        HStack(alignment: .lastTextBaseline, spacing: 4){
                            Text("Turn")
                                .font(.system(.headline, design: .rounded))
                            Text("\(HAHManager.turnCount)")
                                .font(.system(.title2, design: .rounded))
                                .fontWeight(.bold)
                                .contentTransition(.numericText(value: Double(HAHManager.turnCount)))
                            Text("/20")
                                .foregroundStyle(.secondary)
                                .font(.system(.caption, design: .rounded))
                                .fontWeight(.bold)
                            
                        }
                        Image(systemName: HAHManager.player.symbolName)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 30, height: 30)
                            .symbolVariant(.fill)
                            .foregroundStyle(HAHManager.player.color)
                            .scaleEffect(x: HAHManager.player == .hare ? -1 : 1, y: 1)
                    }
                    .padding()
//                    .glassEffect(.regular.interactive())
                    .glassEffect(.regular.tint(.secondary.opacity(0.5)).interactive(), in: .rect(cornerRadius: 16.0))
//                    .glassEffect(.regular.interactive())
                    .padding()
                    Spacer()
                    // 右上の表示
                    Menu{
                        Button {
                            undo?.removeAllActions()
                            HAHManager.setUp()
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
                            .glassEffect(.regular.interactive(), in: .circle)
                            Button{
                                withAnimation{
                                    undo?.redo()
                                }
                            } label: {
                                Image(systemName: "arrow.uturn.forward")
                                    .padding()
                            }
                            .disabled(undo?.canRedo == false)
                            .glassEffect(.regular.interactive(), in: .circle)
                        }
                        .buttonStyle(.plain)
                        .disabled(HAHManager.finishFlg)
                    }
                    .padding()
                }
                
            }
        }

        .sheet(isPresented: $HAHManager.showResult) {
            ZStack{
                Button{
                    HAHManager.showResult = false
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
                    HStack{
                        Text("Win")
                        if let p = HAHManager.winPlayer {
                            Image(systemName: p.symbolName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .symbolVariant(.fill)
                                .foregroundStyle(p.color)
                                .scaleEffect(x: p == .hare ? -1 : 1, y: 1)
                        }
                    }
                    .font(.largeTitle)
                    
                    Button {
                        undo?.removeAllActions()
                        HAHManager.setUp()
                        HAHManager.showResult = false
                    } label: {
                        Label("Restart", systemImage: "arrow.trianglehead.counterclockwise")
                    }
                    // 終了ボタン
                    Button {
                        undo?.removeAllActions()
                        HAHManager.showResult = false
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Label("End game", systemImage: "xmark.circle")
                    }
                }
                .buttonStyle(.glassProminent)
            }
            .presentationDetents([.large, .medium, .height(200)]) // ⬅︎
        }

        .onAppear { HAHManager.undo = undo }
    }
}

#Preview {
    HareAndHoundsView()
}


