//
//  GameViewModel.swift
//  ChatGPT5_2048
//
//  Created by Tatiana Kornilova on 21.09.2025.
//
import SwiftUI
import Playgrounds

#Playground("move") {
    var moved = false
    let row = [/*Tile(value: 2, position: Position(row: 0, col: 0)), */Tile(value: 2, position: Position(row: 0, col: 1)), Tile(value: 4, position: Position(row: 0, col: 2)), Tile(value: 4, position: Position(row: 0, col: 3))]
    // Функция сжатия линии (строки или колонки) и слияния плиток
    func collapse(_ line: [Tile]) -> [Tile] {
        var newLine: [Tile] = []
        var skip = false
        for (i, tile) in line.enumerated() {
            if skip {
                skip = false
                continue
            }
            // Если две подряд плитки равны — объединяем их
            if i < line.count - 1 && tile.value == line[i+1].value {
                var mergedTile =  line [i + 1]
                mergedTile.value *= 2
                mergedTile.merged = true
                newLine.append(mergedTile)
                skip = true // пропускаем следующую
            } else {
                newLine.append(tile)
            }
        }
        return newLine
    }
    
    let collapsed = collapse (row)
    for (c, tile) in collapsed.enumerated() {
        if tile.position.col != c  /*|| tile.value != row[c].value */ { moved = true }
        print ("---- tileCol = \(tile.position.col)  col = \(c)")
    }
    print ("moved = \(moved)")
    print ("row = \(row)")
    print ("collapsed = \(collapsed)")
}

// Возможные направления движения
enum Direction : CaseIterable {
    case left, right, up, down
}

// Модель плитки
struct Tile: Identifiable, Equatable {
    let id  = UUID ()          // уникальный идентификатор
    var value: Int             // значение плитки (2, 4, 8, ...)
    var position: Position     // её позиция на поле
    var merged: Bool = false   // была ли плитка объединена в этом ходе
    
    // Manually confirm Equable
    static func == (lhs: Tile, rhs: Tile) -> Bool {
        return lhs.value == rhs.value  && lhs.position == rhs.position
    
     }
}

// Позиция плитки на игровом поле (строка и колонка)
struct Position: Equatable {
    var row: Int
    var col: Int
}

// Основная модель игры
@Observable
class GameViewModel {
    let size = 4               // размер поля (4x4)
    var tiles: [Tile] = []     // массив плиток
    var score = 0              // текущий счёт
    var gameOver = false       // флаг окончания игры
    
    init() {
        startGame()
    }
    
    /// Инициализатор для глубокого копирования состояния (нужен для симуляций AI)
    init(copying other: GameViewModel) {
        self.tiles = other.tiles
        self.score = other.score
        self.gameOver = other.gameOver
    }
    
    // Инициализатор для глубокого копирования состояния (нужен для симуляций AI)
    init(tiles: [Tile]) {
        self.tiles = tiles
        self.score = 0
        self.gameOver = false
    }
    
    /// Начало новой игры
    func startGame() {
        gameOver = false
        score = 0
        tiles.removeAll()
        
        // В начале появляются 2 случайные плитки
        addRandomTile()
        addRandomTile()
    }
    
    /// Добавление новой случайной плитки (2 или 4) в пустую ячейку
    func addRandomTile() {
        // Находим все пустые позиции
        let emptyPositions = (0..<size).flatMap { r in
            (0..<size).compactMap { c in
                tiles.contains(where: { $0.position.row == r && $0.position.col == c }) ? nil : Position (row:r, col:c)
            }
        }
        
        // Если нет пустых — выходим
        guard let pos = emptyPositions.randomElement() else { return }
        
        // Новая плитка — 2 или 4
        let newValue = Bool.random() ? 2 : 4
        let newTile = Tile(value: newValue, position: pos)
        tiles.append(newTile)
    }
    
    // Первоначальный вариант функции move (direction: Direction)
    /// Выполнение хода в выбранном направлении + добавление случайной новой плитки
 /*   func move(direction: Direction) {
        var moved = false   // флаг, изменилось ли поле после хода
        
        // Функция сжатия линии (строки или колонки) и слияния плиток
        func collapse(_ line: [Tile]) -> [Tile] {
            var newLine: [Tile] = []
            var skip = false
            for (i, tile) in line.enumerated() {
                if skip {
                    skip = false
                    continue
                }
                // Если две подряд плитки равны — объединяем их
                if i < line.count - 1 && tile.value == line[i+1].value {
                    var mergedTile =  line [i + 1]
                    mergedTile.value *= 2
                    mergedTile.merged = true
                    score += mergedTile.value
                    newLine.append(mergedTile)
                    skip = true // пропускаем следующую
                } else {
                    newLine.append(tile)
                }
            }
            return newLine
        }
        
        var newTiles: [Tile] = []
        
        switch direction {
        case .left:
            // Двигаем все строки влево
            for r in 0..<size {
                let row = tiles.filter { $0.position.row == r }.sorted { $0.position.col < $1.position.col }
                let collapsed = collapse(row)
                for (c, tile) in collapsed.enumerated() {
                    if tile.position.col != c  || tile.value != row[c].value { moved = true }
                    var updated = tile
                    updated.position.row = r
                    updated.position.col = c
                    newTiles.append(updated)
                }
            }
        case .right:
            // Двигаем все строки вправо
            for r in 0..<size {
                let row = tiles.filter { $0.position.row == r }.sorted { $0.position.col > $1.position.col }
                let collapsed = collapse(row)
                for (i, tile) in collapsed.enumerated() {
                    let c = size - 1 - i
                    if tile.position.col != c   || tile.value != row[i].value { moved = true }
                    var updated = tile
                    updated.position.row = r
                    updated.position.col = c
                    newTiles.append(updated)
                }
            }
            
        case .up:
            // Двигаем все колонки вверх
            for c in 0..<size {
                let col = tiles.filter { $0.position.col == c }.sorted { $0.position.row < $1.position.row }
                let collapsed = collapse(col)
                for (r, tile) in collapsed.enumerated() {
                    if tile.position.row != r || tile.value != col[min(r, col.count-1)].value  { moved = true }
                    var updated = tile
                    updated.position.row = r
                    updated.position.col = c
                    newTiles.append(updated)
                }
            }
        case .down:
            // Двигаем все колонки вниз
            for c in 0..<size {
                let col = tiles.filter { $0.position.col == c }.sorted { $0.position.row > $1.position.row }
                let collapsed = collapse(col)
                for (i, tile) in collapsed.enumerated() {
                    let r = size - 1 - i
                    if tile.position.row != r || tile.value != col[min(i, col.count-1)].value { moved = true }
                    var updated = tile
                    updated.position.row = r
                    updated.position.col = c
                    newTiles.append(updated)
                }
            }
        }
        
        // Если было движение — обновляем поле
        if moved {
            tiles = newTiles
            addRandomTile()
            checkGameOver()
        }
    } */
    
    /// Проверка, закончена ли игра
    private func checkGameOver() {
        // Есть ли пустая клетка?
        let emptyExists = (0..<size).contains { r in
            (0..<size).contains { c in
                !tiles.contains { $0.position.row == r && $0.position.col == c }
            }
        }
        if emptyExists { return }
        
        // Проверяем соседей — если есть равные, то ещё можно ходить
        for r in 0..<size {
            for c in 0..<size {
                let value = tiles.first { $0.position.row == r && $0.position.col == c }!.value
                let neighbors = [(r+1,c),(r-1,c),(r,c+1),(r,c-1)]
                for (nr, nc) in neighbors where nr >= 0 && nr < size && nc >= 0 && nc < size {
                    if tiles.first(where: { $0.position.row == nr && $0.position.col == nc })?.value == value {
                        return
                    }
                }
            }
        }
        // Если ни пустых клеток, ни возможных объединений нет — игра окончена
        gameOver = true
    }
    //-------- Разделение первоначальной функции move (direction: Direction)
    /// Выполнение хода в выбранном направлении БЕЗ  добавление случайной новой плитки
 
// Variant 1
    /// Выполняет сдвиг и объединение плиток в заданном направлении.
    /// Возвращает `true`, если хотя бы одна плитка была перемещена или объединена.
    func slide(direction: Direction) -> Bool {
        var moved = false   // флаг, показывающий, изменилось ли поле после хода
        var newTiles: [Tile] = []  // новый набор плиток после сдвига

        // MARK: - Функция сжатия одной линии (строки или столбца)
        /// Сжимает линию (объединяет одинаковые соседние плитки).
        /// Возвращает новую линию и флаг, были ли слияния.
        func collapse(_ line: [Tile]) -> ([Tile], Bool) {
            var newLine: [Tile] = []   // результирующая линия после слияния
            var skip = false           // пропуск следующей плитки, если она уже была объединена
            var merged = false         // флаг — происходило ли слияние в этой линии
            
            for (i, tile) in line.enumerated() {
                if skip {
                    // Пропускаем плитку, если предыдущая уже была объединена с ней
                    skip = false
                    continue
                }
                // Проверяем две соседние плитки: если равны — объединяем
                if i < line.count - 1 && tile.value == line[i + 1].value {
                    var mergedTile = line[i + 1]
                    mergedTile.value *= 2          // увеличиваем значение в 2 раза
                    mergedTile.merged = true       // помечаем как объединённую
                    score += mergedTile.value      // добавляем очки за слияние
                    newLine.append(mergedTile)     // добавляем новую плитку в линию
                    skip = true                    // пропускаем следующую плитку
                    merged = true                  // отмечаем, что произошло слияние
                } else {
                    // Если не равны — просто добавляем плитку как есть
                    newLine.append(tile)
                }
            }
            return (newLine, merged)
        }

        // MARK: - Сдвиг плиток в выбранном направлении
        switch direction {
        case .left:
            // Сдвигаем все строки влево
            for r in 0..<size {
                // Получаем все плитки строки, сортируем по возрастанию колонки
                let row = tiles.filter { $0.position.row == r }
                               .sorted { $0.position.col < $1.position.col }
                // Сжимаем строку (объединяем одинаковые плитки)
                let (collapsed, merged) = collapse(row)
                if merged { moved = true }
                // Переставляем плитки в новые позиции слева направо
                for (c, tile) in collapsed.enumerated() {
                    if tile.position.col != c { moved = true }
                    var updated = tile
                    updated.position = Position(row: r, col: c)
                    newTiles.append(updated)
                }
            }

        case .right:
            // Сдвигаем все строки вправо
            for r in 0..<size {
                // Плитки сортируются справа налево
                let row = tiles.filter { $0.position.row == r }
                               .sorted { $0.position.col > $1.position.col }
                let (collapsed, merged) = collapse(row)
                if merged { moved = true }
                // Размещаем объединённые плитки справа налево
                for (i, tile) in collapsed.enumerated() {
                    let c = size - 1 - i
                    if tile.position.col != c { moved = true }
                    var updated = tile
                    updated.position = Position(row: r, col: c)
                    newTiles.append(updated)
                }
            }

        case .up:
            // Сдвигаем все колонки вверх
            for c in 0..<size {
                let col = tiles.filter { $0.position.col == c }
                               .sorted { $0.position.row < $1.position.row }
                let (collapsed, merged) = collapse(col)
                if merged { moved = true }
                // Переставляем плитки сверху вниз
                for (r, tile) in collapsed.enumerated() {
                    if tile.position.row != r { moved = true }
                    var updated = tile
                    updated.position = Position(row: r, col: c)
                    newTiles.append(updated)
                }
            }

        case .down:
            // Сдвигаем все колонки вниз
            for c in 0..<size {
                let col = tiles.filter { $0.position.col == c }
                               .sorted { $0.position.row > $1.position.row }
                let (collapsed, merged) = collapse(col)
                if merged { moved = true }
                // Размещаем объединённые плитки снизу вверх
                for (i, tile) in collapsed.enumerated() {
                    let r = size - 1 - i
                    if tile.position.row != r { moved = true }
                    var updated = tile
                    updated.position = Position(row: r, col: c)
                    newTiles.append(updated)
                }
            }
        }

        // Если было движение — обновляем состояние поля
        if moved {
            tiles = newTiles
        }

        return moved
    }

    /// Выполняет полный ход: вызывает slide(), а затем добавляет новую плитку и проверяет конец игры.
    func move(direction: Direction) {
        let changed = slide(direction: direction)
        if changed {
            addRandomTile()   // добавляем новую плитку на свободное место
            checkGameOver()   // проверяем, есть ли возможные ходы
        }
    }

/*
  // Variant 2
    func slide(direction: Direction) -> Bool {
        var moved = false   // была ли перемещена или объединена какая-либо плитка
        var newTiles: [Tile] = []

        // MARK: - Collapse one line (row or column)
        func collapse(_ line: [Tile]) -> ([Tile], Bool) {
            var newLine: [Tile] = []
            var skip = false
            var merged = false
            
            for (i, tile) in line.enumerated() {
                if skip {
                    skip = false
                    continue
                }
                // merge adjacent equal tiles
                if i < line.count - 1 && tile.value == line[i + 1].value {
                    var mergedTile = line[i + 1]
                    mergedTile.value *= 2
                    mergedTile.merged = true
                    score += mergedTile.value
                    newLine.append(mergedTile)
                    skip = true
                    merged = true
                } else {
                    newLine.append(tile)
                }
            }
            return (newLine, merged)
        }

        // MARK: - Move by direction
        switch direction {
        case .left:
            for r in 0..<size {
                let row = tiles.filter { $0.position.row == r }
                               .sorted { $0.position.col < $1.position.col }
                let (collapsed, merged) = collapse(row)
                if merged { moved = true }
                for (c, tile) in collapsed.enumerated() {
                    if tile.position.col != c { moved = true }
                    var updated = tile
                    updated.position = Position(row: r, col: c)
                    newTiles.append(updated)
                }
            }

        case .right:
            for r in 0..<size {
                let row = tiles.filter { $0.position.row == r }
                               .sorted { $0.position.col > $1.position.col }
                let (collapsed, merged) = collapse(row)
                if merged { moved = true }
                for (i, tile) in collapsed.enumerated() {
                    let c = size - 1 - i
                    if tile.position.col != c { moved = true }
                    var updated = tile
                    updated.position = Position(row: r, col: c)
                    newTiles.append(updated)
                }
            }

        case .up:
            for c in 0..<size {
                let col = tiles.filter { $0.position.col == c }
                               .sorted { $0.position.row < $1.position.row }
                let (collapsed, merged) = collapse(col)
                if merged { moved = true }
                for (r, tile) in collapsed.enumerated() {
                    if tile.position.row != r { moved = true }
                    var updated = tile
                    updated.position = Position(row: r, col: c)
                    newTiles.append(updated)
                }
            }

        case .down:
            for c in 0..<size {
                let col = tiles.filter { $0.position.col == c }
                               .sorted { $0.position.row > $1.position.row }
                let (collapsed, merged) = collapse(col)
                if merged { moved = true }
                for (i, tile) in collapsed.enumerated() {
                    let r = size - 1 - i
                    if tile.position.row != r { moved = true }
                    var updated = tile
                    updated.position = Position(row: r, col: c)
                    newTiles.append(updated)
                }
            }
        }
        if moved {
            tiles = newTiles
        }
        return moved
    }
   
    func move(direction: Direction) {
            let changed = slide( direction: direction)
            if changed {
                addRandomTile()
                checkGameOver()
            }
        }*/
}

extension GameViewModel {
    /// Ход ИИ на основе Монте-Карло (вариант 1, последовательный)
    func playAITurn() {
        var bestDirection: Direction?
        var bestScore = Int.min
        
        for direction in Direction.allCases {
            var totalScore = 0
            let simulations = 100   // 🔁 количество симуляций для каждого направления
            let deep = 15           // 🔁 глубина случайных ходов после основного
            
            for _ in 0..<simulations {
                // ✅ создаём копию текущей игры
                let simulation = GameViewModel(copying: self)
                
                // пробуем сделать один ход в этом направлении
                simulation.move(direction: direction)
                
                // выполняем несколько случайных ходов "в глубину"
                for _ in 0..<deep {
                    if simulation.gameOver { break }
                    if let randomDir = Direction.allCases.randomElement() {
                        simulation.move(direction: randomDir)
                    }
                }
                
                // накапливаем результат симуляции
                totalScore += simulation.score
            }
            
            // вычисляем средний счёт по направлению
            let avgScore = totalScore / simulations
            if avgScore > bestScore {
                bestScore = avgScore
                bestDirection = direction
            }
        }
        
        // ✅ применяем лучший найденный ход
        if let dir = bestDirection {
            move(direction: dir)
        }
    }
    
    /// Вариант для автопилота (асинхронный вызов)
    func playAITurn2() {
        Task {
            if let dir = await self.bestDirection() {
                await MainActor.run {
                    self.move(direction: dir)
                }
            }
        }
    }
    
    /// Монте-Карло (синхронный, однопоточный, блокирующий)
    /// Используется для быстрых подсказок / подсчётов
    func bestDirectionSync(simulations: Int = 100, depth: Int = 15) -> Direction {
        var bestDirection = Direction.up
        var bestScore = Int.min

        for direction in Direction.allCases {
            // 🔍 Проверяем, даёт ли направление изменение доски
            let testCopy = GameViewModel(copying: self)
            let beforeTiles = testCopy.tiles
            testCopy.move(direction: direction)
            if testCopy.tiles == beforeTiles {
                continue // ❌ ход невозможен, пропускаем
            }

            var totalScore: [Int] = []
            for _ in 0..<simulations {
                // создаём копию игры для симуляции
                let simulation = GameViewModel(copying: self)
                simulation.move(direction: direction)

                // выполняем случайные ходы в глубину
                for _ in 0..<depth {
                    if simulation.gameOver { break }
                    if let randomDir = Direction.allCases.randomElement() {
                        simulation.move(direction: randomDir)
                    }
                }
                totalScore.append(simulation.score)
            }

            // средний счёт для направления
            let avgScore = totalScore.average()
            
            if avgScore > bestScore {
                bestScore = avgScore
                bestDirection = direction
            }
        }
        return bestDirection
    }

    /// Асинхронная версия Монте-Карло (с использованием TaskGroup)
    /// Параллельный расчёт симуляций → быстрее на многопроцессорных устройствах
    nonisolated func bestDirection(simulations: Int = 100, depth: Int = 20) async -> Direction? {
        var bestDirection: Direction?
        var bestScore = Int.min

        for direction in Direction.allCases {
            var totalScore: [Int] = []
            
            // 🔍 Проверяем, даёт ли направление изменение доски
            let testCopy = GameViewModel(copying: self)
            let beforeTiles = testCopy.tiles
            testCopy.move(direction: direction)
            if testCopy.tiles == beforeTiles {
                continue // ❌ ход невозможен, пропускаем
            }

            // 🔁 Запускаем симуляции параллельно
            await withTaskGroup(of: Int.self) { simGroup in
                for _ in 0..<simulations {
                    simGroup.addTask {
                        let simulation = GameViewModel(copying: self)
                        simulation.move(direction: direction)

                        for _ in 0..<depth {
                            if simulation.gameOver { break }
                            if let randomDir = Direction.allCases.randomElement() {
                                simulation.move(direction: randomDir)
                            }
                        }
                        return simulation.score
                    }
                }

                // собираем результаты симуляций
                for await score in simGroup {
                    totalScore.append(score)
                }
            }

            // средний счёт по направлению
            let avgScore = totalScore.average()
            if avgScore > bestScore {
                bestScore = avgScore
                bestDirection = direction
            }
        }

        return bestDirection
    }
}

/// Утилита: среднее значение массива чисел
extension Array where Element == Int {
    func average() -> Int {
        let sum = self.reduce(0, +)
        return Int(Double(sum) / Double(self.count))
    }
}

// Expectimax extension for GameViewModel
extension GameViewModel {
    /// Выбор оптимального направления с помощью Expectimax
        func bestDirectionExpectimax() -> Direction? {
            let depth  = 4
            var bestDir: Direction?
            var bestScore = -Double.infinity
            let emptyCells = emptyPositions().count
            
            checkGameOver()
            if gameOver { return nil }

            for dir in Direction.allCases {
                let state = GameViewModel(tiles: self.tiles)
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
      func expectimax(node: GameViewModel, depth: Int, isChanceNode: Bool) -> Double {
          // терминальные условия
          
          checkGameOver()
          if depth <= 0 || node.gameOver {
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
                  let spawn2 = GameViewModel(tiles: node.tiles)
                  let tile2 = Tile(value: 2, position: Position(row: pos.0, col: pos.1))
                  spawn2.tiles.append(tile2)
                  expected += p2 * (1.0 / Double(empties.count)) *
                              expectimax(node: spawn2, depth: depth - 1, isChanceNode: false)

                  // вариант со спавном 4
                  let spawn4 = GameViewModel(tiles: node.tiles)
                  let tile4 = Tile(value: 4, position: Position(row: pos.0, col: pos.1))
                  spawn4.tiles.append(tile4)
                  expected += p4 * (1.0 / Double(empties.count)) *
                              expectimax(node: spawn4, depth: depth - 1, isChanceNode: false)
              }
              return expected

          } else {
              // Узел "игрок": выбираем лучший ход (max)
              var best = -Double.infinity

              for dir in Direction.allCases {
                  let copy = GameViewModel(tiles: node.tiles)
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
    private func evaluateBoard(_ state: GameViewModel )-> Double {
        let grid = tilesToGrid(state.tiles)
        let empties = state.emptyPositions().count
       
       // weights (tunable)
         let wEmpty = 11.7
         let wMonotonicity =  1.0
         let wSmoothness = 0.0 //-0.1
         let wMaxWeight = 1.0
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
    
    /// Count monotonicity — prefer rows/cols that are monotone (increasing or decreasing)
    /// Returns higher value for more monotone boards.
    private func monotonicity(_ state: GameViewModel) -> Double {
        // measure along rows and columns
        var totals: Double = 0.0
        
        // rows
        for r in 0..<size {
            var rowVals: [Int] = []
            for c in 0..<size {
                if let t = state.tiles.first(where: { $0.position.row == r && $0.position.col == c }) {
                    rowVals.append(t.value)
                } else {
                    rowVals.append(0)
                }
            }
            totals += monotoneScoreLine(rowVals)
        }
        
        // cols
        for c in 0..<size {
            var colVals: [Int] = []
            for r in 0..<size {
                if let t = state.tiles.first(where: { $0.position.row == r && $0.position.col == c }) {
                    colVals.append(t.value)
                } else {
                    colVals.append(0)
                }
            }
            totals += monotoneScoreLine(colVals)
        }
        
        return totals
    }
    
    /// Score a single line for monotonicity
    private func monotoneScoreLine(_ vals: [Int]) -> Double {
        // compute increasing and decreasing sums of log-values
        var inc: Double = 0.0
        var dec: Double = 0.0
        var last = vals[0]
        for i in 1..<vals.count {
            let v = vals[i]
            if v > last {
                inc += log2(Double(v + 1)) - log2(Double(last + 1))
            } else {
                dec += log2(Double(last + 1)) - log2(Double(v + 1))
            }
            last = v
        }
        return max(inc, dec)
    }
    
    /// Smoothness: penalize large differences between neighboring tiles
    private func smoothness(_ state: GameViewModel) -> Double {
        var score = 0.0
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
    
    // helper: return list of empty positions as (row,col)
    func emptyPositions() -> [(Int, Int)] {
        var res: [(Int, Int)] = []
        for r in 0..<size {
            for c in 0..<size {
                if !tiles.contains(where: { $0.position.row == r && $0.position.col == c }) {
                    res.append((r, c))
                }
            }
        }
        return res
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
    
    /// Вариант для автопилота (асинхронный вызов)
    func playAIExpectimax() {
        Task {
            if let dir = bestDirectionExpectimax() {
                await MainActor.run {
                    self.move(direction: dir)
                }
            } else {
                checkGameOver()
            }
        }
    }
    
    //------------
    /// Преобразовать плоский массив [Tile] в двумерную сетку [[Int]]
    /// - Параметры:
    /// - Parameters
    ///   - tiles: fплоский массив Tile
    ///   - size: размер доски (по умолчанию = 4x4 для 2048)
    /// - Returns: [[Int]] where 0 means empty cell
    func tilesToGrid(_ tiles: [Tile], size: Int = 4) -> [[Int]] {
        // Создать пустую сетку grid, заполненную нулями
        var grid = Array(repeating: Array(repeating: 0, count: size), count: size)
        
        for tile in tiles {
            let r = tile.position.row
            let c = tile.position.col
            grid[r][c] = tile.value
        }
        return grid
    }
}


// Expectimax extension for GameViewModel (асинхронный)
extension GameViewModel {
    /// Выбор оптимального направления с помощью Expectimax ( асинхронный )
    func bestDirectionExpectimaxAsync() async -> Direction? {
        let depth  = 5
        var bestDir: Direction?
        var bestScore = -Double.infinity
        let emptyCells = emptyPositions().count
        
        checkGameOver()
        if gameOver { return nil }
        
        await withTaskGroup(of: (Direction, Double)?.self) { group in
            for dir in Direction.allCases {
                group.addTask { [self] in
                    let state = GameViewModel(tiles: self.tiles)
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
    func expectimaxAsync(node: GameViewModel, depth: Int, isChanceNode: Bool) async -> Double {
        // терминальные условия
        node.checkGameOver()
        if depth <= 0 || node.gameOver{
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
            return await withTaskGroup(of: Double.self) { group in
                for pos in empties {
                    group.addTask {
                        // вариант со значением 2
                        let spawn2 = GameViewModel(tiles: node.tiles)
                        let tile2 = Tile(value: 2, position: Position(row: pos.0, col: pos.1))
                        spawn2.tiles.append(tile2)
                        let val2 = await self.expectimaxAsync(node: spawn2, depth: depth - 1, isChanceNode: false)
                        return p2 * probPerEmpty * val2
                    }
                    
                    group.addTask {
                        // вариант со значением 4
                        let spawn4 = GameViewModel(tiles: node.tiles)
                        let tile4 = Tile(value: 4, position: Position(row: pos.0, col: pos.1))
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
            
            return await withTaskGroup(of: Double.self) { group in
                for dir in Direction.allCases {
                    group.addTask { [self] in
                        let copy = GameViewModel(tiles: node.tiles)
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
    
    /// Вариант для автопилота (асинхронный вызов)
    func playAIExpectimaxAsync () {
        Task {
            if let dir = await bestDirectionExpectimaxAsync () {
                await MainActor.run {
                    self.move(direction: dir)
                }
            } else {
                checkGameOver()
            }
        }
    }
}
