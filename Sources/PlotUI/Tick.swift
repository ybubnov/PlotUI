import Foundation
import SwiftUI

public struct TickOrientationConfiguration {
    let value: Double

    let contentDisposition: ContentDisposition

    let viewport: Viewport

    let size: CGSize
}

public protocol TickOrientationStyle {
    typealias Configuration = TickOrientationConfiguration

    func makeBody(configuration: Configuration) -> Path
}

public struct AnyTickOrientationStyle: TickOrientationStyle {

    var _makeBody: (Configuration) -> Path

    public init<S: TickOrientationStyle>(_ style: S) {
        self._makeBody = { configuration in
            style.makeBody(configuration: configuration)
        }
    }

    public func makeBody(configuration: Configuration) -> Path {
        _makeBody(configuration)
    }
}

struct VerticalTickOrientationStyle: TickOrientationStyle {
    func makeBody(configuration: Configuration) -> Path {
        let disposition = configuration.contentDisposition
        let rect = configuration.viewport.inset(
            rect: CGRect(origin: .zero, size: configuration.size)
        )

        let xScale = rect.width / disposition.bounds.width
        let x = rect.minX + (configuration.value - disposition.bounds.left) * xScale

        return Path { path in
            if (rect.minX...rect.maxX).contains(x) {
                path.move(to: CGPoint(x: x, y: rect.minY))
                path.addLine(to: CGPoint(x: x, y: configuration.size.height))
            }
        }
    }
}

struct HorizontalTickOrientationStyle: TickOrientationStyle {
    func makeBody(configuration: Configuration) -> Path {
        let disposition = configuration.contentDisposition
        let rect = configuration.viewport.inset(
            rect: CGRect(origin: .zero, size: configuration.size)
        )

        // All y-axis ticks are located on the horizontal axis, hence subtract the
        // size of y-tick from the width of this axis.
        let yScale = rect.height / disposition.bounds.height
        let y = rect.maxY - (configuration.value - disposition.bounds.bottom) * yScale

        return Path { path in
            if (rect.minY...rect.maxY).contains(y) {
                path.move(to: CGPoint(x: rect.minX, y: y))
                path.addLine(to: CGPoint(x: configuration.size.width, y: y))
            }
        }
    }
}

public struct TickOrientation: Equatable {

    internal var axis: Axis.Set
    internal var style: AnyTickOrientationStyle

    internal init<S: TickOrientationStyle>(_ axis: Axis.Set, _ style: S) {
        self.axis = axis
        self.style = AnyTickOrientationStyle(style)
    }

    public static let vertical = TickOrientation(.vertical, VerticalTickOrientationStyle())

    public static let horizontal = TickOrientation(.horizontal, HorizontalTickOrientationStyle())

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
            let path = orientation.style.makeBody(
                configuration: TickOrientationConfiguration(
                    value: value,
                    contentDisposition: disposition,
                    viewport: viewport,
                    size: rect.size
                )
            )

            path.stroke(style: stroke)
            style.makeBody(
                configuration: TickStyleConfiguration(
                    label: TickStyleConfiguration.Label(Text(label)),
                    tick: path.boundingRect,
                    orientation: orientation,
                    padding: padding
                )
            )
            .font(.system(.footnote).weight(.light))
        }
    }
}

struct VerticalTickPreview: PreviewProvider {
    static var previews: some View {
        GeometryReader { rect in
            Tick("5", orientation: .vertical, value: 5)
                .contentDisposition(left: 0, right: 10, bottom: 0, top: 10)
                .tickInsets(top: 40, bottom: 40)
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

    public func tickInsets(_ insets: EdgeInsets) -> some View {
        return viewport(insets)
    }

    public func tickInsets(
        top: CGFloat? = nil, leading: CGFloat? = nil, bottom: CGFloat? = nil,
        trailing: CGFloat? = nil
    ) -> some View {
        return viewport(top: top, leading: leading, bottom: bottom, trailing: trailing)
    }
}
