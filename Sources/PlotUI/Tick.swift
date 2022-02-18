import Foundation
import SwiftUI

public struct TickOrientation: Equatable {

    typealias Body = (CGFloat, ContentDisposition, Viewport) -> Path

    internal var axis: Axis.Set
    internal var body: Body

    internal init(_ axis: Axis.Set, @ViewBuilder body: @escaping Body) {
        self.axis = axis
        self.body = body
    }

    public static let vertical = TickOrientation(.vertical) { value, disposition, viewport in
        let xScale = viewport.rect.width / disposition.bounds.width
        let x = viewport.rect.minX + (value - disposition.bounds.left) * xScale

        return Path { path in
            if (viewport.rect.minX...viewport.rect.maxX).contains(x) {
                path.move(to: CGPoint(x: x, y: viewport.rect.minY))
                path.addLine(to: CGPoint(x: x, y: viewport.frame.height))
            }
        }
    }

    public static let horizontal = TickOrientation(.horizontal) { value, disposition, viewport in
        // All y-axis ticks are located on the horizontal axis, hence subtract the
        // size of y-tick from the width of this axis.
        let yScale = viewport.rect.height / disposition.bounds.height
        let y = viewport.rect.height - (value - disposition.bounds.bottom) * yScale

        return Path { path in
            if (viewport.rect.minY...viewport.rect.maxY).contains(y) {
                path.move(to: CGPoint(x: viewport.rect.minX, y: y))
                path.addLine(to: CGPoint(x: viewport.frame.width, y: y))
            }
        }
    }

    public static func == (a: TickOrientation, b: TickOrientation) -> Bool {
        return a.axis == b.axis
    }
}

public struct Tick: View {
    @Environment(\.contentDisposition) private var disposition
    @Environment(\.viewport) private var viewport
    @Environment(\.tickStyle) private var style
    @Environment(\.tickStroke) private var stroke

    @ScaledMetric(relativeTo: .body) private var padding = 10

    private var label: LocalizedStringKey
    private var orientation: TickOrientation
    private var value: Double

    public init(_ label: LocalizedStringKey, orientation: TickOrientation, value: Double) {
        self.orientation = orientation
        self.label = label
        self.value = value
    }

    public var body: some View {
        GeometryReader { rect in
            let path = orientation.body(value, disposition, viewport)
            let configuration = TickStyleConfiguration(
                label: TickStyleConfiguration.Label(Text(label)),
                tick: path.boundingRect,
                orientation: orientation,
                padding: padding
            )

            path.stroke(style: stroke)
            style
                .makeBody(configuration: configuration)
                .font(.system(.footnote).weight(.light))
        }
    }
}

struct VerticalTickPreview: PreviewProvider {
    static var previews: some View {
        GeometryReader { rect in
            Tick("5", orientation: .vertical, value: 5)
                .contentDisposition(left: 0, right: 10, bottom: 0, top: 10)
                .viewport([.top, .bottom, .leading], 40)
                .tickStyle(.bottomTrailing)
                .tickStroke(style: .tinyDashed)
        }
        .frame(width: 400, height: 400)
        .background(Color.white)
    }
}

extension StrokeStyle {
    static public var tinyDashed: StrokeStyle {
        StrokeStyle(lineWidth: 0.2, dash: [2])
    }

    static public var tiny: StrokeStyle {
        StrokeStyle(lineWidth: 0.2)
    }
}

struct TickStrokeEnvironmentKey: EnvironmentKey {
    static var defaultValue: StrokeStyle = .tiny
}

extension EnvironmentValues {
    public var tickStroke: StrokeStyle {
        get { self[TickStrokeEnvironmentKey.self] }
        set { self[TickStrokeEnvironmentKey.self] = newValue }
    }
}

extension View {
    public func tickStroke(style: StrokeStyle) -> some View {
        environment(\.tickStroke, style)
    }
}
