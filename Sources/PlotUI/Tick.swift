import Foundation
import SwiftUI

/// The properties of a tick orientation.
struct TickOrientationConfiguration {
    /// A value of a specific point on a target axis.
    let value: Double

    /// Bounds of the plot's data.
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

        let xScale = rect.width / disposition.width
        let x = rect.minX + (configuration.value - disposition.minX) * xScale

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
        let yScale = rect.height / disposition.height
        let y = rect.maxY - (configuration.value - disposition.minY) * yScale

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

/// A visual element of a plot that be used to show specific points on a coordinate
/// axis.
///
/// Commonly, you don't need to use this view directly, ``VAxis`` and ``HAxis`` create
/// ticks at the necessary positions.
public struct Tick: View {
    @Environment(\.contentDisposition) private var disposition
    @Environment(\.viewport) private var viewport
    @Environment(\.tickStyle) private var style
    @Environment(\.tickStroke) private var stroke
    @Environment(\.tickColor) private var color
    @Environment(\.tickFont) private var font

    @ScaledMetric(relativeTo: .body) private var padding = 10

    private var label: LocalizedStringKey
    private var orientation: TickOrientation
    private var value: Double

    /// Creates a tick with the given label at the given `value` within a content
    /// disposition.
    ///
    /// You need to specify a disposition of the plot's content using
    /// ``PlotView/contentDisposition(minX:maxX:minY:maxY:)`` to render a tick, if used
    /// outside of `PlotView` hierarchy:
    ///
    /// ```swift
    /// Tick("4.2", .horizontal, 4.2)
    /// .contentDisposition(minX: 0, maxX: 10, minY: 0, maxY: 10)
    /// ```
    ///
    /// - Parameters:
    ///   - label: A label associated with the tick.
    ///   - orientation: An orientation of a tick, either vertical or horizontal.
    ///   - value: A position of a tick within content disposition of the plot's data.
    public init(_ label: LocalizedStringKey, orientation: TickOrientation, value: Double) {
        self.orientation = orientation
        self.label = label
        self.value = value
    }

    /// The content and behavior of the view.
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
            .font(font)
        }
    }
}

struct VerticalTickPreview: PreviewProvider {
    static var previews: some View {
        GeometryReader { rect in
            Tick("5", orientation: .vertical, value: 5)
                .contentDisposition(minX: 0, maxX: 10, minY: 0, maxY: 10)
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

struct TickStyleEnvironmentKey: EnvironmentKey {
    static var defaultValue: AnyTickStyle = AnyTickStyle(.bottom)
}

struct TickStrokeEnvironmentKey: EnvironmentKey {
    static var defaultValue: StrokeStyle = .tiny
}

struct TickColorEnvironmentKey: EnvironmentKey {
    static var defaultValue: Color = .gray
}

struct TickFontEnvironmentKey: EnvironmentKey {
    static var defaultValue: Font = .system(.footnote).weight(.light)
}

extension EnvironmentValues {
    public var tickStyle: AnyTickStyle {
        get { self[TickStyleEnvironmentKey.self] }
        set { self[TickStyleEnvironmentKey.self] = newValue }
    }

    public var tickStroke: StrokeStyle {
        get { self[TickStrokeEnvironmentKey.self] }
        set { self[TickStrokeEnvironmentKey.self] = newValue }
    }

    public var tickColor: Color {
        get { self[TickColorEnvironmentKey.self] }
        set { self[TickColorEnvironmentKey.self] = newValue }
    }

    public var tickFont: Font {
        get { self[TickFontEnvironmentKey.self] }
        set { self[TickFontEnvironmentKey.self] = newValue }
    }
}

extension View {
    /// Sets the tick's label style in this view.
    ///
    /// You can customize your tick style appearance using ``Tick/tickStyle(_:)``
    /// modifier. This modifier controls the position of the label associated with a
    /// tick:
    ///
    /// ```swift
    /// Tick("1.00", .vertical, 1.0)
    /// .tickStyle(.trailing)
    /// ```
    ///
    /// - Parameter style: A style of a tick.
    /// - Returns: A view with modified tick style.
    public func tickStyle<S: TickStyle>(_ style: S) -> some View {
        environment(\.tickStyle, AnyTickStyle(style))
    }

    /// Sets the stroke style of the tick's path in this view.
    ///
    /// You can customize the stroke style of the tick using ``Tick/tickStroke(style:)``
    /// modifier. This modifier controls the style of a tick's stroke:
    ///
    /// ```swift
    /// Tick("Tue", .horizontal, 2.0)
    /// .tickStroke(StrokeStyle(lineWidth: 2.0, dash: [5]))
    /// ```
    ///
    /// - Parameter style: A stoke style used to decorate tick's path.
    /// - Returns: A view with modified stroke style.
    public func tickStroke(style: StrokeStyle) -> some View {
        environment(\.tickStroke, style)
    }

    /// Sets the tick's color in this view.
    ///
    /// You can customize the color of a tick using ``Tick/tickColor(_:)`` modifier.
    /// This modifier controls the color of ticks' path. Note, to modify color of a
    /// label, use ``PlotView/foregroundColor(_:)`` instead:
    ///
    /// ```swift
    /// Tick("Mar", .vertical, 3)
    /// .tickColor(.blue)
    /// .foregroundColor(.blue)
    /// ```
    ///
    /// - Parameter color: The tick color to use when displaying the tick.
    /// - Returns: A view with modified tick color.
    public func tickColor(_ color: Color) -> some View {
        environment(\.tickColor, color)
    }

    /// Sets the tick's font in this view.
    ///
    /// You can customize the font of the tick's label using ``Tick/tickFont(_:)``
    /// modifier:
    ///
    /// ```swift
    /// Tick("3pm", .vertical, 15)
    /// .tickFont(.system(.body).weight(.light))
    /// ```
    ///
    /// - Parameter font: The font to use when displaying the tick's label.
    /// - Returns: A view with modifier tick font.
    public func tickFont(_ font: Font) -> some View {
        environment(\.tickFont, font)
    }

    /// Adds a different padding amount to each edge of plot view.
    ///
    /// Use this modifier to add different amount of tick's padding on each edge of a
    /// plot view:
    ///
    /// ```swifth
    /// Tick("1 rad", .vertical, 3.14)
    /// .tickInsets(EdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 40))
    /// ```
    ///
    /// - Parameter insets: An `EdgeInsets` instance that contains padding for each edge.
    /// - Returns: A view where plot is padded by different amount on each edge.
    public func tickInsets(_ insets: EdgeInsets) -> some View {
        return viewport(insets)
    }

    /// Adds a different padding amount to each edge of plot view.
    ///
    /// If you want to customize the padding of a tick from the major axes, use
    /// ``Tick/tickInsets(top:leading:bottom:trailing:)`` modifier or
    /// ``Tick/tickInsets(_:)`` to specify insets using `EdgeInsets`.
    /// The following example sets the bottom tick size to 40 pixels:
    ///
    /// ```swift
    /// Tick("June", .horizontal, 6)
    /// .tickInsets(bottom: 40)
    /// ```
    ///
    /// - Parameters:
    ///   - top: The padding from the top edge of the view.
    ///   - leading: The padding from the left edge of the view.
    ///   - bottom: The padding from the bottom edge of the view.
    ///   - trailing: The padding from the right edge of the view.
    /// - Returns: A view with modified tick insets.
    public func tickInsets(
        top: CGFloat? = nil, leading: CGFloat? = nil, bottom: CGFloat? = nil,
        trailing: CGFloat? = nil
    ) -> some View {
        return viewport(top: top, leading: leading, bottom: bottom, trailing: trailing)
    }
}
