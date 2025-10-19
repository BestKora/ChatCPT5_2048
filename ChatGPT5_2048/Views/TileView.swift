//
//  TileView.swift
//  ChatGPT5_2048
//
//  Created by Tatiana Kornilova on 21.08.2025.
//

import SwiftUI

struct TileView: View {
    let tile: Tile
    let size: CGFloat
    let spacing: CGFloat
    
    @State private var isPopping = false
    var onPopFinished: () -> Void   // callback для сброса состояния после объединения плитки

    var body: some View {
        // 📍 Вычисляем позицию плитки на поле
        let tilePosition =
            CGPoint(
                x: CGFloat(tile.position.col) * (size + spacing) + size / 2,
                y: CGFloat(tile.position.row) * (size + spacing) + size / 2
            )
        
        RoundedRectangle(cornerRadius: 8)
            // 🎨 Цвет плитки в зависимости от значения
            .fill(color(for: tile.value))
            .frame(width: size, height: size)
            // 📝 Накладываем текст с числом плитки
            .overlay(
                Text(tile.value, format: .number.precision(.fractionLength(0)).grouping(.never))
                    .font(.title)
                    .bold()
                    // Цвет текста: светлый для маленьких чисел, белый для больших
                    .foregroundColor(tile.value > 4 ? .white : .black)
            )
            // 🔄 Анимация "прыжка" при объединении плиток
           .scaleEffect(isPopping ? 1.2 : 1.0)
            .onChange(of: tile.merged) { _, merged in
                if merged {
                    // Запускаем анимацию увеличения плитки
                    withAnimation {
                        isPopping = true
                    }
                    completion: {
                        // После завершения возвращаем размер обратно
                        withAnimation {
                            isPopping = false
                           // tile.merged = false
                            onPopFinished()
                        }
                    }
                }
            }
            // 📍 Устанавливаем позицию плитки на поле
            .position(tilePosition)
            // Анимация плавного перемещения плитки
            .animation(.easeInOut(duration: 0.34), value: tile.position)
            // 🎭 Анимация появления и удаления плитки
            .transition(
                .asymmetric(
                    insertion: .scale(scale: 0.12)
                        .combined(
                            with: .offset(
                                x: tilePosition.x - 2 * size,
                                y: tilePosition.y - 2 * size
                            )
                        ),
                    removal: .opacity
                )
            )
    }
    
    // 🎨 Определение цвета плитки по её значению
    private func color(for value: Int) -> Color {
        switch value {
        case 2: return Color(hex: "#EEE4DA") // Светло-бежевый
        case 4: return Color(hex: "#EDE0C8") // Бежевый
        case 8: return Color(hex: "#F2B179") // Светло-оранжевый
        case 16: return Color(hex: "#F59563") // Оранжевый
        case 32: return Color(hex: "#F67C5F") // Более тёмный оранжевый
        case 64: return Color(hex: "#F65E3B") // Красно-оранжевый
        case 128: return Color(hex: "#EDCF72") // Жёлтый
        case 256: return Color(hex: "#EDCC61") // Тёмно-жёлтый
        case 512: return Color(hex: "#EDC850") // Золотой
        case 1024: return Color(hex: "#EDC53F") // Тёмно-золотой
        case 2048: return Color(hex: "#EDC22E") // Ярко-золотой
        default: return Color(hex: "#CDC1B4") // Цвет для пустых или нестандартных плиток
        }
    }
}

extension Color {
    static let colorBG = Color(hex: "#BBADA0")      // Цвет фона поля
    static let colorEmpty = Color(hex: "#CDC1B4")   // Цвет пустой ячейки
    
    // 🛠 Конструктор цвета из hex-кода
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-бит)
            (a, r, g, b) = (255, (int >> 8) * 17,
                            (int >> 4 & 0xF) * 17,
                            (int & 0xF) * 17)
        case 6: // RGB (24-бит)
            (a, r, g, b) = (255,
                            int >> 16,
                            int >> 8 & 0xFF,
                            int & 0xFF)
        case 8: // ARGB (32-бит)
            (a, r, g, b) = (int >> 24,
                            int >> 16 & 0xFF,
                            int >> 8 & 0xFF,
                            int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    // 🔍 Превью плитки со значением 8 в позиции (0,2)
    let tile = Tile(value: 8, position: Position(row: 0, col: 2))
    TileView(tile: tile, size: 70, spacing: 8)  {  }
}

