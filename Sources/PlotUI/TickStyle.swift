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
        let pos = CGSize(
            width: configuration.tick.maxX,
            height: configuration.tick.maxY + configuration.padding
        )

        configuration
            .label
            .position(x: pos.width, y: pos.height)
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

/*
public struct Label: View {
    public var label: LocalizedStringKey
    public var tick: Path

    @ScaledMetric(relativeTo: .body) var padding = 10

    public init(_ label: LocalizedStringKey, tick: Path) {
        self.label = label
        self.tick = tick
    }

    public var body: some View {
        Text(label)
    }

    public func labelStyle<S: TickStyle>(_ style: S) -> some View {
        GeometryReader { rect in
            style
                .makeBody(
                    configuration: TickStyleConfiguration(
                        label: TickStyleConfiguration.Label(Text(label)),
                        tick: tick.boundingRect,
                        padding: padding
                    )
                )
                .font(.system(.footnote).weight(.light))
        }
    }
}
*/

extension Shape {
    private func boundingRect(_ rect: GeometryProxy) -> CGRect {
        return CGRect(origin: CGPoint(), size: rect.size)
    }

    //    public func label<S: TickStyle>(_ label: LocalizedStringKey, style: S) -> some View {
    //        GeometryReader { rect in
    //            Label(label, tick: path(in: boundingRect(rect))).labelStyle(style)
    //            self
    //        }
    //    }
    //
    //    public func label(_ label: LocalizedStringKey) -> some View {
    //        GeometryReader { rect in
    //            Label(label, tick: path(in: boundingRect(rect)))
    //            self
    //        }
    //    }
}

struct TickStyleEnvironmentKey: EnvironmentKey {
    static var defaultValue: AnyTickStyle = AnyTickStyle(.bottom)
}

struct HorizontalTickStyleEnvironmentKey: EnvironmentKey {
    static var defaultValue: AnyTickStyle = AnyTickStyle(.trailing)
}

struct VerticalTickStyleEnvironmentKey: EnvironmentKey {
    static var defaultValue: AnyTickStyle = AnyTickStyle(.bottomTrailing)
}

extension EnvironmentValues {
    public var tickStyle: AnyTickStyle {
        get { self[TickStyleEnvironmentKey.self] }
        set { self[TickStyleEnvironmentKey.self] = newValue }
    }

    public var horizontalTickStyle: AnyTickStyle {
        get { self[HorizontalTickStyleEnvironmentKey.self] }
        set { self[HorizontalTickStyleEnvironmentKey.self] = newValue }
    }

    public var verticalTickStyle: AnyTickStyle {
        get { self[VerticalTickStyleEnvironmentKey.self] }
        set { self[VerticalTickStyleEnvironmentKey.self] = newValue }
    }
}

extension View {
    public func tickStyle<S: TickStyle>(_ style: S) -> some View {
        environment(\.tickStyle, AnyTickStyle(style))
    }

    public func horizontalTickStyle<S: TickStyle>(_ style: S) -> some View {
        environment(\.horizontalTickStyle, AnyTickStyle(style))
    }

    public func verticalTickStyle<S: TickStyle>(_ style: S) -> some View {
        environment(\.verticalTickStyle, AnyTickStyle(style))
    }
}
