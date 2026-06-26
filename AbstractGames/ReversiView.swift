//
//  ReversiView.swift
//  Test
//
//  Created by 岡山直也 on 2025/11/10.
//

import SwiftUI

enum RvStone{
    //Stone（石）の種類は黒と白と無色の３種類
    case black,white
    //色付きの石(黒白)のみの集合(Set)。別に配列でもいい。
    static let colored:Set<Self> = [.black,.white]
    //石の色
//    static let color = {(stone:Self)->Color in
//        switch stone{
//        case .black:.black
//        case .white:.white
////        case .none :.clear
//        }
//    }
    var color: Color {
        switch self {
        case .black: return .black
        case .white: return .white
        }
    }

    //反対の石黒の反対は白で、白の反対は黒。透明の反対は存在しないのでこの式にnoneを入れた場合はエラーが発生するようにしてます
    static let opposedStone = {(stone:Self)->Self in
        switch stone {
        case .black:.white
        case .white:.black
//        case .none :fatalError()
        }
    }
}

struct ReversiCell:View {
    var stone:RvStone? = nil
    var targetStones:[RvStone:[(y:Int,x:Int)]] = [.black:[],.white:[]]
    mutating func clearTargetStones(){
        for stone in RvStone.colored{
            targetStones[stone]!.removeAll()
        }
    }
    var canMove: Bool = false
    
    var body: some View{
        
        ZStack(){
            Rectangle()
                .foregroundStyle(.green.opacity(canMove ? 0.5 : 0.85))
                .border(.primary, width: 1.0)
            if let stone = stone {
                Image(systemName: "circle.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(stone.color)
                    .padding(4)
                    .scaleEffect(x: stone == .black ? -1 : 1, y: 1)
            }
        }
        .scaledToFit()
    }
}

struct CanNotMove {
    var flg = false
    var player: RvStone? = nil
}
@Observable class ReversiManager{
    var player:RvStone = .black
//    var winFlg: Bool = false
//    var drawFlg: Bool = false
    var finishFlg: Bool = false
    var showResult: Bool = false
    var resultState: ResultState = .none

    var winPlayer:RvStone? = nil
    var canNotMove: CanNotMove = .init()
    
    var blackCount = 0
    var whiteCount = 0
    
    var undo: UndoManager?
    
    var cells:[[ReversiCell]] = []
    init(){
        setUp()
    }
    
    public func setUp(){
        player = .black
        finishFlg = false
        showResult = false
        resultState = .none
        winPlayer = .none

        undo?.removeAllActions()
        
        cells = [[ReversiCell]](repeating: [ReversiCell](repeating: ReversiCell(), count: 8), count: 8)
        putStone(3,3,.black)
        putStone(4,4,.black)
        putStone(3,4,.white)
        putStone(4,3,.white)
        checkAllCells()
        countColors()
    }
    private func undoTask(_ y:Int,_ x:Int){
        countColors()
        changePlayer()
        checkAllCells()
        undo?.registerUndo(withTarget: self) { me in
            me.progressGame(y,x)
        }
    }
    private func putStone(_ y:Int,_ x:Int,_ stone:RvStone?){
        let oldStone = cells[y][x].stone
        undo?.registerUndo(withTarget: self) { me in
            me.putStone(y,x,oldStone)
        }
        cells[y][x].stone = stone
    }
    private func checkAllCells(){
        print("checkAllCells()")
        for y in 0..<8{
            for x in 0..<8{
                cells[y][x].clearTargetStones()//ひっくり返せるセルを初期化
                cells[y][x].canMove = false
                if(cells[y][x].stone == .none){//石が置いてないセルのみ調査
                    checkTargetStones(y,x)
                }
            }
        }
    }
    private func checkTargetStones(_ y:Int,_ x:Int){
        //調査方位(上下左右と斜めの座標方向)
        let directions:[(y:Int,x:Int)] = [(-1,-1),(-1,0),(-1,1),(0,-1),(0,1),(1,-1),(1,0),(1,1)]
        for stone in RvStone.colored{//黒白両方を確認
            for direction in directions{
                let foundTargetStones:[(y:Int,x:Int)] = findTargetStones(y,x,direction.y,direction.x,stone)
//                print("foundTargetStones = \(foundTargetStones)")
                if stone == player && !foundTargetStones.isEmpty {
                    cells[y][x].canMove = true
                }
                cells[y][x].targetStones[stone]!.append(contentsOf: foundTargetStones)
            }
        }
    }
    private func findTargetStones(_ y:Int,_ x:Int,_ dy:Int,_ dx:Int,_ stone:RvStone)->[(y:Int,x:Int)]{
        //そのセルはゲーム版の外もしくはそのセルには何も石がないかを確認
        let noneOrOB = {(y:Int,x:Int)->Bool in (!(0..<8).contains(y) || !(0..<8).contains(x)) || self.cells[y][x].stone == .none}
        
        var position:(y:Int,x:Int) = (y:y+dy,x:x+dx) //探索場所を更新
        if(noneOrOB(position.y, position.x)){return []} //何もないもしくはゲーム版の外なら終了。記録なし
        
        var result:[(y:Int,x:Int)] = []
        while(cells[position.y][position.x].stone == RvStone.opposedStone(stone)){ //反対の色の石が出続ける限り探索をおこなう
            result.append(position) //結果を記録
            position = (y:position.y+dy,x:position.x+dx) //探索場所を更新
            if(noneOrOB(position.y, position.x)){return []} //何もないもしくはゲーム版の外なら終了。記録なし
        }
        return result
    }
    public func progressGame(_ y:Int,_ x:Int){
        if(cells[y][x].targetStones[player]!.isEmpty){return}//石を置くことができない
        undo?.beginUndoGrouping()
        undo?.registerUndo(withTarget: self) { me in
            withAnimation{
                me.undoTask(y, x)
            }
        }
        putStone(y, x, player)
        for targetStone in cells[y][x].targetStones[player]!{
            putStone(targetStone.y, targetStone.x, player)
        }
        undo?.endUndoGrouping()
//        checkAllCells()
        // おけるセルの調査
//        checkCanPutCells()
        countColors()
        if isGameFinished() {
            if blackCount == whiteCount {
                finishFlg = true
                showResult = true
                resultState = .draw
            } else if (blackCount > whiteCount) {
                winPlayer = .black
                finishFlg = true
                showResult = true
                resultState = .win
            } else {
                winPlayer = .white
                finishFlg = true
                showResult = true
                resultState = .win
            }
        } else {
            changePlayer()
            checkAllCells()
            checkCanMovecells()
        }
    }
    public func checkCanMovecells(){
        for y in 0..<8{
            for x in 0..<8{
                if cells[y][x].canMove == true{
                    return
                }
            }
        }
        // 移動可能セルがない場合はプレイヤー交代
        canNotMove.flg = true
        canNotMove.player = player
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.canNotMove.flg = false
            self.canNotMove.player = nil
        }
        changePlayer()
        checkAllCells()
        checkCanMovecells()
    }
    public func isGameFinished() -> Bool {
        // noneがある場合はゲーム続行
        for y in 0..<8{
            for x in 0..<8{
                if cells[y][x].stone == .none{
                    return false
                }
            }
        }
        return true
    }

    private func changePlayer(){
        var canChange:[RvStone:Bool] = [:]
        for stone in RvStone.colored{
            canChange[stone] = (cells.flatMap{$0}.map{$0.targetStones[stone]!.isEmpty}.filter{!$0}.count != 0)
        }
        player = (canChange[.opposedStone(player)]!) ? .opposedStone(player):player
    }
    
    private func countColors(){
        blackCount = 0
        whiteCount = 0
        for y in 0..<8{
            for x in 0..<8{
                if cells[y][x].stone == .black{
                    blackCount = blackCount + 1
                } else if cells[y][x].stone == .white{
                    whiteCount = whiteCount + 1
                }
            }
        }
    }
}

struct ReversiView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.undoManager) private var undo
    
    @State var reversiManager = ReversiManager()
    var body: some View {
        ZStack{
            // ゲーム本体
            VStack{
                VStack(spacing: 0.0){
                    ForEach(0..<8, id:\.self){y in
                        HStack(spacing: 0.0){
                            ForEach(0..<8, id:\.self){x in
                                reversiManager.cells[y][x]
                                    .onTapGesture {
                                        withAnimation{
                                            reversiManager.progressGame(y, x)
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .overlay{
            VStack{
                HStack(alignment: .top){
                    // 左上の表示
                    VStack{
                        Text("Turn")
                            .font(.headline)
                        Circle()
                            .fill(reversiManager.player.color)
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                    }
                    .padding()
                    .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 16.0))
                    .padding()
                    Spacer()
                    if reversiManager.canNotMove.flg {
                        Text("There is no place to put the stone.")
                            .foregroundStyle(.secondary)
                            .fontWeight(.bold)
                    }
                    
                    Spacer()
                    // 右上の表示
                    Menu{
                        Button {
                            undo?.removeAllActions()
                            reversiManager.setUp()
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
                    HStack{
                        VStack{
                            Text("Black")
                                .font(.headline)
                            Text("\(reversiManager.blackCount)")
                                .font(.system(.title, design: .rounded))
                                .fontWeight(.bold)
                                .contentTransition(.numericText(value: Double(reversiManager.blackCount)))
                        }
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.secondary.opacity(0.5))
                            .frame(width:2, height: 50)
                        VStack{
                            Text("White")
                                .font(.headline)
                            Text("\(reversiManager.whiteCount)")
                                .font(.system(.title, design: .rounded))
                                .fontWeight(.bold)
                                .contentTransition(.numericText(value: Double(reversiManager.whiteCount)))
                        }
                        
                    }
                    .padding()
                    .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 16.0))
                    .padding()
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
                        .disabled(reversiManager.finishFlg)
                    }
                    .padding()
                }
                
            }
        }

        .sheet(isPresented: $reversiManager.showResult) {
            ZStack{
                Button{
                    reversiManager.showResult = false
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
                    switch reversiManager.resultState {
                    case .win:
                        HStack{
                            Text("Win")
                            Image(systemName: "circle.fill")
                                .foregroundStyle(reversiManager.winPlayer!.color)
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
                        reversiManager.setUp()
                        reversiManager.showResult = false
                    } label: {
                        Label("Restart", systemImage: "arrow.trianglehead.counterclockwise")
                    }
                    // 終了ボタン
                    Button {
                        undo?.removeAllActions()
                        reversiManager.showResult = false
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Label("End game", systemImage: "xmark.circle")
                    }
                }
                .buttonStyle(.glassProminent)
            }
            .presentationDetents([.large, .medium, .height(200)]) // ⬅︎
        }

        .onAppear {
            reversiManager.undo = undo
        }
    }
}
#Preview {
    ReversiView()
}
