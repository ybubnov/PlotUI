import Foundation
import SwiftUI

/// The properties of a tick label.
public struct TickStyleConfiguration {
    /// A type-erased label of the tick.
    public typealias Label = AnyView

    /// A view that represents the label of the tick.
    public let label: TickStyleConfiguration.Label

    /// An associated tick.
    public let tick: CGRect

    /// A tick orientation, either horizontal or vertical.
    public let orientation: TickOrientation

    /// An optional padding scaled relative to footnote size.
    public let padding: CGFloat
}

/// A type that applies custom appearance to tick labels.
///
/// To configure the current tick style for a view hierarchy, use the
/// ``PlotView/tickStyle(_:)`` modifier. Specify a style that conforms `TickStyle` to
/// create a tick with custom appearance.
public protocol TickStyle {
    /// A view that represents the body of a tick label.
    associatedtype Body: View

    /// The properties of a tick label.
    typealias Configuration = TickStyleConfiguration

    /// Creates a view that represents the body of a tick label.
    @ViewBuilder func makeBody(configuration: Configuration) -> Body
}

/// A type-erased TickStyle value.
public struct AnyTickStyle: TickStyle {
    public typealias Body = AnyView

    private let _makeBody: (Configuration) -> AnyView

    /// Creates an instance from `style`.
    public init<S: TickStyle>(_ style: S) {
        self._makeBody = { (configuration: Configuration) in
            AnyView(style.makeBody(configuration: configuration))
        }
    }

    /// Creates a view that represents the body of a tick label.
    public func makeBody(configuration: Configuration) -> AnyView {
        _makeBody(configuration)
    }
}

extension TickStyle where Self == BottomTickStyle {
    /// A tick style that decorates the tick with a label below tick's position.
    public static var bottom: BottomTickStyle { BottomTickStyle() }
}

extension TickStyle where Self == BottomTrailingTickStyle {
    /// A tick style that decorates the tick with a label below tick's position
    /// and aligns it to the right.
    public static var bottomTrailing: BottomTrailingTickStyle {
        BottomTrailingTickStyle()
    }
}

extension TickStyle where Self == TrailingTickStyle {
    /// A tick style that decorates the tick with a label that is aligned to the right
    /// relative to the tick's position.
    public static var trailing: TrailingTickStyle { TrailingTickStyle() }
}

extension TickStyle where Self == PlainTickStyle {
    /// A tick style without decorations.
    public static var plain: PlainTickStyle { PlainTickStyle() }
}

/// A tick style without decorations.
///
/// To apply this style to a tick, or to a view that contains ticks, use the
/// ``PlotView/tickStyle(_:)`` modifier.
public struct PlainTickStyle: TickStyle {
    /// Creates a view that represents the body of a tick label.
    public func makeBody(configuration: Configuration) -> some View {
        EmptyView()
    }
}

/// A tick style that decorates the tick with a label below tick's position.
///
/// To apply this style to a tick, or to a view that contains ticks, use the
/// ``PlotView/tickStyle(_:)`` modifier.
public struct BottomTickStyle: TickStyle {
    /// Creates a view that represents the body of a tick label.
    public func makeBody(configuration: Configuration) -> some View {
        if configuration.orientation == .vertical {
            return AnyView(
                configuration
                    .label
                    .position(
                        x: configuration.tick.maxX,
                        y: configuration.tick.maxY + configuration.padding
                    )
            )
        }
        return AnyView(
            configuration
                .label
                .offset(
                    x: configuration.tick.maxX + configuration.padding,
                    y: configuration.tick.maxY
                )
        )
    }
}

/// A tick style that decorates the tick with a label below tick's position
/// and aligns it to the right.
///
/// To apply this style to a tick, or to a view that contains ticks, use the
/// ``PlotView/tickStyle(_:)`` modifier.
public struct BottomTrailingTickStyle: TickStyle {
    /// Creates a view that represents the body of a tick label.
    public func makeBody(configuration: Configuration) -> some View {
        let pos = CGSize(width: configuration.tick.maxX, height: configuration.tick.maxY)

        configuration
            .label
            .offset(
                x: pos.width + configuration.padding / 4,
                y: pos.height - configuration.padding
            )
    }
}

/// A tick style that decorates the tick with a label that is aligned to the right
/// relative to the tick's position.
///
/// To apply this style to a tick, or to a view that contains ticks, use the
/// ``PlotView/tickStyle(_:)`` modifier.
public struct TrailingTickStyle: TickStyle {
    /// Creates a view that represents the body of a tick label.
    public func makeBody(configuration: Configuration) -> some View {
        let pos = CGSize(
            width: configuration.tick.maxX + configuration.padding / 3,
            height: configuration.tick.maxY - (configuration.padding * 2 / 3)
        )

        configuration
            .label
            .offset(x: pos.width, y: pos.height)
    }
}

extension Shape {
    private func boundingRect(_ rect: GeometryProxy) -> CGRect {
        return CGRect(origin: CGPoint(), size: rect.size)
    }
}
