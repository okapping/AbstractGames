//
//  CheckersView.swift
//  AbstractGames
//
//  Created by 岡山直也 on 2025/12/08.
//

import SwiftUI


enum ChPlayerStatus{
    case first,second
    //マークの集合(Set)。別に配列でもいい。
//    static let canMoves:Set<Self> = [.first, .second]
    //コマの色
    var color: Color {
        switch self {
        case .first:
            return .black
        case .second:
            return .white
        }
    }
    
    var anotherPiece: Self {
        switch self {
        case .first: return .second
        case .second:return .first
        }
    }
}

struct ChPiece: Hashable, Identifiable {
    var id = UUID()
    var player: ChPlayerStatus
    var isActive: Bool = false
    var name: String
    var canMoveCells: [Cell] = []
    var jumpFlg: Bool = false
    var isKing: Bool = false
}

struct CheckersCell:View {
    @Environment(NamespaceWrapper.self) var namespaceWrapper
    var piece:ChPiece? = nil
    var canMove: Bool = false
//    var isGoal: Bool = false
    // このセルの座標
    var cellIndex: (y:Int,x:Int)
    
    let lightBackgroundColor: Color = Color(red: 234/255, green: 223/255, blue: 193/255)
    let darkBackgroundColor: Color = Color(red: 126/255, green: 121/255, blue: 109/255)
    let moveColor: Color = .red.opacity(0.75)
    
    var body: some View{
        ZStack{
            Rectangle()
                .foregroundStyle( (cellIndex.y+cellIndex.x)%2==0 ? lightBackgroundColor : darkBackgroundColor )
                .opacity(0.8)
//                .foregroundStyle(.green.opacity(canMove ? 0.5 : 0.85))
                .border(.primary, width: 1.0)
            if let p = piece{
                if p.isActive {
                    Rectangle()
                        .fill(moveColor)
                        .transition(.opacity)
//                        .matchedGeometryEffect(id: "isActive", in: namespaceWrapper.namespace)
                }
            }

        }
        .overlay{
            if let p = piece{
                ZStack{
                    Image(systemName: "circle.fill")
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(0.8)
                        .foregroundStyle(p.player.color)
                    if p.isKing {
                        Image(systemName: "crown.fill")
                            .resizable()
                            .scaledToFit()
                            .scaleEffect(0.6)
                            .foregroundStyle(.white)
                            .blendMode(.difference)
                    }
                }
                .geometryGroup()
                .matchedGeometryEffect(id: p.name, in: namespaceWrapper.namespace)
            }
        }
//        .overlay{
//            if let p = piece{
//                Text("\(p.canMoveCells.count)")
//                    .foregroundStyle(.white)
//                    .blendMode(.difference)
//            }
//            
//        }
        .overlay{
            if canMove {
                Circle()
                    .fill(moveColor)
                    .scaleEffect(0.4)
                    .transition(.opacity)
            }
            
        }
        .scaledToFit()
    }
}
@Observable class CheckersManager{
    var player:ChPlayerStatus = .first
    var winFlg: Bool = false
    var drawFlg: Bool = false
    var isJumping: Bool = false
    
    var winPlayer: ChPlayerStatus? = nil
    
    var cells:[[CheckersCell]] = []
    
    var undo: UndoManager?
    
    var pieceCount: [ChPlayerStatus: Int] = [.first: 0, .second: 0]
    var turnCount: Int = 0
    init(){
        setUp()
    }
    public func setUp(){
        player = .first
        winFlg = false
        drawFlg = false
        turnCount = 0
        
        undo?.removeAllActions()
        
        withAnimation{
            cells = (0..<8).map { y in
                (0..<8).map { x in
                    CheckersCell(cellIndex: (y, x)) // y座標を引数として渡す
                }
            }
            // 初期コマの配置
            for y in 0..<8 {
                for x in 0..<8 {
                    if y < 3 && (y+x)%2 != 0 {
                        cells[y][x].piece = ChPiece(player: .first, name: "first-\(y)-\(x)")
                    }
                    if (5..<8).contains(y) && (y+x)%2 != 0 {
                        cells[y][x].piece = ChPiece(player: .second, name: "second-\(y)-\(x)")
                    }
                }
            }
            setCanMoveCells()
            countPieces()
        }
    }
    
    public func getActiveCell() -> (y:Int,x:Int)?{
        for y in 0..<8{
            for x in 0..<8{
                if cells[y][x].piece?.isActive == true{
                    return (y, x)
                }
            }
        }
        return nil
    }
    public func setActiveStatus(_ cell: (y:Int,x:Int)){
        cells[cell.y][cell.x].piece?.isActive = true
    }
    public func resetActiveStatus(){
//        cells[cell.y][cell.x].piece?.isActive = false
        for y in 0..<8{
            for x in 0..<8{
                cells[y][x].piece?.isActive = false
            }
        }
    }
    public func isInsideBoard(_ cell: (y:Int,x:Int)) -> Bool {
        if (0..<8).contains(cell.y) && (0..<8).contains(cell.x) {
            return true
        }
        return false
    }
    private func setCanMoveCells(skipCells: [(y:Int,x:Int)] = []){
        let moveDirections: [(y:Int, x:Int)] = [(-1,-1), (-1,1), (1,-1), (1,1)]
        // 先に飛び越えられる場所があるかチェックする
        // 飛び越えることができる場合は、飛び越えた先にのみ移動可能

        for y in 0..<8{
            for x in 0..<8{
                // 初期化
                cells[y][x].piece?.canMoveCells = []
                cells[y][x].piece?.jumpFlg = false
                // 空きコマの場合は脱出
                if cells[y][x].piece == nil {continue}
                // スキップセルに含まれている場合はスキップ
                if skipCells.contains(where: {$0 == (y:y,x:x)}) {continue}
                
                var canJump: Bool = false
                for direction in moveDirections {
                    var checkCell: (y:Int,x:Int) = (y+direction.y, x+direction.x)
                    if (0..<8).contains(checkCell.y) && (0..<8).contains(checkCell.x) {
                        // 自身と同じのコマと空白は除外する
                        if cells[checkCell.y][checkCell.x].piece?.player == cells[y][x].piece?.player {continue}
                        if cells[checkCell.y][checkCell.x].piece == nil {continue}
                        // 敵のコマの場合はさらに奥のコマまでチェックする
                        if cells[checkCell.y][checkCell.x].piece?.player == cells[y][x].piece?.player.anotherPiece {
                            checkCell = (checkCell.y+direction.y,checkCell.x+direction.x)
                            if !isInsideBoard(checkCell) || cells[checkCell.y][checkCell.x].piece != nil {continue}
                        }
                        // キングになっていない場合、進行方向の逆へは進めない
                        if cells[y][x].piece?.isKing == false {
                            switch cells[y][x].piece?.player {
                            case .first:
                                if direction.y < 0 {continue}
                            case .second:
                                if direction.y > 0 {continue}
                            case nil:
                                break
                            }
                        } else {
                        }
                        // コマ配置可能
                        cells[y][x].piece?.canMoveCells.append(Cell(checkCell))
                        cells[y][x].piece?.jumpFlg = true
                        canJump = true
                    }
                }
                // ジャンプができない場合はすぐ周りの空白を探す
                if !canJump {
                    for direction in moveDirections {
                        let checkCell: (y:Int,x:Int) = (y+direction.y,x+direction.x)
                        if (0..<8).contains(checkCell.y) && (0..<8).contains(checkCell.x) {
                            // コマ（どちらの色も）が配置してある場所には置けない
                            if cells[checkCell.y][checkCell.x].piece != nil {continue}
                            // キングになっていない場合、進行方向の逆へは進めない
                            if cells[y][x].piece?.isKing == false {
                                switch cells[y][x].piece?.player {
                                case .first:
                                    if direction.y < 0 {continue}
                                case .second:
                                    if direction.y > 0 {continue}
                                case nil:
                                    break
                                }
                            } else {
                            }
                            // コマ配置可能
                            cells[y][x].piece?.canMoveCells.append(Cell(checkCell))
                        }
                    }
                }

            }
        }

    }
    private func showCanMoveCells(_ tapCell: (y:Int,x:Int)){
//        print("showCanMoveCells")
        for cell in cells[tapCell.y][tapCell.x].piece!.canMoveCells{
            cells[cell.y][cell.x].canMove = true
        }
    }
    private func hideCanMoveCells(){
        for y in 0..<8{
            for x in 0..<8{
                cells[y][x].canMove = false
            }
        }
    }
//    private func removePiece(_ activeCell: (y:Int,x:Int),_ targetCell: (y:Int,x:Int)){
////        self.resetMoveCells()
//    }
    public func movePiece(_ activeCell: (y:Int,x:Int),_ targetCell: (y:Int,x:Int)){
        let moveDirection: (y:Int,x:Int) = (targetCell.y-activeCell.y,targetCell.x-activeCell.x)
        print("moveDirection \(moveDirection)")
        
//        undo?.beginUndoGrouping()
//        undo?.registerUndo(withTarget: self) { me in
//            me.setCanMoveCells()
//            me.changePlayer()
//        }
        
        // コマを飛び越えた場合
        if moveDirection.y % 2 == 0 {
            let jumpedPiece: (y:Int,x:Int) = (activeCell.y+(moveDirection.y/2),activeCell.x+(moveDirection.x/2))
//            moveDirection = (moveDirection.y/2,moveDirection.x/2)
            print("jumpedPiece \(moveDirection)")
            let deletedPiece = cells[jumpedPiece.y][jumpedPiece.x].piece!
            undo?.registerUndo(withTarget: self) { me in
                me.cells[jumpedPiece.y][jumpedPiece.x].piece = deletedPiece
            }
            cells[jumpedPiece.y][jumpedPiece.x].piece = nil
        }
        undo?.registerUndo(withTarget: self) { me in
            me.cells[activeCell.y][activeCell.x].piece = me.cells[targetCell.y][targetCell.x].piece
            me.cells[targetCell.y][targetCell.x].piece = nil
        }
        cells[targetCell.y][targetCell.x].piece = cells[activeCell.y][activeCell.x].piece
        cells[activeCell.y][activeCell.x].piece = nil
//        undo?.endUndoGrouping()
    }

    private func changePlayer(){
        let oldPlayer = player
        undo?.registerUndo(withTarget: self) { me in
            me.player = oldPlayer
        }
        player = player.anotherPiece
    }
    private func checkWin() -> Bool{
        // 残数がゼロになったら負け
        if pieceCount[.first]! == 0{
            winFlg = true
            winPlayer = .second
            return true
        }
        if pieceCount[.second]! == 0{
            winFlg = true
            winPlayer = .first
            return true
        }
        
        // 動ける場所がなくなったら負け
        var firstCantMoveFlg = true
        var secondCantMoveFlg = true
        for y in 0..<8{
            for x in 0..<8{
                if cells[y][x].piece == nil { continue }
                switch cells[y][x].piece!.player {
                case .first:
                    if cells[y][x].piece!.canMoveCells.count > 0 {
                        firstCantMoveFlg = false
                        break
                    }
                case .second:
                    if cells[y][x].piece!.canMoveCells.count > 0 {
                        secondCantMoveFlg = false
                        break
                    }
                }
            }
        }
        if firstCantMoveFlg {
            winFlg = true
            winPlayer = .second
            return true
        }
        if secondCantMoveFlg {
            winFlg = true
            winPlayer = .first
            return true
        }
        return false
    }
    private func countPieces(){
        pieceCount = [.first: 0, .second: 0]
        for y in 0..<8{
            for x in 0..<8{
                switch cells[y][x].piece?.player{
                case .first:
                    pieceCount[.first]! += 1
                case .second:
                    pieceCount[.second]! += 1
                case .none:
                    continue
                }
            }
        }
    }
    private func upgradeToKing() -> [(y:Int,x:Int)]{
    var result: [(y:Int,x:Int)] = []
//        for y in 0..<8{
            for x in 0..<8{
                if cells[0][x].piece?.player == .second{
                    if cells[0][x].piece?.isKing == false{
                        undo?.registerUndo(withTarget: self) { me in
                            me.cells[0][x].piece?.isKing = false
                        }
                        cells[0][x].piece?.isKing = true
                        result.append( (y:0,x:x) )
                    }
                }
                if cells[7][x].piece?.player == .first{
                    if cells[7][x].piece?.isKing == false{
                        undo?.registerUndo(withTarget: self) { me in
                            me.cells[0][x].piece?.isKing = false
                        }
                        cells[7][x].piece?.isKing = true
                        result.append( (y:7,x:x) )
                    }
                }
            }
//        }
        return result
    }
    public func turnActions(_ activeCell: (y:Int,x:Int),_ tapCell: (y:Int,x:Int)){
        undo?.beginUndoGrouping()
        undo?.registerUndo(withTarget: self) { me in
            me.undo?.registerUndo(withTarget: self) { me in
                me.turnActions(activeCell, tapCell)
            }
            me.setCanMoveCells()
            if me.isJumping {
                me.setActiveStatus(activeCell)
                me.showCanMoveCells(activeCell)
                
            }
            me.countPieces()
        }
        movePiece(activeCell, tapCell)
        let result: [(y:Int,x:Int)] = upgradeToKing()
        setCanMoveCells(skipCells: result)
        countPieces()
        
        // ジャンプで移動したかを判定
        // ジャンプで移動したかつ移動先でもジャンプができる場合(jumpFlg)は、ターン継続
        let isJumpMove = (activeCell.y-tapCell.y) % 2 == 0
        
        print("isJumpMove = \(isJumpMove)")
        if isJumpMove && cells[tapCell.y][tapCell.x].piece?.jumpFlg == true {
            let oldIsJumping = isJumping
            undo?.registerUndo(withTarget: self) { me in
                me.isJumping = oldIsJumping
            }
            isJumping = true
            hideCanMoveCells()
            showCanMoveCells(tapCell)
        } else {
            let oldIsJumping = isJumping
            undo?.registerUndo(withTarget: self) { me in
                me.isJumping = oldIsJumping
//                if oldIsJumping {
//                    me.showCanMoveCells(activeCell)
//                }
            }
            isJumping = false
            // 非アクティブ化
            resetActiveStatus()
            hideCanMoveCells()
            
            setCanMoveCells()
            if checkWin() {
            } else {
                changePlayer()
            }
        }
        undo?.registerUndo(withTarget: self) { me in
            me.resetActiveStatus()
            me.hideCanMoveCells()
        }
        undo?.endUndoGrouping()
        

    }
    public func progressGame(_ y:Int,_ x:Int){
        print("TAP in Checkers \(Date())")
//        if !isJumping {
//            undo?.beginUndoGrouping()
//        }
        let tapCell: (y:Int,x:Int) = (y, x)
        let activeCell: (y:Int,x:Int)? = getActiveCell()
//        print("activeCell = \(activeCell)")
        if let activeCell = activeCell {
//            / そのセルはアクティブセルか？
            if tapCell == activeCell {
                if isJumping { return }
                // アクティブ状態を戻す
                resetActiveStatus()
                hideCanMoveCells()
                return
            }
            if cells[tapCell.y][tapCell.x].canMove == true{
//                //
                turnActions(activeCell, tapCell)

            } else {
                if isJumping { return }
                if cells[tapCell.y][tapCell.x].piece == nil {return}
                if cells[tapCell.y][tapCell.x].piece?.player == player.anotherPiece {return}
                resetActiveStatus()
                hideCanMoveCells()
                setActiveStatus(tapCell)
                showCanMoveCells(tapCell)
            }
        } else {
//            // アクティブでない場合
            if cells[tapCell.y][tapCell.x].piece == nil {return}
            if cells[tapCell.y][tapCell.x].piece?.player == player.anotherPiece {return}
            setActiveStatus(tapCell)
            showCanMoveCells(tapCell)
//            //
//            //            }
//            //
        }
    }
}


struct CheckersView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.undoManager) private var undo
    @State var checkersManager = CheckersManager()
    @Namespace private var namespace

    var body: some View {
        ZStack{
            // 右上のメニュー
            Menu{
                Button {
                    checkersManager.setUp()
                } label: {
                    Label("Restart", systemImage: "arrow.trianglehead.counterclockwise")
                }
                // 閉じるボタン
                Button {
                    undo?.removeAllActions()
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
                Image(systemName: "circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .foregroundStyle(checkersManager.player.color)
//                    .scaleEffect(x: checkersManager.player == .black ? -1 : 1, y: 1)
            }
            .padding()
            .background(Color.secondary.opacity(0.25))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            
            // 左下の個数表示
            HStack{
                VStack{
                    Text("Black")
                        .font(.headline)
                    Text("\(checkersManager.pieceCount[ChPlayerStatus.first]!)")
                        .font(.system(.title, design: .rounded))
                        .fontWeight(.bold)
                        .contentTransition(.numericText(value: Double(checkersManager.pieceCount[ChPlayerStatus.first]!)))
                }
                RoundedRectangle(cornerRadius: 10)
                    .fill(.secondary.opacity(0.5))
                    .frame(width:2, height: 50)
                VStack{
                    Text("White")
                        .font(.headline)
                    Text("\(checkersManager.pieceCount[ChPlayerStatus.second]!)")
                        .font(.system(.title, design: .rounded))
                        .fontWeight(.bold)
                        .contentTransition(.numericText(value: Double(checkersManager.pieceCount[ChPlayerStatus.second]!)))
                }
            }
            .padding()
            .background(Color.secondary.opacity(0.25))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
            // 右下のredo undo
            HStack{
                Button{
                    withAnimation{
                        undo?.undo()
                    }
                } label: {
                    Image(systemName: "arrow.uturn.backward")
                }
                .disabled(undo?.canUndo == false)
                Button{
                    withAnimation{
                        undo?.redo()
                    }
                } label: {
                    Image(systemName: "arrow.uturn.forward")
                }
                .disabled(undo?.canRedo == false)
            }
            .disabled(checkersManager.winFlg || checkersManager.drawFlg)
            .gameUndoRedoButtonStyle()
            // ゲーム本体
            VStack{
                //                Text(reversiManager.winFlg ? "winFlg : true" : "winFlg : false")
                //                Text(reversiManager.drawFlg ? "drawFlg : true" : "drawFlg : false")
                HStack{
                    // 決着後の表示
                    if checkersManager.winFlg {
                        HStack{
                            Text("Win")
                            ZStack{
                                Image(systemName: "circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                                    .foregroundStyle(checkersManager.winPlayer!.color)
                                Circle()
                                    .stroke(lineWidth: 2)
                                    .frame(width: 30, height: 30)
                                    .foregroundStyle(.primary)
                            }
                        }
                        .font(.title)
                        .fontWeight(.bold)
                        .padding()
                        .transition(.scale)
                    }
//                    // 引き分け表示
//                    if checkersManager.drawFlg{
//                        Text("Draw")
//                            .font(.title)
//                            .fontWeight(.bold)
//                            .padding()
//                            .transition(.scale)
//                    }
                    if checkersManager.winFlg || checkersManager.drawFlg{
                        Button {
                            checkersManager.setUp()
                        } label: {
                            Label("Restart", systemImage: "arrow.trianglehead.counterclockwise")
                        }
                        .buttonStyle(.bordered)
                        .transition(.scale)
                        // 閉じるボタン
                        Button {
                            undo?.removeAllActions()
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
                
                VStack(spacing: 0.0){
                    ForEach(0..<8, id:\.self){y in
                        HStack(spacing: 0.0){
                            ForEach(0..<8, id:\.self){x in
                                checkersManager.cells[y][x]
                                    .environment(NamespaceWrapper(namespace))
                                    .onTapGesture {
                                        withAnimation{
                                            checkersManager.progressGame(y, x)
                                        }
                                    }
                            }
                        }
                    }
                }
                .padding(8)
                .border(Color.primary, width: 8)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                
            }
        }
        .padding()
        .onAppear {
            checkersManager.undo = undo
            //            undo?.removeAllActions()
        }
    }
}

#Preview {
    CheckersView()
}
