//
//  Expectimax.swift
//  ChatGPT5_2048
//
//  Created by Tatiana Kornilova on 16/10/2025.
//
import SwiftUI

 final class Expectimax: Sendable {
 //   struct Expectimax {
    /// Выбор оптимального направления с помощью Expectimax ( асинхронный )
  func bestDirectionExpectimaxAsync (game: Game) async -> Direction? {
        let depth  = 5
        var bestDir: Direction?
        var bestScore = -Double.infinity
        let emptyCells = game.emptyPositions().count // emptyPositions(tiles: game.tiles).count
        
        var newGame = Game(copying: game)
        newGame.checkGameOver()
        if newGame.gameOver { return nil }
        
        await withTaskGroup (of: (Direction, Double)?.self) { group in
            for dir in Direction.allCases {
                group.addTask { [self] in
                    var state = Game (tiles: game.tiles)
                    let moved = state.slide(direction: dir)
                    if !moved { return nil }
                    
                    let score = await expectimaxAsync(node: state, depth: emptyCells >= 4 ? (depth - 1) : depth, isChanceNode: true)
                    return (dir, score)
                }
                
            }
            // Соберите результаты и найдите лучшее направление
            for await result in group {
                if let (dir, score) = result, score > bestScore {
                    bestScore = score
                    bestDir = dir
                }
            }
            
        }
        return bestDir
    }
    
    /// Expectimax recursive function.
    /// - Parameters:
    ///   - node: копия состояния игры
    ///   - depth: оставшаяся глубина поиска
    ///   - isChanceNode: если true → узел случая (появление плитки 2/4),
    ///                   если false → ход игрока (max)
    /// - Returns: эвристическая оценка (чем больше, тем лучше для игрока)
   func expectimaxAsync(node: Game, depth: Int, isChanceNode: Bool) async -> Double {
        // терминальные условия
        
        var newGame = Game(copying: node)
        newGame.checkGameOver()
        if depth <= 0 || newGame.gameOver {
            return evaluateBoard(node)
        }
        
        if isChanceNode {
            // Узел "случай": появляются плитки 2 или 4
            let empties = node.emptyPositions()
            if empties.isEmpty {
                return await expectimaxAsync(node: node, depth: depth - 1, isChanceNode: false)
            }
            
            let p2 = 0.9
            let p4 = 0.1
            let probPerEmpty = 1.0 / Double(empties.count)
            
            
            // Run all spawns in parallel
            return await withTaskGroup { group in
                for pos in empties {
                    group.addTask {
                        // вариант со значением 2
                        var spawn2 = Game (tiles: node.tiles)
                        let tile2 = Tile(value: 2, position: Position(row: pos.row, col: pos.col))
                        spawn2.tiles.append(tile2)
                        let val2 = await self.expectimaxAsync(node: spawn2, depth: depth - 1, isChanceNode: false)
                        return p2 * probPerEmpty * val2
                    }
                    
                    group.addTask {
                        // вариант со значением 4
                        var spawn4 = Game (tiles: node.tiles)
                        let tile4 = Tile(value: 4, position: Position(row: pos.row, col: pos.col))
                        spawn4.tiles.append(tile4)
                        let val4 = await self.expectimaxAsync(node: spawn4, depth: depth - 1, isChanceNode: false)
                        return p4 * probPerEmpty * val4
                    }
                }
                // Собираем результаты
                var total: Double = 0.0
                for await partial in group {
                    total += partial
                }
                return total
            }
        } else {
            // Узел "игрок": выбираем лучший ход (max)
            var best = -Double.infinity
            
            return await withTaskGroup { group in
                for dir in Direction.allCases {
                    group.addTask { [self] in
                        var copy = Game (tiles: node.tiles)
                        let moved = copy.slide(direction: dir) // 👈 используем slideMerge
                        if !moved { return -Double.infinity/*continue*/} // если ход невозможен, пропускаем
                        
                        return await expectimaxAsync(node: copy, depth: depth - 1, isChanceNode: true)
                    }
                }
                
                for await result in group {
                    best  = max( best , result)
                }
                return  best
            }
        }
    }
    
    /// Выбор оптимального направления с помощью Expectimax ( синхронный)
        func bestDirectionExpectimax(game: Game) -> Direction? {
            let depth  = 4
            var bestDir: Direction?
            var bestScore = -Double.infinity
            let emptyCells = game.emptyPositions().count
            
            var newGame = Game(copying: game)
            newGame.checkGameOver()
            if newGame.gameOver { return nil }
            

            for dir in Direction.allCases {
                var state = Game (tiles: game.tiles)
                let moved = state.slide(direction: dir)
                if !moved { continue }

                let score = expectimax(node: state, depth: emptyCells >= 4 ? (depth - 1) : depth, isChanceNode: true)
                if score > bestScore {
                    bestScore = score
                    bestDir = dir
                }
            }
            return bestDir
        }
    
    /// Expectimax recursive function.
      /// - Parameters:
      ///   - node: копия состояния игры
      ///   - depth: оставшаяся глубина поиска
      ///   - isChanceNode: если true → узел случая (появление плитки 2/4),
      ///                   если false → ход игрока (max)
      /// - Returns: эвристическая оценка (чем больше, тем лучше для игрока)
      func expectimax(node: Game, depth: Int, isChanceNode: Bool) -> Double {
          // терминальные условия
          
          
          var newGame = Game(copying: node)
          newGame.checkGameOver()
          if depth <= 0 || newGame.gameOver {
              return evaluateBoard(node)
          }

          if isChanceNode {
              // Узел "случай": появляются плитки 2 или 4
              let empties = node.emptyPositions()
              if empties.isEmpty {
                  return expectimax(node: node, depth: depth - 1, isChanceNode: false)
              }

              let p2 = 0.9
              let p4 = 0.1
              var expected: Double = 0.0

              for pos in empties {
                  // вариант со спавном 2
                  var spawn2 = Game (tiles: node.tiles)
                  let tile2 = Tile(value: 2, position: Position(row: pos.row, col: pos.col))
                  spawn2.tiles.append(tile2)
                  expected += p2 * (1.0 / Double(empties.count)) *
                              expectimax(node: spawn2, depth: depth - 1, isChanceNode: false)

                  // вариант со спавном 4
                  var spawn4 = Game (tiles: node.tiles)
                  let tile4 = Tile(value: 4, position: Position(row: pos.row, col: pos.col))
                  spawn4.tiles.append(tile4)
                  expected += p4 * (1.0 / Double(empties.count)) *
                              expectimax(node: spawn4, depth: depth - 1, isChanceNode: false)
              }
              return expected

          } else {
              // Узел "игрок": выбираем лучший ход (max)
              var best = -Double.infinity

              for dir in Direction.allCases {
                  var copy = Game (tiles: node.tiles)
                  let moved = copy.slide(direction: dir) // 👈 используем slideMerge
                  if !moved { continue } // если ход невозможен, пропускаем
                  let val = expectimax(node: copy, depth: depth - 1, isChanceNode: true)
                  if val > best { best = val }
              }
              return best
          }
      }
    
    // MARK: - Heuristic evaluation
    
    /// Evaluate board heuristically. Combine factors (empty cells, monotonicity, smoothness, max tile corner)
    private func evaluateBoard(_ state: Game )-> Double {
        let grid = state.tilesToGrid()
        let empties = state.emptyPositions().count
       
       // weights (tunable)
        let wEmpty = 11.7// 11.7
         let wMonotonicity =  1.1 // 1.0
         let wSmoothness = 0.0 //-0.1
         let wMaxWeight = 1.0 // 1.0
         let wScore = 0.0
    
        let mono = monotonicity(grid)
        let smooth = smoothness(state)
        let currentScore = Double(state.score)
        let maxTile = Double(state.tiles.map { $0.value }.max() ?? 0)
        
       return wEmpty * Double(empties)
        + wMonotonicity * mono
        + wSmoothness * smooth
        + wMaxWeight * maxTile
        + wScore * currentScore
    }
    
    // MARK: - monotonicity
        func monotonicity(_ grid: [[Int]]) -> Double {
            var totals: [Double] = [0, 0, 0, 0]
            
            for i in 0..<4 {
                var current = 0
                var next = current + 1
                while next < 4 {
                    while next < 4 && grid[i][next] == 0 {
                        next += 1
                    }
                    if next >= 4 {
                        next -= 1
                    }
                    let currentValue = grid[i][current] != 0 ? log2(Double(grid[i][current])) : 0
                    let nextValue = grid[i][next] != 0 ? log2(Double(grid[i][next])) : 0
                    if currentValue > nextValue {
                        totals[0] += nextValue - currentValue
                    } else if nextValue > currentValue {
                        totals[1] += currentValue - nextValue
                    }
                    current = next
                    next += 1
                }
            }
            
            for i in 0..<4 {
                var current = 0
                var next = current + 1
                while next < 4 {
                    while next < 4 && grid[next][i] == 0 {
                        next += 1
                    }
                    if next >= 4 {
                        next -= 1
                    }
                    let currentValue = grid[current][i] != 0 ? log2(Double(grid[current][i])) : 0
                    let nextValue = grid[next][i] != 0 ? log2(Double(grid[next][i])) : 0
                    if currentValue > nextValue {
                        totals[2] += nextValue - currentValue
                    } else if nextValue > currentValue {
                        totals[3] += currentValue - nextValue
                    }
                    current = next
                    next += 1
                }
            }
            return max(totals[0], totals[1]) + max(totals[2], totals[3])
        }
    
    /// Smoothness: penalize large differences between neighboring tiles
    private func smoothness(_ state: Game) -> Double {
        var score = 0.0
        let size = 4
        for t in state.tiles {
            let v = Double(t.value)
            let neighbors = [
                (t.position.row + 1, t.position.col),
                (t.position.row - 1, t.position.col),
                (t.position.row, t.position.col + 1),
                (t.position.row, t.position.col - 1)
            ]
            for (r, c) in neighbors {
                if r >= 0 && r < size && c >= 0 && c < size {
                    if let nt = state.tiles.first(where: { $0.position.row == r && $0.position.col == c }) {
                        let diff = abs(log(v + 1) - log(Double(nt.value + 1)))
                        score -= diff
                    }
                }
            }
        }
        return score
    }
}
