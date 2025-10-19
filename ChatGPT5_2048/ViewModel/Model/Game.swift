//
//  Game.swift
//  ChatGPT5_2048
//
//  Created by Tatiana Kornilova on 16/10/2025.
//

import Foundation

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
struct Game {
    let size = 4               // размер поля (4x4)
    var tiles: [Tile] = []     // массив плиток
    var score = 0              // текущий счёт
    var gameOver = false       // флаг окончания игры
    
  //  let monteCarlo = MonteCarlo()
    
    init() {
        startGame()
    }
    
    // Инициализатор для глубокого копирования состояния (нужен для симуляций AI)
    init(tiles: [Tile]) {
        self.tiles = tiles
        self.score = 0
        self.gameOver = false
    }
    
    /// Инициализатор для глубокого копирования состояния (нужен для симуляций AI)
    init(copying other: Game) {
        self.tiles = other.tiles
        self.score = other.score
        self.gameOver = other.gameOver
    }
    
    /// Начало новой игры
    mutating func startGame() {
        gameOver = false
        score = 0
        tiles.removeAll()
        
        // В начале появляются 2 случайные плитки
        addRandomTile()
        addRandomTile()
    }
    
    /// Добавление новой случайной плитки (2 или 4) в пустую ячейку
    mutating func addRandomTile() {
        // Если нет пустых — выходим
        guard let pos = emptyPositions().randomElement() else { return }
        
        // Новая плитка — 2 или 4
        let newValue = Bool.random() ? 2 : 4
        let newTile = Tile(value: newValue, position: pos)
        tiles.append(newTile)
    }
    
    /// Проверка, закончена ли игра
   mutating func checkGameOver() {
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
    /// Выполняет сдвиг и объединение плиток в заданном направлении.
    /// Возвращает `true`, если хотя бы одна плитка была перемещена или объединена.
    mutating func slide(direction: Direction) -> Bool {
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
                    newLine.append(mergedTile)    // добавляем новую плитку в линию
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
   mutating func move(direction: Direction) {
        let changed = slide(direction: direction)
        if changed {
            addRandomTile()   // добавляем новую плитку на свободное место
            checkGameOver()   // проверяем, есть ли возможные ходы
        }
    }
   
    // MARK: - вcпомогательные функции
    /// Преобразовать плоский массив [Tile] в двумерную сетку [[Int]]
    /// - Returns: [[Int]] where 0 means empty cell
    func tilesToGrid() -> [[Int]] {
        // Создать пустую сетку grid, заполненную нулями
        var grid = Array(repeating: Array(repeating: 0, count: size), count: size)
        
        for tile in tiles {
            let r = tile.position.row
            let c = tile.position.col
            grid[r][c] = tile.value
        }
        return grid
    }
    
    // Возвращает список пустых позиций как [Position]
    func emptyPositions() -> [Position]{
        // Находим все пустые позиции
        let emptyPositions = (0..<size).flatMap { r in
            (0..<size).compactMap { c in
                tiles.contains(where: { $0.position.row == r && $0.position.col == c }) ? nil : Position (row:r, col:c)
            }
        }
        return emptyPositions
    }
}
