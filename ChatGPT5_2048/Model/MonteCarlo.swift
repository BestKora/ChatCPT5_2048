//
//  MonteCarlo.swift
//  ChatGPT5_2048
//
//  Created by Tatiana Kornilova on 16/10/2025.
//

// final class MonteCarlo : Sendable {
    struct MonteCarlo {
    /// Асинхронная версия Монте-Карло (с использованием TaskGroup)
    /// Параллельный расчёт симуляций → быстрее на многопроцессорных устройствах
    static func bestDirection (tiles: [Tile], simulations: Int = 100, depth: Int = 20) async -> Direction? {
        var bestDirection: Direction?
        var bestScore = Int.min

        for direction in Direction.allCases {
            var totalScore: [Int] = []
            
            // 🔍 Проверяем, даёт ли направление изменение доски
            var testCopy = Game(tiles: tiles)//GameViewModel(tiles: tiles)
            let beforeTiles = testCopy.tiles
            testCopy.move(direction: direction)
            if testCopy.tiles == beforeTiles {
                continue // ❌ ход невозможен, пропускаем
            }

            // 🔁 Запускаем симуляции параллельно
            await withTaskGroup /*(of: Int.self) */{ simGroup in
                for _ in 0..<simulations {
                    simGroup.addTask {
                        var simulation = Game (tiles: tiles)
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
    
    /// Монте-Карло (синхронный, однопоточный, блокирующий)
    /// Используется для быстрых подсказок / подсчётов
    static func bestDirectionSync(tiles: [Tile],simulations: Int = 100, depth: Int = 15) -> Direction? {
        var bestDirection: Direction?
        var bestScore = Int.min

        for direction in Direction.allCases {
            // 🔍 Проверяем, даёт ли направление изменение доски
            var testCopy = Game (tiles:  tiles)
            let beforeTiles = testCopy.tiles
            testCopy.move(direction: direction)
            if testCopy.tiles == beforeTiles {
                continue // ❌ ход невозможен, пропускаем
            }

            var totalScore: [Int] = []
            for _ in 0..<simulations {
                // создаём копию игры для симуляции
                var simulation = Game (tiles:  tiles)
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
}

/// Утилита: среднее значение массива чисел
extension Array where Element == Int {
    func average() -> Int {
        let sum = self.reduce(0, +)
        return Int(Double(sum) / Double(self.count))
    }
}
