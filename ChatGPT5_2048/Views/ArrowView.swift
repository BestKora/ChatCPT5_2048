//
//  ArrowView.swift
//  ChatGPT5_2048
//
//  Created by Tatiana Kornilova on 21.09.2025.
//

/* import SwiftUI

// Variant 1
   struct ArrowView: Shape {
    let direction: Direction

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let midX = rect.midX
        let midY = rect.midY

        switch direction {
        case .up:
            path.move(to: CGPoint(x: midX, y: rect.minY))
            path.addLine(to: CGPoint(x: midX, y: rect.maxY))
            path.move(to: CGPoint(x: midX, y: rect.minY))
            path.addLine(to: CGPoint(x: midX - 20, y: rect.minY + 30))
            path.move(to: CGPoint(x: midX, y: rect.minY))
            path.addLine(to: CGPoint(x: midX + 20, y: rect.minY + 30))
        case .down:
            path.move(to: CGPoint(x: midX, y: rect.maxY))
            path.addLine(to: CGPoint(x: midX, y: rect.minY))
            path.move(to: CGPoint(x: midX, y: rect.maxY))
            path.addLine(to: CGPoint(x: midX - 20, y: rect.maxY - 30))
            path.move(to: CGPoint(x: midX, y: rect.maxY))
            path.addLine(to: CGPoint(x: midX + 20, y: rect.maxY - 30))
        case .left:
            path.move(to: CGPoint(x: rect.minX, y: midY))
            path.addLine(to: CGPoint(x: rect.maxX, y: midY))
            path.move(to: CGPoint(x: rect.minX, y: midY))
            path.addLine(to: CGPoint(x: rect.minX + 30, y: midY - 20))
            path.move(to: CGPoint(x: rect.minX, y: midY))
            path.addLine(to: CGPoint(x: rect.minX + 30, y: midY + 20))
        case .right:
            path.move(to: CGPoint(x: rect.maxX, y: midY))
            path.addLine(to: CGPoint(x: rect.minX, y: midY))
            path.move(to: CGPoint(x: rect.maxX, y: midY))
            path.addLine(to: CGPoint(x: rect.maxX - 30, y: midY - 20))
            path.move(to: CGPoint(x: rect.maxX, y: midY))
            path.addLine(to: CGPoint(x: rect.maxX - 30, y: midY + 20))
        }
        return path
    }
} */

// Variant 2
/*import SwiftUI


// MARK: - ArrowShape (animatable by angle in radians)
struct ArrowShape: Shape {
    /// Angle in radians. 0 = right, +90° = down, -90° = up, π = left (we convert externally)
    var angle: Double

    var animatableData: Double {
        get { angle }
        set { angle = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var p = Path()

        let midX = rect.midX
        let midY = rect.midY

        // length and head size tuned to rect
        let length = min(rect.width, rect.height) * 0.32
        let headLen = min(rect.width, rect.height) * 0.20

        // forward vector (Double -> CGFloat)
        let dx = CGFloat(cos(angle))
        let dy = CGFloat(sin(angle))

        // main line endpoints
        let start = CGPoint(x: midX - dx * length, y: midY - dy * length)
        let tip   = CGPoint(x: midX + dx * length, y: midY + dy * length)

        p.move(to: start)
        p.addLine(to: tip)

        // arrowhead: two points at ±135° from forward
        let perpAngle1 = angle + (3.0 * .pi / 4.0)
        let perpAngle2 = angle - (3.0 * .pi / 4.0)

        let headPoint1 = CGPoint(
            x: tip.x + CGFloat(cos(perpAngle1)) * headLen,
            y: tip.y + CGFloat(sin(perpAngle1)) * headLen
        )
        let headPoint2 = CGPoint(
            x: tip.x + CGFloat(cos(perpAngle2)) * headLen,
            y: tip.y + CGFloat(sin(perpAngle2)) * headLen
        )

        p.move(to: tip)
        p.addLine(to: headPoint1)

        p.move(to: tip)
        p.addLine(to: headPoint2)

        return p
    }
}

// MARK: - ArrowMorphView (handles shortest-path angle interpolation)
struct ArrowMorphView: View {
    var direction: Direction
    var strokeStyle: StrokeStyle = StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
    var color: Color = .blue

    // current animated angle (radians). Initialize to direction angle
    @State private var angle: Double

    init(direction: Direction, strokeStyle: StrokeStyle = StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round), color: Color = .blue) {
        self.direction = direction
        self.strokeStyle = strokeStyle
        self.color = color
        // initial state value — set via State initializer
        _angle = State(initialValue: Self.directionToAngle(direction))
    }

    var body: some View {
        ArrowShape(angle: angle)
            .stroke(color, style: strokeStyle)
            .onChange(of: direction) { oldDir, newDir in
                // compute canonical target angle for the new direction
                var target = Self.directionToAngle(newDir)

                // adjust target by +/- 2π to pick the shortest rotation path
                // so numeric interpolation goes the shorter way
                while target - angle > .pi { target -= 2 * .pi }
                while target - angle < -(.pi) { target += 2 * .pi }

                withAnimation(.easeInOut(duration: 0.36)) {
                    angle = target
                }
            }
            .onAppear {
                // ensure angle matches initial direction (no snap)
                let initial = Self.directionToAngle(direction)
                angle = initial
            }
    }

    /// Map Direction to a base angle in radians:
    /// up    -> -π/2
    /// right -> 0
    /// down  -> π/2
    /// left  -> π (or -π)
    static func directionToAngle(_ d: Direction) -> Double {
        switch d {
        case .up:    return -Double.pi / 2.0
        case .right: return 0.0
        case .down:  return Double.pi / 2.0
        case .left:  return Double.pi // same as -π
        }
    }
}
*/
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

