//
//  ArrowView.swift
//  ChatGPT5_2048
//
//  Created by Tatiana Kornilova on 21.09.2025.
//

import SwiftUI

// MARK: - ArrowShape (анимируемая форма стрелки по углу в радианах)
struct ArrowShape: Shape {
    /// Угол в радианах.
    /// 0 = вправо, +90° = вниз, -90° = вверх, π = влево (переводим в вызывающем коде)
    var angle: Double

    // Свойство для анимации: SwiftUI будет плавно изменять это значение
    var animatableData: Double {
        get { angle }
        set { angle = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var p = Path()

        let midX = rect.midX   // центр по X
        let midY = rect.midY   // центр по Y

        // Длина линии стрелки и длина "головки", зависящие от размера rect
        let length = min(rect.width, rect.height) * 0.32
        let headLen = min(rect.width, rect.height) * 0.20

        // Вектор направления (угол -> dx, dy)
        let dx = CGFloat(cos(angle))
        let dy = CGFloat(sin(angle))

        // Точка начала линии и кончик стрелки
        let start = CGPoint(x: midX - dx * length, y: midY - dy * length)
        let tip   = CGPoint(x: midX + dx * length, y: midY + dy * length)

        // Основная линия стрелки
        p.move(to: start)
        p.addLine(to: tip)

        // Вычисляем два угла для "усиков" стрелки (±135° относительно направления)
        let perpAngle1 = angle + (3.0 * .pi / 4.0)
        let perpAngle2 = angle - (3.0 * .pi / 4.0)

        // Левая и правая точки головки стрелки
        let headPoint1 = CGPoint(
            x: tip.x + CGFloat(cos(perpAngle1)) * headLen,
            y: tip.y + CGFloat(sin(perpAngle1)) * headLen
        )
        let headPoint2 = CGPoint(
            x: tip.x + CGFloat(cos(perpAngle2)) * headLen,
            y: tip.y + CGFloat(sin(perpAngle2)) * headLen
        )

        // Соединяем кончик стрелки с головкой (две линии)
        p.move(to: tip)
        p.addLine(to: headPoint1)

        p.move(to: tip)
        p.addLine(to: headPoint2)

        return p
    }
}

// MARK: - ArrowMorphView (контейнер, анимирует поворот стрелки между направлениями)
struct ArrowMorphView: View {
    var direction: Direction  // текущее направление
    var strokeStyle: StrokeStyle = StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round) // стиль линии
    var color: Color = .blue  // цвет стрелки

    // Текущий угол (в радианах), хранится в @State для анимации
    @State private var angle: Double

    init(direction: Direction,
         strokeStyle: StrokeStyle = StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round),
         color: Color = .blue) {
        self.direction = direction
        self.strokeStyle = strokeStyle
        self.color = color
        // Инициализация угла в зависимости от переданного направления
        _angle = State(initialValue: Self.directionToAngle(direction))
    }

    var body: some View {
        ArrowShape(angle: angle) // сама форма стрелки
            .stroke(color, style: strokeStyle) // применяем цвет и стиль линии
            .onChange(of: direction) { oldDir, newDir in
                // Целевой угол для нового направления
                var target = Self.directionToAngle(newDir)

                // Корректируем угол так, чтобы поворот был по кратчайшему пути
                while target - angle > .pi { target -= 2 * .pi }
                while target - angle < -(.pi) { target += 2 * .pi }

                // Анимация поворота
                withAnimation(.easeInOut(duration: 0.36)) {
                    angle = target
                }
            }
            .onAppear {
                // Устанавливаем угол в соответствии с начальным направлением (без резкого прыжка)
                let initial = Self.directionToAngle(direction)
                angle = initial
            }
    }

    /// Преобразуем Direction в угол (радианы):
    /// up    -> -π/2
    /// right -> 0
    /// down  -> π/2
    /// left  -> π (то же, что -π)
    static func directionToAngle(_ d: Direction) -> Double {
        switch d {
        case .up:    return -Double.pi / 2.0
        case .right: return 0.0
        case .down:  return Double.pi / 2.0
        case .left:  return Double.pi // то же самое, что -π
        }
    }
}

struct ArrowMorphPreview: View {
    @State private var currentDirection: Direction = .up

    var body: some View {
        VStack(spacing: 40) {
            // Сама стрелка
            ArrowMorphView(direction: currentDirection,
                           strokeStyle: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round),
                           color: .blue)
                .frame(width: 120, height: 120)
                .opacity(0.8)

            // Кнопки для выбора направления
            VStack(spacing: 16) {
                Button("⬆️ Вверх") { currentDirection = .up }
                HStack {
                    Button("⬅️ Влево") { currentDirection = .left }
                    Button("➡️ Вправо") { currentDirection = .right }
                }
                Button("⬇️ Вниз") { currentDirection = .down }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

#Preview {
    ArrowMorphPreview()
}

