import Foundation
import SwiftUI

/// The properties of a tick label.
public struct TickLabelStyleConfiguration {
    /// A type-erased label of the tick.
    public typealias Label = AnyView

    /// A view that represents the label of the tick.
    public let label: TickLabelStyleConfiguration.Label

    /// An associated tick.
    public let tick: CGRect

    /// An optional padding scaled relative to footnote size.
    public let padding: CGFloat
}

/// A type that applies custom appearence to tick labels.
public protocol TickLabelStyle {
    /// A view that represents the body of a tick label.
    associatedtype Body: View

    /// The properties of a tick label.
    typealias Configuration = TickLabelStyleConfiguration

    /// Creates a view that represents the body of a tick label.
    @ViewBuilder func makeBody(configuration: Configuration) -> Body
}

public struct AnyTickLabelStyle: TickLabelStyle {
    public typealias Body = AnyView

    private let _makeBody: (Configuration) -> AnyView

    public init<S: TickLabelStyle>(_ style: S) {
        self._makeBody = { (configuration: Configuration) in
            AnyView(style.makeBody(configuration: configuration))
        }
    }

    public func makeBody(configuration: Configuration) -> AnyView {
        _makeBody(configuration)
    }
}

extension TickLabelStyle where Self == BottomTickLabelStyle {
    public static var bottom: BottomTickLabelStyle { BottomTickLabelStyle() }
}

extension TickLabelStyle where Self == BottomTrailingTickLabelStyle {
    public static var bottomTrailing: BottomTrailingTickLabelStyle {
        BottomTrailingTickLabelStyle()
    }
}

extension TickLabelStyle where Self == TrailingTickLabelStyle {
    public static var trailing: TrailingTickLabelStyle { TrailingTickLabelStyle() }
}

extension TickLabelStyle where Self == EmptyTickLabelStyle {
    public static var empty: EmptyTickLabelStyle { EmptyTickLabelStyle() }
}

/// A tick label style that does render the content at all.
public struct EmptyTickLabelStyle: TickLabelStyle {
    public func makeBody(configuration: Configuration) -> some View {
        EmptyView()
    }
}

public struct BottomTickLabelStyle: TickLabelStyle {

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

public struct BottomTrailingTickLabelStyle: TickLabelStyle {
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

public struct TrailingTickLabelStyle: TickLabelStyle {
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

public struct TickLabel: View {
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

    public func tickLabelStyle<S: TickLabelStyle>(_ style: S) -> some View {
        GeometryReader { rect in
            style
                .makeBody(
                    configuration: TickLabelStyleConfiguration(
                        label: TickLabelStyleConfiguration.Label(Text(label)),
                        tick: tick.boundingRect,
                        padding: padding
                    )
                )
                .font(.system(.footnote).weight(.light))
        }
    }
}

extension Shape {
    private func boundingRect(_ rect: GeometryProxy) -> CGRect {
        return CGRect(origin: CGPoint(), size: rect.size)
    }

    public func tickLabel<S: TickLabelStyle>(_ label: LocalizedStringKey, style: S) -> some View {
        GeometryReader { rect in
            TickLabel(label, tick: path(in: boundingRect(rect))).tickLabelStyle(style)
            self
        }
    }

    public func tickLabel(_ label: LocalizedStringKey) -> some View {
        GeometryReader { rect in
            TickLabel(label, tick: path(in: boundingRect(rect)))
            self
        }
    }
}
