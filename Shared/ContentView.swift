//
//  ContentView.swift
//  Shared
//
//  Created by Luthfi Khan on 16/05/22.
//

import SwiftUI

struct ContentView: View {
    //Refactor isi dari LazyVGrid harus array
    let columns: [GridItem] = [GridItem(.flexible()),
                               GridItem(.flexible()),
                               GridItem(.flexible()),]
    
    //Buat check di buletannya dh ada yang jalan apa blom
    @State private var moves: [Move?] = Array(repeating: nil, count: 9)
    @State private var isGameBoardDisabled = false
    
    var body: some View {
        //buat bikin frame yang di bikin keren di semua size screen
        GeometryReader{ geometry in
            //Buat bikin grid
            VStack {
                Spacer()
                LazyVGrid(columns: columns){
                    ForEach(0..<9){ i in
                        ZStack{
                            Circle()
                                .foregroundColor(.purple).opacity(1)
                            //dibagi 3 karena boardnya 3x3
                                .frame(width: geometry.size.width/3 - 15,
                                       height: geometry.size.height/3 - 15)
                                .padding(.vertical, -60)
                            
                            Image(systemName: moves[i]? .indicator ?? "")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.white)
                        }
                        .onTapGesture {
                            //Player move
                            if isOccupied(in: moves, forIndex: i) { return }
                            moves[i] = Move(player: .human, boardIndex: i)
                            isGameBoardDisabled = true
                            
                            //check win
                            if checkWin(for: .human, in: moves){
                                print("Human Win")
                            }
                            if checkDraw(in: moves){
                                print("Draw")
                            }
                            
                            //Comp move
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                                let compPos = computerMove(in: moves)
                                moves[compPos] = Move(player: .computer, boardIndex: compPos)
                                isGameBoardDisabled = false
                                
                                //check win
                                if checkWin(for: .human, in: moves){
                                    print("Computer Win")
                                }
                                if checkDraw(in: moves){
                                    print("Draw")
                                }
                            }
                        }
                    }
                }
                Spacer()
            }
            .disabled(isGameBoardDisabled)
            .padding()
        }
    }
    
    func isOccupied(in moves: [Move?], forIndex index: Int) -> Bool {
        return moves.contains(where: {$0?.boardIndex == index})
    }
    
    func computerMove(in moves : [Move?]) -> Int{
        var movePos = Int.random(in: 0..<9)
        
        while isOccupied(in: moves, forIndex: movePos){
            movePos = Int.random(in: 0..<9)
        }
        
        return movePos
    }
    
    func checkWin(for player:Player, in moves: [Move?]) -> Bool{
        let winPattern: Set<Set<Int>> = [[0,1,2], [3,4,5], [6,7,8], [0,4,7], [2,4,6], [0,3,6], [1,4,7], [2,5,8]]
        
        //ini gunanya ngilangin nil
        //$0 semua element yang ada di index
        let playerMoves = moves.compactMap { $0 }.filter {$0.player == player}
        let playerPos = Set(playerMoves.map { $0.boardIndex })
        
        //check win condition
        for pattern in winPattern where pattern.isSubset(of: playerPos){ return true }
        
        return false
    }
    
    func checkDraw(in moves: [Move?]) -> Bool{
        return moves.compactMap{ $0 } .count == 9
    }
}

enum Player {
    case human, computer
}

struct Move{
    let player: Player
    let boardIndex: Int
    
    var indicator: String{
        return player == .human ? "xmark" : "circle"
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
