//
//  AnimalShogiView.swift
//  AbstractGames
//
//  Created by 岡山直也 on 2025/11/30.
//

import SwiftUI

enum ASPieceStatus{
    case chick, chicken, giraffe, elephant, lion
    
//    static let pieces:Set<Self> = [.hounds, .hare]
    var imageName: String{
        switch self {
        case .chick:
            return "Chick"
        case .chicken:
            return "Chicken"
        case .elephant:
            return "Elephant"
        case .giraffe:
            return "Giraffe"
        case .lion:
            return "Lion"
        }
    }
    
    var moveDirections: [(y: Int, x: Int)]{
        switch self {
        case .chick:
            return [(-1,0)]
        case .chicken:
            return [(-1,-1), (-1,0), (-1,1), (0,-1), (0,1), (1,0)]
        case .elephant:
            return [(-1,-1), (-1,1), (1,-1), (1,1)]
        case .giraffe:
            return [(-1,0), (0,-1), (0,1), (1,0)]
        case .lion:
            return [(-1,-1), (-1,0), (-1,1), (0,-1), (0,1), (1,-1), (1,0), (1,1)]
        }
    }
    
//    var color: Color {
//        switch self {
//        case .hounds:
//            return .black
//        case .hare:
//            return .white
//        }
//    }
//    var anotherPiece: Self {
//        switch self {
//        case .hounds: return .hare
//        case .hare:return .hounds
//        }
//    }
}

enum ASPlayerStatus{
    case first, second
    
    var color: Color {
        switch self {
        case .first:
            return .orange
        case .second:
            return .green
        }
    }

    var anotherPiece: Self {
        switch self {
        case .first: return .second
        case .second:return .first
        }
    }

}
enum ASActiveArea{
    case cell, captured, none
}
struct ASPiece: Hashable, Identifiable {
    var id = UUID()
    var status: ASPieceStatus
    var player: ASPlayerStatus
    var isActive: Bool = false
    var name: String
    
    // ついの座標を取得（対面で操作する時の逆側の算出用）
    func getOppositeDirection(direction: (y: Int, x: Int)) -> (y: Int, x: Int){
        let directions: [(y: Int, x: Int)] = [(-1,-1), (-1,0), (-1,1), (0,-1), (0,1), (1,-1), (1,0), (1,1)]
        let opposites: [(y: Int, x: Int)] = [(1,1), (1,0), (1,-1), (0,1), (0,-1), (-1,1), (-1,0), (-1,-1)]
        
        if let index = directions.firstIndex(where: { $0 == direction }) {
            return opposites[index]
        }
        // 引数がdirectionsに含まれていない場合
        return (0, 0)
    }
    func getOppositeDirections(directions: [(y: Int, x: Int)]) -> [(y: Int, x: Int)] {
        var tmpDir: [(y: Int, x: Int)] = []
        for direction in directions {
            tmpDir.append(getOppositeDirection(direction: direction))
        }
        return tmpDir
    }
    // コマの移動先
    var playerMoveDirections: [(y: Int, x: Int)] {
        switch self.player {
        case .first:
            // 対面する先行は逆の座標を返す
            return getOppositeDirections(directions: self.status.moveDirections)
        case .second:
            return self.status.moveDirections
        }
    }

}

struct AnimalShogiPiece:View {
    var piece:ASPiece
    var body: some View{
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(.white)
            RoundedRectangle(cornerRadius: 10)
                .fill(piece.player.color.opacity(0.1))
//                .scaleEffect(0.8)
//            RoundedRectangle(cornerRadius: 10)
//                .stroke(lineWidth: 4)
//                .fill(.black)
//                .scaleEffect(0.8)
            // 進行方向
            VStack {
                ForEach(-1..<2, id:\.self){y in
                    HStack{
                        ForEach(-1..<2, id:\.self){x in
                            ZStack{
                                Circle()
                                    .fill(piece.player.color)
//                                Circle()
//                                    .stroke(lineWidth: 4)
//                                    .fill(Color.black)
                            }
                            .frame(minWidth: 10, minHeight: 10)
//                            .frame(width: 20, height: 20)
                            .frame(maxWidth: 20, maxHeight:20)
                            .frame(maxWidth: .infinity, maxHeight:.infinity)
//                            .scaleEffect(0.6)
//                            .padding(8)
//                            .scaledToFit()
                            .opacity(piece.status.moveDirections.contains(where: { $0 == (y, x) }) ? 1 : 0)
                        }
                    }
                }
            }
//            .scaleEffect(0.8)
            // コマ画像
            Image(piece.status.imageName)
                .resizable()
                .scaledToFit()
//                .foregroundStyle(.black)
                .scaleEffect(0.9)
            RoundedRectangle(cornerRadius: 10)
                .stroke(lineWidth: 4)
                .fill(.black)
        }
        .scaledToFit()

    }
}

struct AnimalShogiCell:View {
    var piece:ASPiece? = nil
    var showCell: Bool = true
//    @Environment var namespaceWrapper: NamespaceWrapper?
    @Environment(NamespaceWrapper.self) var namespaceWrapper

    var canMove: Bool = false
    let moveColor: Color = .blue.opacity(0.75)
    
    var body: some View{
        ZStack{
            if let p = piece{
                if p.isActive {
                    Rectangle()
                        .fill(moveColor)
//                        .matchedGeometryEffect(id: "isActive", in: namespaceWrapper.namespace)
                }
            }
            Rectangle()
//                .stroke(lineWidth: 4)
                .stroke(style: StrokeStyle(lineWidth: 4, dash: [12, 12]))
                .fill(.primary.opacity(0.8))
//            Circle()
//                .fill(piece?.isActive == true ? .yellow : .green)
//                .scaleEffect(0.8)
//            Circle()
//                .stroke(lineWidth: 4)
//                .scaleEffect(0.8)
        }
        .overlay{
            if let p = piece{
                AnimalShogiPiece(piece: p)
                    .scaleEffect(0.8)
                    .matchedGeometryEffect(id: p.name, in: namespaceWrapper.namespace)
                    .transition(.scale(scale: 1))
                    .rotationEffect(Angle(degrees: p.player == .first ? 180 : 0))
            }
        }
        .overlay{
            if canMove {
                Circle()
                    .fill(moveColor)
                    .scaleEffect(0.4)
                    .transition(.opacity)
            }
            
        }
        .opacity(showCell ? 1 : 0)
        .scaledToFit()
        
        
    }
}
@Observable class AnimalShogiManager{
//class AnimalShogiManager:ObservableObject{
    var player:ASPlayerStatus = .first
    var winFlg: Bool = false
    var drawFlg: Bool = false
    
    var turnCount: Int = 1
    var winPlayer: ASPlayerStatus? = nil
    
    var activeArea: ASActiveArea = .none
        
    var capturedPieces: [ASPlayerStatus: [ASPiece]] = [.first: [], .second: []]
    var cells:[[AnimalShogiCell]] = []
//    @Published var cells:[[AnimalShogiCell]] = []
    init(){
        setUp()
    }
    
    public func setUp(){
        player = .first
        winFlg = false
        drawFlg = false
        winPlayer = nil
        turnCount = 1
        capturedPieces = [.first: [], .second: []]
        activeArea = .none
        
        withAnimation{
            //            cells = [[HareAndHoundsCell]](repeating: [HareAndHoundsCell](repeating: HareAndHoundsCell(), count: 5), count: 3)
            cells = (0..<4).map { y in
                (0..<3).map { x in
                    AnimalShogiCell()
                }
            }
            // 非表示セルの設定
//            cells[0][0].showCell = false
//            cells[0][4].showCell = false
//            cells[2][0].showCell = false
//            cells[2][4].showCell = false
            
            // 初期コマの配置
            cells[0][0].piece = ASPiece(status: .giraffe, player: .first, name: "first-giraffe")
            cells[0][1].piece = ASPiece(status: .lion, player: .first, name: "first-lion")
            cells[0][2].piece = ASPiece(status: .elephant, player: .first, name: "first-elephant")
            cells[1][1].piece = ASPiece(status: .chick, player: .first, name: "first-chick")
            cells[2][1].piece = ASPiece(status: .chick, player: .second, name: "second-chick")
            cells[3][0].piece = ASPiece(status: .elephant, player: .second, name: "second-elephant")
            cells[3][1].piece = ASPiece(status: .lion, player: .second, name: "second-lion")
            cells[3][2].piece = ASPiece(status: .giraffe, player: .second, name: "second-giraffe")
//            cells[0][1].piece = HAHPiece(status: .hounds, name: "hound1")
//            cells[1][0].piece = HAHPiece(status: .hounds, name: "hound2")
//            cells[2][1].piece = HAHPiece(status: .hounds, name: "hound3")
//            cells[1][4].piece = HAHPiece(status: .hare, name: "hare1")
            
            //デバック
//            capturedPieces[.first]!.append(cells[0][0].piece!)
        }
    }
    public func getActiveCell() -> (y:Int,x:Int)?{
        for y in 0..<4{
            for x in 0..<3{
                if cells[y][x].piece?.isActive == true {
                    return (y, x)
                }
            }
        }
        return nil
    }
//    public func getAnimalCells(_ animal: HAHPieceStatus) -> [(y:Int,x:Int)]{
//        let tmpCells: [(y: Int, x: Int)] = (0..<3).flatMap { y in
//            (0..<5).compactMap { x in
//                cells[y][x].piece?.status == animal ? (y, x) : nil
//            }
//        }
//        
//        return tmpCells
//    }
    public func setActiveStatus(_ cell: (y:Int,x:Int)){
        cells[cell.y][cell.x].piece?.isActive = true
        activeArea = .cell
    }
    public func resetActiveStatus(_ cell: (y:Int,x:Int)){
        cells[cell.y][cell.x].piece?.isActive = false
        activeArea = .none
    }
    private func setCanMoveCells(_ tapCell: (y:Int,x:Int)){
//
        let moveDirections = cells[tapCell.y][tapCell.x].piece!.playerMoveDirections
//        let moveDirections = ASPieceStatus.playerMoveDirections(cells[tapCell.y][tapCell.x].piece!.status, player)
        print("moveDirections = \(moveDirections)")
        for direction in moveDirections {
            let checkCell: (y:Int,x:Int) = (tapCell.y+direction.y,tapCell.x+direction.x)
            if (0..<4).contains(checkCell.y) && (0..<3).contains(checkCell.x) {
                // 自分のコマが配置してある場所には置けない
                if cells[checkCell.y][checkCell.x].piece?.player == player {continue}
                
                // コマ配置可能
                cells[checkCell.y][checkCell.x].canMove = true
            }
        }
//        cells[tapCell.y][tapCell.x].piece?.status.moveDirections.forEach { direction in
////            let moveCell: (y:Int,x:Int) = ()
//        }
//        let cell = Cell(y: tapCell.y, x: tapCell.x)
//        //        print("move cells \(cell)")
//        //        movableCells[cell]
//        //        print("move cells \(movableCells[cell])")
//        if let moveCells = movableCells[cell] {
//            for cell in moveCells {
//                print("can move cell = \(cell)")
//                // 既にコマ配置済みの場所には置けない
//                if cells[cell.y][cell.x].piece != nil {continue}
//                // 犬の場合、後ろには置けない
//                if cells[tapCell.y][tapCell.x].piece?.status == .hounds {
//                    if cell.x < tapCell.x {continue}
//                }
//                cells[cell.y][cell.x].canMove = true
//            }
//        }
//        //        for cell in movableCells[Cell(y: tapCell.y, x: tapCell.x)]{
//        //            print("moce cells \(cell)")
//        //        }
    }
    private func resetCanMoveCells(){
        for y in 0..<4{
            for x in 0..<3{
                cells[y][x].canMove = false
            }
        }
    }
    public func moveCells(_ targetCell: (y:Int,x:Int),_ activeCell: (y:Int,x:Int)){
//        let moveDirection: (y:Int,x:Int) = (y-activeCell.y,x-activeCell.x)
//        print("moveDirection \(moveDirection)")
        if let _ = cells[targetCell.y][targetCell.x].piece {
//            // 自分のコマにする
//            cells[targetCell.y][targetCell.x].piece?.player = player
            // 手持ちに追加する
            capturedPieces[player]!.append(cells[targetCell.y][targetCell.x].piece!)
            // 自分のコマにする
            let cnt = capturedPieces[player]!.count
            capturedPieces[player]![cnt-1].player = player
            // 盤面から消す
            cells[targetCell.y][targetCell.x].piece = nil
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation{
                self.cells[targetCell.y][targetCell.x].piece = self.cells[activeCell.y][activeCell.x].piece
                self.cells[activeCell.y][activeCell.x].piece = nil
            }

        }
//        cells[targetCell.y][targetCell.x].piece = cells[activeCell.y][activeCell.x].piece
//        cells[activeCell.y][activeCell.x].piece = nil
//        cells[y][x].pieces.append(cells[activeCell.y][activeCell.x].pieces.last!)
//        cells[activeCell.y][activeCell.x].pieces.removeLast()
    }
    
    private func setCapturedPiecesCanMoveCells(){
        for y in 0..<4{
            for x in 0..<3{
                if cells[y][x].piece == nil {
                    cells[y][x].canMove = true
                }
            }
        }
    }
    private func changePlayer(){
        player = player.anotherPiece
    }
    
//    private func checkWin() -> Bool{
//        // 勝利条件（wikiより）
//        // ・ウサギが全ての猟犬より後ろ（進行方向と逆）の点に移動した場合、ウサギ側の勝利となる。
//        // ・ウサギが移動できる全ての頂点を猟犬によって塞がれ、ウサギが移動できなくなった場合、猟犬側の勝利となる。
//        // ・千日手（一般的なゲームにおいては20手で勝敗が決しなかった状態）になった場合、ウサギ側の勝利となる。
//        
//        // ・ウサギが全ての猟犬より後ろ（進行方向と逆）の点に移動した場合、ウサギ側の勝利となる。
//        let houndsCells = getAnimalCells(.hounds)
//        //        print("hound Cells = \(houndsCells)")
//        let hareCells = getAnimalCells(.hare)
//        //        print("hare Cells = \(hareCells)")
//        if houndsCells.allSatisfy({ $0.x > hareCells[0].x }) {
//            winFlg = true
//            winPlayer = .hare
//            return true
//        }
//        // ・ウサギが移動できる全ての頂点を猟犬によって塞がれ、ウサギが移動できなくなった場合、猟犬側の勝利となる。
//        let wrappedHareCell: Cell = Cell(y: hareCells[0].y, x: hareCells[0].x)
//        if let moveCells = movableCells[wrappedHareCell] {
//            if moveCells.allSatisfy({ cells[$0.y][$0.x].piece != nil }) {
//                winFlg = true
//                winPlayer = .hounds
//                return true
//            }
//        }
//        // ・千日手（一般的なゲームにおいては20手で勝敗が決しなかった状態）になった場合、ウサギ側の勝利となる。
//        if turnCount == 20 {
//            winFlg = true
//            winPlayer = .hare
//            return true
//        }
//        return false
//    }
    
    public func progressGame(_ y:Int,_ x:Int){
        print("TAP in AnimalShogi \(Date())")
        //
        let tapCell: (y:Int,x:Int) = (y, x)
        let activeCell: (y:Int,x:Int)? = getActiveCell()
        let activeCaptured: Int? = capturedPieces[player]!.firstIndex(where: { $0.isActive })

        
//        // アクティブセルかどうか
//        if activeCell != nil{
        switch activeArea{
        case .cell:
            if let activeCell = activeCell {
                if tapCell == activeCell {
                    //                // アクティブ状態を戻す
                    resetActiveStatus(activeCell)
                    resetCanMoveCells()
                    return
                }
                if cells[tapCell.y][tapCell.x].canMove{
                    // 移動先セルだった場合
                    
                    // コマの移動
                    moveCells(tapCell, activeCell)
                    
                    // コマのステータス変更
                    resetActiveStatus(activeCell)
                    resetCanMoveCells()
                    activeArea = .none
                    //
                    //                // 勝敗判定
                    //                if checkWin() {
                    //                    //
                    //                } else {
                    //                    // プレイヤー交代
                    changePlayer()
                    //                    // ターン経過
                    //                    turnCount += 1
                    //                }
                    //
                } else {
                    if cells[tapCell.y][tapCell.x].piece?.player != player {return}
                    resetCanMoveCells()
                    resetActiveStatus(activeCell)
                    setActiveStatus(tapCell)
                    setCanMoveCells(tapCell)
                }
//                }
            }
            
        case .captured:
            if let activeCaptured = activeCaptured {
                if cells[y][x].piece?.player == player.anotherPiece {return}
                if cells[y][x].canMove {
                    // 移動先セルだった場合、手札のコマを配置
                    capturedPieces[player]![activeCaptured].isActive = false

                    cells[tapCell.y][tapCell.x].piece = capturedPieces[player]![activeCaptured]
                    capturedPieces[player]!.remove(at: activeCaptured)
                    // コマのステータス変更
//                    changeActiveStatus(false, activeCell.y, activeCell.x)
                    
                    resetCanMoveCells()
                    activeArea = .none
                    
                    changePlayer()

                } else {
                    // 移動先セルじゃなかった場合
                    if cells[tapCell.y][tapCell.x].piece?.player != player {return}
                    resetCanMoveCells()
                    capturedPieces[player]![activeCaptured].isActive = false
                    setActiveStatus(tapCell)
                    setCanMoveCells(tapCell)
                }
            }
        case .none:
            // アクティブでない場合
            if cells[tapCell.y][tapCell.x].piece?.player != player {return}
            setActiveStatus(tapCell)
            setCanMoveCells(tapCell)
        }
        
        
//        if let activeCell = activeCell{
//            if tapCell == activeCell {
////                // アクティブ状態を戻す
//                changeActiveStatus(false, y, x)
//                resetCanMoveCells()
//                activeArea = .none
//                
//            } else {
//                if cells[tapCell.y][tapCell.x].canMove{
//                    // 移動先セルだった場合
//                    
//                    // コマの移動
//                    moveCells(tapCell, activeCell)
//                    
//                    // コマのステータス変更
//                    changeActiveStatus(false, activeCell.y, activeCell.x)
//                    resetCanMoveCells()
//                    activeArea = .none
//                    //
//                    //                // 勝敗判定
//                    //                if checkWin() {
//                    //                    //
//                    //                } else {
//                    //                    // プレイヤー交代
//                    changePlayer()
//                    //                    // ターン経過
//                    //                    turnCount += 1
//                    //                }
//                    //
//                } else {
////                    // 移動先セルじゃなかった場合
////                    if cells[tapCell.y][tapCell.x].piece?.player != player {return}
////                    resetCanMoveCells()
////                    changeActiveStatus(false, activeCell.y, activeCell.x)
////                    changeActiveStatus(true, tapCell.y, tapCell.x)
////                    setCanMoveCells(tapCell)
////                    activeArea = .cell
//                }
//            }
////            
//        } else {
//            if let activeCaptured = activeCaptured {
//                capturedPieces[player]![activeCaptured].isActive = false
//                resetCanMoveCells()
//            }
////            // アクティブでない場合
//////            if let _ = cells[y][x].piece {
////                if cells[y][x].piece?.player == player.anotherPiece {return}
//////                //                changeCellsStatus(true, y, x)
////                changeActiveStatus(true, y, x)
////                setCanMoveCells(tapCell)
////                activeArea = .cell
////            }
////            //
//        }
    }
    // 控えのコマ用
    public func progressGame(_ piece: ASPiece){
        if piece.player != player {return}
        print("TAP in AnimalShogi capturedPieces \(Date())")
        
        guard let tapIndex = capturedPieces[player]?.firstIndex(of: piece) else { return }
        print("tapIndex = \(tapIndex)")
        let activeCell: (y:Int,x:Int)? = getActiveCell()
        
        switch activeArea{
        case .cell:
            if let activeCell = activeCell{
                resetActiveStatus(activeCell)
                resetCanMoveCells()
            }
            
            capturedPieces[player]![tapIndex].isActive = true
            setCapturedPiecesCanMoveCells()
            activeArea = .captured

        case .captured:
            if capturedPieces[player]![tapIndex].isActive {
                capturedPieces[player]![tapIndex].isActive = false
                resetCanMoveCells()
                activeArea = .none
            } else {
                for i in 0..<capturedPieces[player]!.count {
                    capturedPieces[player]![i].isActive = false
                }
                resetCanMoveCells()
                capturedPieces[player]![tapIndex].isActive = true
//                if let activeCell = activeCell {
//                    resetActiveStatus(activeCell)
//                    resetCanMoveCells()
//                }
                setCapturedPiecesCanMoveCells()
                activeArea = .captured
            }
        case .none:
            capturedPieces[player]![tapIndex].isActive = true
            setCapturedPiecesCanMoveCells()
            activeArea = .captured
        }
        // アクティブかどうか
//        if let activeCell = activeCell {
//            changeActiveStatus(false, activeCell.y, activeCell.x)
//            resetCanMoveCells()
//
//            capturedPieces[player]![tapIndex].isActive = true
//        } else {
//            capturedPieces[player]![tapIndex].isActive = true
//        }
    }
}


struct AnimalShogiView: View {
    @Environment(\.presentationMode) var presentationMode
//    @StateObject var animalShogiManager = AnimalShogiManager()
    @State var animalShogiManager = AnimalShogiManager()
    @Namespace private var namespace

    @State private var orientation: UIInterfaceOrientation = .unknown
    @State private var screenSizeWidth = CGFloat()
    @State private var screenSizeHeight = CGFloat()
//    @State private var screenSizeWidth = UIScreen.main.bounds.width
//    @State private var screenSizeHeight = UIScreen.main.bounds.height

    init(){
        guard let scene = UIApplication.shared.windows.last?.windowScene else { return }
        self.orientation = scene.interfaceOrientation
    }
    
    private func gameSize() -> CGSize{
        
        switch orientation {
        case .portrait, .portraitUpsideDown:
            return CGSize(width: screenSizeWidth, height: screenSizeHeight)
        case .landscapeLeft:
            return CGSize(width: screenSizeHeight, height: screenSizeWidth)
        case .landscapeRight:
            return CGSize(width: screenSizeHeight, height: screenSizeWidth)
        case .unknown:
            return CGSize(width: screenSizeWidth, height: screenSizeHeight)
        @unknown default:
            return CGSize(width: screenSizeWidth, height: screenSizeHeight)
        }
    }
    private func gameWidtg() -> CGFloat{
        
        switch orientation {
        case .portrait, .portraitUpsideDown:
            return screenSizeWidth
        case .landscapeLeft:
            return screenSizeHeight
        case .landscapeRight:
            return screenSizeHeight
        case .unknown:
            return screenSizeWidth
        @unknown default:
            return screenSizeWidth
        }
    }
    private func rotationSize() -> Angle{
        switch orientation {
        case .portrait, .portraitUpsideDown:
            return Angle(degrees: 0.0)
        case .landscapeLeft:
            return Angle(degrees: 90.0)
        case .landscapeRight:
            return Angle(degrees: 270.0)
        case .unknown:
            return Angle(degrees: 0.0)
        @unknown default:
            return Angle(degrees: 0.0)
        }
    }
    var body: some View {
        ZStack{
            // 右上のメニュー
            Menu{
                Button {
                    withAnimation{
                        animalShogiManager.setUp()
                    }
                } label: {
                    Label("Restart", systemImage: "arrow.trianglehead.counterclockwise")
                }
                // 閉じるボタン
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Label("Finish", systemImage: "xmark.circle")
                }
            } label: {
                Image(systemName: "menucard")
            }
            .gameMenuButtonStyle()
            // 左上のターン表示
            VStack{
                Text("Turn")
                    .font(.headline)
//                ZStack{
//                    RoundedRectangle(cornerRadius: 8)
//                        .fill(AnimalShogiManager.player.color)
//                        .transition(.scale(scale: 1))
//                    RoundedRectangle(cornerRadius: 8)
//                        .stroke(lineWidth: 2)
//                }
//                .frame(width: 30, height: 30)
            }
            .padding()
            .background(Color.secondary.opacity(0.25))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            
            VStack{
                HStack{
                    // 決着後の表示
                    if animalShogiManager.winFlg {
                        HStack{
                            Text("Win")
//                            ZStack{
//                                RoundedRectangle(cornerRadius: 8)
//                                    .fill(animalShogiManager.player.color)
//                                    .transition(.scale(scale: 1))
//                                RoundedRectangle(cornerRadius: 8)
//                                    .stroke(lineWidth: 2)
//                            }
//                            .frame(width: 30, height: 30)
                        }
                        .font(.title)
                        .fontWeight(.bold)
                        .padding()
                        .transition(.scale)
                    }
                    // 引き分け表示
                    if animalShogiManager.drawFlg{
                        Text("Draw")
                            .font(.title)
                            .fontWeight(.bold)
                            .padding()
                            .transition(.scale)
                    }
                    if animalShogiManager.winFlg || animalShogiManager.drawFlg{
                        Button {
                            animalShogiManager.setUp()
                        } label: {
                            Label("Restart", systemImage: "arrow.trianglehead.counterclockwise")
                        }
                        .buttonStyle(.bordered)
                        .transition(.scale)
                        // 閉じるボタン
                        Button {
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            Label("Finish", systemImage: "xmark.circle")
                        }
                        .buttonStyle(.bordered)
                        .transition(.scale)
                    }
                }
                .frame(height: 30)
                .frame(maxWidth: .infinity)
                
                // ゲーム本体
                
                VStack(spacing: 0.0){
                    HStack{
                        ForEach(animalShogiManager.capturedPieces[.first]!, id:\.self){ piece in
                            AnimalShogiPiece(piece: piece)
                                .background{
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.yellow, lineWidth: piece.isActive ? 15 : 0)
                                    //                                    .matchedGeometryEffect(id: "isActive", in: namespace)
                                    //                                    .fill(Color.yellow)
                                }
                                .padding(.leading, 16)
                                .matchedGeometryEffect(id: piece.name, in: namespace)
                                .onTapGesture {
                                    if !animalShogiManager.winFlg && !animalShogiManager.drawFlg{
                                        withAnimation{
                                            animalShogiManager.progressGame(piece)
                                        }
                                    }
                                }
                        }
                    }
                    .frame(height: 40)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(ASPlayerStatus.first.color)
                    .padding(4)
                    .rotationEffect(Angle(degrees: 180))
                    ForEach(0..<4, id:\.self){y in
                        HStack(spacing: 0.0){
                            ForEach(0..<3, id:\.self){x in
                                //                                Rectangle()
                                //                                    .stroke()
                                //                                    .scaledToFit()
                                animalShogiManager.cells[y][x]
                                    .environment(NamespaceWrapper(namespace))
                                    .onTapGesture {
                                        if !animalShogiManager.winFlg && !animalShogiManager.drawFlg{
                                            withAnimation{
                                                animalShogiManager.progressGame(y, x)
                                            }
                                        }
                                    }
                            }
                        }
                    }
                    HStack{
                        ForEach(animalShogiManager.capturedPieces[.second]!, id:\.self){ piece in
                            AnimalShogiPiece(piece: piece)
                                .background{
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.yellow, lineWidth: piece.isActive ? 15 : 0)
                                    //                                    .matchedGeometryEffect(id: "isActive", in: namespace)
                                    //                                    .fill(Color.yellow)
                                }
                                .padding(.leading, 16)
                                .padding(.vertical, 12)
                                .matchedGeometryEffect(id: piece.name, in: namespace)
                                .onTapGesture {
                                    if !animalShogiManager.winFlg && !animalShogiManager.drawFlg{
                                        withAnimation{
                                            animalShogiManager.progressGame(piece)
                                        }
                                    }
                                }
                            
                        }
                    }
//                    .padding()
                    .frame(height: 50)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(ASPlayerStatus.second.color)
                    .padding(4)
                }
//                .background(.blue.opacity(0.5))
//                .frame(width: 300, height: 500)
//                .scaledToFill()
//                .clipped()
//                .frame(height: gameSize())
                
//                .frame(width: gameWidtg())
//                .frame(gameSize())
//                .frame(height: screenSizeWidth-200)
                //                .frame(width: screenSizeWidth)
//                .frame(width: screenSizeHeight)
//                .frame(maxWidth: .infinity, maxHeight: .infinity)
//                .background(.gray.opacity(0.5))
//                .scaledToFit()
//                .rotationEffect(rotationSize())
//                .rotationEffect(Angle(degrees: DeviceOrientationHelper.shared().deviceRotationDegrees))
//                .background() {
//                    GeometryReader { geometry in
//                        Path { path in
//                            let size = geometry.size
//                            DispatchQueue.main.async {
//                                self.screenSizeWidth = size.width
//                                self.screenSizeHeight = size.height
////
////                                if self.cellSize != size {
////                                    self.cellSize = size
////                                }
//                            }
//                        }
//                    }
//                }

            }
        }
        .padding()
        .onReceive(NotificationCenter.default.publisher(for:UIDevice.orientationDidChangeNotification)) { _ in
            guard let scene = UIApplication.shared.windows.last?.windowScene else { return }
            self.orientation = scene.interfaceOrientation
            
        }
    }
}



#Preview {
    AnimalShogiView()
}
