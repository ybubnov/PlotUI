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

/// A type that applies custom appearence to tick labels.
public protocol TickStyle {
    /// A view that represents the body of a tick label.
    associatedtype Body: View

    /// The properties of a tick label.
    typealias Configuration = TickStyleConfiguration

    /// Creates a view that represents the body of a tick label.
    @ViewBuilder func makeBody(configuration: Configuration) -> Body
}

public struct AnyTickStyle: TickStyle {
    public typealias Body = AnyView

    private let _makeBody: (Configuration) -> AnyView

    public init<S: TickStyle>(_ style: S) {
        self._makeBody = { (configuration: Configuration) in
            AnyView(style.makeBody(configuration: configuration))
        }
    }

    public func makeBody(configuration: Configuration) -> AnyView {
        _makeBody(configuration)
    }
}

extension TickStyle where Self == BottomTickStyle {
    public static var bottom: BottomTickStyle { BottomTickStyle() }
}

extension TickStyle where Self == BottomTrailingTickStyle {
    public static var bottomTrailing: BottomTrailingTickStyle {
        BottomTrailingTickStyle()
    }
}

extension TickStyle where Self == TrailingTickStyle {
    public static var trailing: TrailingTickStyle { TrailingTickStyle() }
}

extension TickStyle where Self == EmptyTickStyle {
    public static var empty: EmptyTickStyle { EmptyTickStyle() }
}

/// A tick label style that does render the content at all.
public struct EmptyTickStyle: TickStyle {
    public func makeBody(configuration: Configuration) -> some View {
        EmptyView()
    }
}

public struct BottomTickStyle: TickStyle {

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

public struct BottomTrailingTickStyle: TickStyle {
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

public struct TrailingTickStyle: TickStyle {
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

struct TickStyleEnvironmentKey: EnvironmentKey {
    static var defaultValue: AnyTickStyle = AnyTickStyle(.bottom)
}

extension EnvironmentValues {
    public var tickStyle: AnyTickStyle {
        get { self[TickStyleEnvironmentKey.self] }
        set { self[TickStyleEnvironmentKey.self] = newValue }
    }
}

extension View {
    public func tickStyle<S: TickStyle>(_ style: S) -> some View {
        environment(\.tickStyle, AnyTickStyle(style))
    }
}
