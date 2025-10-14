//
//  GameView.swift
//  ChatGPT5_2048
//
//  Created by Tatiana Kornilova on 21.08.2025.
//
import SwiftUI

struct GameView: View {
    @State var viewModel = GameViewModel()
    @State private var showHintDirection = false
    @State private var aiEnabled = false
    @State private var cachedHint: Direction?
    @State private var aiMode: AIMode = .expectimax   // 👈 режим ИИ
    @State private var timer = Timer.publish(every: 0.65, on: .main, in: .common).autoconnect()

    let gridSize: CGFloat = 80  // tile size
    let spacing: CGFloat = 8
    var boardSize: CGFloat { 4 * gridSize + 3 * spacing }

    var body: some View {
        VStack (spacing: 2 * spacing){
                Text("Score: \(viewModel.score)")
                    .font(.title)
                
                ZStack {
                    // Grid background (gray cells)
                    VStack(spacing: spacing) {
                        ForEach(0..<4) { _ in
                            HStack(spacing: spacing) {
                                ForEach(0..<4) { _ in
                                    RoundedRectangle(cornerRadius: spacing)
                                        .fill(Color.colorEmpty)
                                        .frame(width: gridSize, height: gridSize)
                                }
                            }
                        }
                    }
                    
                    // Animated tiles
                    ForEach(viewModel.tiles) { tile in
                        TileView(tile: tile, size: gridSize, spacing: spacing) {
                            // Переустановка флага merged только после анимацииo
                            if let index = viewModel.tiles.firstIndex(where: { $0.id == tile.id }) {
                                viewModel.tiles[index].merged = false
                            }
                        } 
                    }
                    
                    // ✅ AI Arrow in the center
                    if showHintDirection, let dir = cachedHint, !aiEnabled {
                        ArrowMorphView(direction: dir)
                                .frame(width: 125, height: 125)
                    }
                } // ZStack
                .frame(width: boardSize, height: boardSize)// 👈 fixed frame
                .gesture(
                    DragGesture()
                        .onEnded { value in
                            let horizontal = value.translation.width
                            let vertical = value.translation.height
                            if abs(horizontal) > abs(vertical) {
                                if horizontal > 0 {
                                    withAnimation {
                                        viewModel.move(direction: .right)
                                    }
                                } else {
                                    withAnimation{
                                        viewModel.move(direction: .left)
                                    }
                                }
                            } else {
                                if vertical > 0 {
                                    withAnimation {
                                        viewModel.move(direction: .down)
                                    }
                                } else {
                                    withAnimation{
                                        viewModel.move(direction: .up)
                                    }
                                }
                            }
                        }
                )
                HStack {
                    VStack (alignment: .leading) {
                        Button("Restart") {
                            aiEnabled = false
                            showHintDirection = false
                            viewModel.startGame()
                        }
                        .padding(.horizontal,8)
                        
                        // Переключатель режима ИИ
                        Picker("", selection: $aiMode) {
                            Text("Expectimax").tag(AIMode.expectimax).font(.headline)
                            Text("Monte Carlo").tag(AIMode.monteCarlo).font(.headline)
                        }
                        .pickerStyle(.menu)
                    }
                   
                    Spacer()
                    
                    VStack (alignment: .leading){
                        CheckBoxView(isChecked: $showHintDirection, title: "Hint Direction")
                        CheckBoxView(isChecked: $aiEnabled, title: "AI")
                            .onChange(of: aiEnabled) { _ , newValue in
                                if newValue { showHintDirection = false}
                            }
                    }
                }
                
                    Text(viewModel.gameOver ? "Game is Over" : " ")
                        .font(.largeTitle)
                        .foregroundColor(.red)
            } // VStack
            .padding()
        //-----------
            .onChange(of: showHintDirection) { oldValue,newValue in
                if newValue {
                    Task{
                        if let hint =  viewModel.bestDirectionExpectimax() {
                            await MainActor.run { cachedHint = hint }
                        }
                    }
                } else {
                    cachedHint = nil
                }
            }
            .onChange(of: viewModel.tiles) { oldValue, newValue in
                let oldValues = oldValue.map {$0.value}
                let newValues = newValue.map {$0.value}
                let oldPositions = oldValue.map {$0.position}
                let newPositions = newValue.map {$0.position}
                
                if showHintDirection {
                    if (oldValues  != newValues || oldPositions != newPositions) {
                            Task{
                                if let hint =  viewModel.bestDirectionExpectimax() {
                                    await MainActor.run {
                                        withAnimation {
                                            cachedHint = hint
                                        }
                                    }
                                } else  {
                                    print ("Game over")
                                    showHintDirection = false
                                }
                            } // Task
                    }
                }
            }
        //-----------
           .onReceive(timer) { _ in
                // Uncomment for auto-play
                if aiEnabled && !viewModel.gameOver {
                        switch aiMode {
                        case .expectimax: withAnimation  {viewModel.playAIExpectimaxAsync()}
                        case .monteCarlo: withAnimation  { viewModel.playAITurn2() }
                            //  viewModel.playAITurn()
                            //   viewModel.playAITurn2()
                            //  viewModel.playAIExpectimax()
                           // viewModel.playAIExpectimaxAsync()
                        }
                }
            }
    } // body
}

// MARK: - Режимы ИИ
enum AIMode {
    case monteCarlo
    case expectimax
}
   
    

#Preview {
    GameView()
}

