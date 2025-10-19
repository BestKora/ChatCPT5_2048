//
//  GameViewModel.swift
//  ChatGPT5_2048
//
//  Created by Tatiana Kornilova on 21.09.2025.
//
import SwiftUI

@Observable  @MainActor
class GameViewModel {
             
  //  var tiles: [Tile] = []     // массив плиток
  //  var score = 0              // текущий счёт
  //  var gameOver = false       // флаг окончания игры
    
    private var game = Game ()
    let expectimax = Expectimax()
    
    init() {
        self.game = Game()
    }
    
    var tiles: [Tile] {
        game.tiles
    }
    
    var score: Int {
        game.score
    }
    var gameOver: Bool {
        game.gameOver
    }
    
    var optimalDirection: Direction? {
        MonteCarlo.bestDirectionSync(tiles: tiles) //expectimax.bestDirectionExpectimax(game: game)
    }
    // MARK: Intents
    
    func startGame() {
        game.startGame()
    }
    
    func move(direction: Direction) {
        game.move(direction: direction)
    }
    
    func mergedTileFalse (tile: Tile) {
        // Переустановка флага merged только после анимацииo
       if let index = game.tiles.firstIndex(where: { $0.id == tile.id }) {
            game.tiles[index].merged = false
        }
    }
    
    /// Вариант для автопилота Монте Карло асинхронный вызов)
     func playAITurn2() {
        Task {
           if let dir = await MonteCarlo.bestDirection(tiles: tiles) {
              //  await MainActor.run {
                game.move(direction: dir)
             //  }
            }
        }
    }
    
    /// Вариант для автопилота  Expectimax  (асинхронный вызов)
    func playAIExpectimaxAsync () {
        Task {
            if let dir = await expectimax.bestDirectionExpectimaxAsync (game: game) {
               // await MainActor.run {
                game.move(direction: dir)
             //   }
            } else {
                game.checkGameOver()
            }
        }
    }
}
