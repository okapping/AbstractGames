
//
//  xoGameView.swift
//  Test
//
//  Created by 岡山直也 on 2025/11/07.
//
import SwiftUI

enum Mark{
    
    case o,x
    
    //マークの集合(Set)。別に配列でもいい。
    static let signed:Set<Self> = [.o, .x]

    // マークのサイン（？）
    var sign: String {
        switch self {
//        case .none:
//            return " "
        case .o:
            return "circle"
        case .x:
            return "xmark"
        }
    }
    
    var color: Color {
        switch self {
        case .o:
            return .blue
        case .x:
            return .red
        }
    }
    static let opposedMark = {(mark:Self)->Self in
        switch mark {
        case .o:.x
        case .x:.o
//        case .none :fatalError()
        }
    }
}

struct xoGameCellVIew: View {
    // セルの表示のみ担当
    var mark: Mark? = nil
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(.primary.opacity(0.25))
            if let m = mark {
                Image(systemName: m.sign)
                    .resizable()
                    .padding()
                    .foregroundStyle(m.color)
                    .transition(.symbolEffect(.appear))
            }
        }
        .padding(16)
        .scaledToFit()
    }
}


@Observable class XogameManager{
    var player:Mark = .o

    var finishFlg: Bool = false
    var showResult: Bool = false
    var resultState: ResultState = .none

    // 初期化
    var cells:[[xoGameCellVIew]] = []
    init(){
        setUp()
    }
    
    public func setUp(){
        player = .o
        finishFlg = false
        showResult = false
        resultState = .none
        cells = [[xoGameCellVIew]](repeating: [xoGameCellVIew](repeating: xoGameCellVIew(), count: 3), count: 3)
    }

    private func checkMark(_ y:Int,_ x:Int,_ mark:Mark){
        cells[y][x].mark = mark
    }
    
    private func checkVictory() -> Bool {
        // 縦横斜めで揃っているところがあるか確認する
        // 横の確認
        for y in 0..<3 {
            if cells[y].allSatisfy({ $0.mark == player }) {
                return true
            }
        }
        // 縦の確認
        for x in 0..<3 {
            if (0..<3).allSatisfy({ cells[$0][x].mark == player }) {
                return true
            }
        }
        
        // 斜め（左上から右下）の確認
        if (0..<3).allSatisfy({ cells[$0][$0].mark == player }) {
            return true
        }
        // 斜め（ 右上から左下）の確認
        if (0..<3).allSatisfy({ cells[$0][3 - 1 - $0].mark ==  player }) {
            return true
        }
        
        return false

    }
    
    public func checkDraw() -> Bool {
        for y in 0..<3 {
            for x in 0..<3 {
                if cells[y][x].mark == .none {
                    return false
                }
            }
        }
        return true
    }

    public func progressGame(_ y:Int,_ x:Int){
        //石を置くことができない
        if(
            cells[y][x].mark != .none ||
            finishFlg == true
        ){return}
        
        // チェックをつける
        checkMark(y, x, player)
        
        // 決着がついているか
        if checkVictory(){
            // 決着
            finishFlg = true
            showResult = true
            resultState = .win
            return
        }
        // 置く場所が存在するか確認
        if checkDraw(){
            finishFlg = true
            showResult = true
            resultState = .draw
            return
        }
        // プレイヤーの交代
        changePlayer()
    }
    private func changePlayer(){
        player = .opposedMark(player)
    }

    
}

struct XoGameView: View {
    @Environment(\.presentationMode) var presentationMode
    @State var xoGameManager = XogameManager()
    var body: some View {
        ZStack{
            // 右上のメニュー
//            Menu{
//                Button {
////                    startGridAnimation()
//                    xoGameManager.setUp()
//                } label: {
//                    Label("Restart", systemImage: "arrow.trianglehead.counterclockwise")
//                }
//                .buttonStyle(.bordered)
//                // 閉じるボタン
//                Button {
//                    presentationMode.wrappedValue.dismiss()
//                } label: {
//                    Label("Finish", systemImage: "xmark.circle")
//                }
//                .buttonStyle(.bordered)
//            } label: {
//                Image(systemName: "menucard")
//                //                Label("メニュー", systemImage: "menucard")
//            }
//            .gameMenuButtonStyle()
//            
//            // 左上のターン表示
//            VStack{
//                Text("Turn")
//                    .font(.headline)
//                Image(systemName: xoGameManager.player.sign)
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: 30, height: 30)
//                    .foregroundStyle(xoGameManager.player.color)
//                    .contentTransition(.symbolEffect(.replace.offUp))
//            }
//            .padding()
//            .background(Color.secondary.opacity(0.25))
//            .clipShape(RoundedRectangle(cornerRadius: 10))
//            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

            VStack{
//                HStack{
                    // 決着後の表示
//                    if xoGameManager.winFlg {
//                        HStack{
//                            Text("Win")
//                            Image(systemName: xoGameManager.player.sign)
//                                .resizable()
//                                .scaledToFit()
//                                .frame(width: 30, height: 30)
//                                .foregroundStyle(xoGameManager.player.color)
//                        }
//                        .font(.title)
//                        .fontWeight(.bold)
//                        .padding()
//                        .transition(.scale)
//                    }
//                    // 引き分け表示
//                    if xoGameManager.drawFlg{
//                        Text("Draw")
//                            .font(.title)
//                            .fontWeight(.bold)
//                            .padding()
//                            .transition(.scale)
//                    }
//                    if xoGameManager.winFlg || xoGameManager.drawFlg{
//                        Button {
////                            startGridAnimation()
//                            xoGameManager.setUp()
//                        } label: {
//                            Label("Restart", systemImage: "arrow.trianglehead.counterclockwise")
//                        }
//                        .buttonStyle(.bordered)
//                        .transition(.scale)
//                        // 閉じるボタン
//                        Button {
//                            presentationMode.wrappedValue.dismiss()
//                        } label: {
//                            Label("Finish", systemImage: "xmark.circle")
//                        }
//                        .buttonStyle(.bordered)
//                        .transition(.scale)
//                    }
//                }
//                .frame(height: 30)
//                .frame(maxWidth: .infinity)

                // マスの表示
                ZStack{
                    VStack {
                        ForEach(0..<3, id:\.self){y in
                            HStack{
                                ForEach(0..<3, id:\.self){x in
                                    xoGameManager.cells[y][x]
                                        .onTapGesture {
                                            withAnimation{
                                                xoGameManager.progressGame(y, x)
                                            }
                                        }
                                }
                            }
                        }
                    }
                    .padding()
                    // 格子状の背景
                    ZStack{
                        //                        Rectangle()
                        //                            .scaledToFit()
                        VStack(alignment: .leading){
                            //                            Spacer()
                            Rectangle()
                                .frame(maxHeight: .infinity)
                                .foregroundStyle(.clear)
                            RoundedRectangle(cornerRadius: 20)
                                .frame(maxHeight: 10)
//                                .frame(width: gridAnimation[0] ? .infinity : 0, height: 10)
                            Rectangle()
                                .frame(maxHeight: .infinity)
                                .foregroundStyle(.clear)
                            RoundedRectangle(cornerRadius: 20)
                                .frame(maxHeight: 10)
//                                .frame(width: gridAnimation[1] ? .infinity : 0, height: 10)
                            Rectangle()
                                .frame(maxHeight: .infinity)
                                .foregroundStyle(.clear)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        //                        .background(.gray)
                        HStack(alignment: .top){
                            Rectangle()
                                .frame(maxWidth: .infinity)
                                .foregroundStyle(.clear)
                            RoundedRectangle(cornerRadius: 20)
                                .frame(maxWidth: 10)
//                                .frame(width: 10, height: gridAnimation[2] ? .infinity : 0)
                            Rectangle()
                                .frame(maxWidth: .infinity)
                                .foregroundStyle(.clear)
                            RoundedRectangle(cornerRadius: 20)
                                .frame(maxWidth: 10)
//                                .frame(width: 10, height: gridAnimation[3] ? .infinity : 0)
                            Rectangle()
                                .frame(maxWidth: .infinity)
                                .foregroundStyle(.clear)
                        }
                    }
                    .scaledToFit()
                    //                    .frame(maxWidth: .infinity)
                    .padding()
                }

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
                        Image(systemName: xoGameManager.player.sign)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .foregroundStyle(xoGameManager.player.color)
                            .contentTransition(.symbolEffect(.replace.offUp))
                    }
                    .padding()
                    .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 16.0))
                    .padding()
                    Spacer()
                    // 右上の表示
                    Menu{
                        Button {
//                            undo?.removeAllActions()
                            xoGameManager.setUp()
                        } label: {
                            Label("Restart", systemImage: "arrow.trianglehead.counterclockwise")
                        }
                        // 閉じるボタン
                        Button {
//                            undo?.removeAllActions()
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
//                    GlassEffectContainer(spacing: 40.0) {
//                        HStack() {
//                            Button{
//                                withAnimation{
//                                    undo?.undo()
//                                }
//                            } label: {
//                                Image(systemName: "arrow.uturn.backward")
//                                    .padding()
//                            }
//                            .disabled(undo?.canUndo == false)
//                            .glassEffect(.regular.interactive())
//                            Button{
//                                withAnimation{
//                                    undo?.redo()
//                                }
//                            } label: {
//                                Image(systemName: "arrow.uturn.forward")
//                                    .padding()
//                            }
//                            .disabled(undo?.canRedo == false)
//                            .glassEffect(.regular.interactive())
//                        }
//                        .disabled(connectFourManager.finishFlg)
//                    }
//                    .padding()
                }
                
            }
        }

        
        .sheet(isPresented: $xoGameManager.showResult) {
            ZStack{
                Button{
                    xoGameManager.showResult = false
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
                    switch xoGameManager.resultState {
                    case .win:
                        HStack{
                            Text("Win")
                            Image(systemName: xoGameManager.player.sign)
                                .foregroundStyle(xoGameManager.player.color)
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
//                        undo?.removeAllActions()
                        xoGameManager.setUp()
                        xoGameManager.showResult = false
                    } label: {
                        Label("Restart", systemImage: "arrow.trianglehead.counterclockwise")
                    }
                    // 終了ボタン
                    Button {
//                        undo?.removeAllActions()
                        xoGameManager.showResult = false
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Label("End game", systemImage: "xmark.circle")
                    }
                }
                .buttonStyle(.glassProminent)
            }
            .presentationDetents([.large, .medium, .height(200)]) // ⬅︎
        }

        .onAppear{}
    }
}

#Preview{
    XoGameView()
}
