import Foundation
import SwiftUI

/// The properties of a tick orientation.
struct TickOrientationConfiguration {
    /// A value of a specific point on a target axis.
    let value: Double

    /// A bounds of the plot's data.
    let contentDisposition: ContentDisposition

    /// An area where the plot's data is currently being viewed.
    let viewport: Viewport

    /// A flexible preferred size of the parent's layout.
    let frameSize: CGSize
}

/// A type that applies a custom appearence to tick geometry.
///
/// To configure the tick representation, use the `Tick`'s constructor
/// ``Tick/init(_:orientation:value:)``. Specify a style that conforms
/// `TickOrientationStyle` to create a tick with custom orientation.
protocol TickOrientationStyle {
    /// The properties of a tick orientation.
    typealias Configuration = TickOrientationConfiguration

    /// Create a path that represents a tick.
    func makeBody(configuration: Configuration) -> Path
}

/// A type-erased TickOrientationStyle value.
struct AnyTickOrientationStyle: TickOrientationStyle {

    var _makeBody: (Configuration) -> Path

    /// Creates an instance from `style`.
    init<S: TickOrientationStyle>(_ style: S) {
        self._makeBody = { configuration in
            style.makeBody(configuration: configuration)
        }
    }

    /// Creates a path that represents a tick.
    func makeBody(configuration: Configuration) -> Path {
        _makeBody(configuration)
    }
}

/// A tick orientation that shows a tick as a vertical line from the bottom to the top
/// of its parent plot.
struct VerticalTickOrientationStyle: TickOrientationStyle {
    /// Creates a path that represents a tick.
    func makeBody(configuration: Configuration) -> Path {
        let disposition = configuration.contentDisposition
        let rect = configuration.viewport.inset(
            rect: CGRect(origin: .zero, size: configuration.frameSize)
        )

        let xScale = rect.width / disposition.bounds.width
        let x = rect.minX + (configuration.value - disposition.bounds.left) * xScale

        return Path { path in
            if (rect.minX...rect.maxX).contains(x) {
                path.move(to: CGPoint(x: x, y: rect.minY))
                path.addLine(to: CGPoint(x: x, y: configuration.frameSize.height))
            }
        }
    }
}

/// A tick orientation that shows a tick as a horizontal line from left to the right
/// of its parent plot.
struct HorizontalTickOrientationStyle: TickOrientationStyle {
    /// Creates a path that represents a tick.
    func makeBody(configuration: Configuration) -> Path {
        let disposition = configuration.contentDisposition
        let rect = configuration.viewport.inset(
            rect: CGRect(origin: .zero, size: configuration.frameSize)
        )

        // All y-axis ticks are located on the horizontal axis, hence subtract the
        // size of y-tick from the width of this axis.
        let yScale = rect.height / disposition.bounds.height
        let y = rect.maxY - (configuration.value - disposition.bounds.bottom) * yScale

        return Path { path in
            if (rect.minY...rect.maxY).contains(y) {
                path.move(to: CGPoint(x: rect.minX, y: y))
                path.addLine(to: CGPoint(x: configuration.frameSize.width, y: y))
            }
        }
    }
}

/// A value that describes the orientation of a tick.
///
/// A tick orientation defines a tick's target axis. For example,
/// the ``TickOrientation/horizontal`` indicates that a tick is dedicated for Y axis and
/// is used to show a specific point on Y axis:
///
/// ```swift
/// Tick("One", orientation: .horizontal, value: 1.0)
/// ```
public struct TickOrientation: Equatable {

    internal var axis: Axis.Set
    internal var style: AnyTickOrientationStyle

    internal init<S: TickOrientationStyle>(_ axis: Axis.Set, _ style: S) {
        self.axis = axis
        self.style = AnyTickOrientationStyle(style)
    }

    /// An orientation that indicates a vertical tick.
    ///
    /// Use this orientation for a tick that shows a specific point on Y axis.
    public static let vertical = TickOrientation(.vertical, VerticalTickOrientationStyle())

    /// An orientation that indicates a horizontal tick.
    ///
    /// Use this orientation for a tick that shows a specific point on X axis.
    public static let horizontal = TickOrientation(.horizontal, HorizontalTickOrientationStyle())

    /// Indicates whether two tick orientations are equal.
    public static func == (a: TickOrientation, b: TickOrientation) -> Bool {
        return a.axis == b.axis
    }
}

public struct Tick: View {
    @Environment(\.contentDisposition) private var disposition
    @Environment(\.viewport) private var viewport
    @Environment(\.tickStyle) private var style
    @Environment(\.tickStroke) private var stroke
    @Environment(\.tickColor) private var color

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
                    frameSize: rect.size
                )
            )

            path.stroke(style: stroke).fill(color)
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

struct TickColorEnvironmentKey: EnvironmentKey {
    static var defaultValue: Color = .gray
}

extension EnvironmentValues {
    public var tickStroke: StrokeStyle {
        get { self[TickStrokeEnvironmentKey.self] }
        set { self[TickStrokeEnvironmentKey.self] = newValue }
    }

    public var tickColor: Color {
        get { self[TickColorEnvironmentKey.self] }
        set { self[TickColorEnvironmentKey.self] = newValue }
    }
}

extension View {
    public func tickStroke(style: StrokeStyle) -> some View {
        environment(\.tickStroke, style)
    }

    public func tickColor(_ color: Color) -> some View {
        environment(\.tickColor, color)
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
