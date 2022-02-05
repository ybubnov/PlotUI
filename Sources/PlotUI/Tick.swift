import Foundation
import SwiftUI


public protocol TickLabelStyle {
    associatedtype Body : View
    
    func position(axis: CGRect, tick: Text) -> Body
}

public struct AnyTickLabelStyle: TickLabelStyle {
    
    public typealias Body = AnyView
    
    private let parentPosition: (CGRect, Text) -> AnyView

    public init<S: TickLabelStyle>(_ style: S) {
        self.parentPosition = {(axis: CGRect, tick: Text) in
            AnyView(style.position(axis: axis, tick: tick))
        }
    }

    public func position(axis: CGRect, tick: Text) -> AnyView {
        return parentPosition(axis, tick)
    }
}

public struct TickLabelStyleConfiguration {
    /// A type-erased label of a tick.
    public struct Label : View {
        /// The type of view representing the body of this view.
        public var body: Never
    }
    
    public let axis: CGRect
    
    public let label: TickLabelStyleConfiguration.Label

    public let fontSize: CGFloat = 10
    
    public let fontWeight: Font.Weight = .light
}

extension TickLabelStyleConfiguration {
    public func font() -> Font {
        return .system(size: fontSize, weight: fontWeight)
    }
}

extension TickLabelStyle where Self == BottomTickLabelStyle {
    public static var bottom: BottomTickLabelStyle { BottomTickLabelStyle() }
}


extension TickLabelStyle where Self == BottomTrailingTickLabelStyle {
    public static var bottomTrailing: BottomTrailingTickLabelStyle { BottomTrailingTickLabelStyle() }
}


extension TickLabelStyle where Self == TrailingTickLabelStyle {
    public static var trailing: TrailingTickLabelStyle { TrailingTickLabelStyle() }
}


extension TickLabelStyle where Self == EmptyTickLabelStyle {
    public static var empty: EmptyTickLabelStyle { EmptyTickLabelStyle() }
}


public struct EmptyTickLabelStyle: TickLabelStyle {
    public func position(axis: CGRect, tick: Text) -> some View {
        EmptyView()
    }
}


public struct BottomTickLabelStyle: TickLabelStyle {
    public var fontSize: CGFloat = 10
    public var fontWeight: Font.Weight = .light
    
    public func position(axis: CGRect, tick: Text) -> some View {
        let pos = CGSize(width: axis.maxX, height: axis.maxY + fontSize)
        
        return tick
            .font(font())
            .position(x: pos.width, y: pos.height)
    }
    
    public func font() -> Font {
        return .system(size: fontSize, weight: fontWeight)
    }
}


public struct BottomTrailingTickLabelStyle: TickLabelStyle {
    public var fontSize: CGFloat = 10
    public var fontWeight: Font.Weight = .light
    
    public func position(axis: CGRect, tick: Text) -> some View {
        let pos = CGSize(width: axis.maxX, height: axis.maxY)

        return tick
            .font(font())
            .offset(x: pos.width + fontSize/4, y: pos.height - fontSize)
    }
    
    public func font() -> Font {
        return .system(size: fontSize, weight: fontWeight)
    }
}


public struct TrailingTickLabelStyle: TickLabelStyle {
    public var fontSize: CGFloat = 10
    public var fontWeight: Font.Weight = .light
    
    public func position(axis: CGRect, tick: Text) -> some View {
        let pos = CGSize(width: axis.maxX + fontSize/3, height: axis.maxY - (fontSize * 2 / 3))

        return tick
            .font(font())
            .offset(x: pos.width, y: pos.height)
    }
    
    public func font() -> Font {
        return .system(size: fontSize, weight: fontWeight)
    }
}


public struct TickLabel: View {
    public var label: LocalizedStringKey
    public var axis: Path
    
    public init(_ label: LocalizedStringKey, axis: Path) {
        self.label = label
        self.axis = axis
    }
    
    public var body: some View {
        Text(label)
    }
}

extension TickLabel {
    
    public func tickLabelStyle<S: TickLabelStyle>(_ style: S) -> some View {
        GeometryReader { rect in
            style.position(axis: axis.boundingRect, tick: Text(label))
        }
    }
}


extension Shape {
    private func boundingRect(_ rect: GeometryProxy) -> CGRect {
        return CGRect(origin: CGPoint(), size: rect.size)
    }
    
    public func tickLabel<S: TickLabelStyle>(_ label: LocalizedStringKey, style: S) -> some View {
        GeometryReader { rect in
            TickLabel(label, axis: path(in: boundingRect(rect))).tickLabelStyle(style)
            self
        }
    }
    
    public func tickLabel(_ label: LocalizedStringKey) -> some View {
        GeometryReader { rect in
            TickLabel(label, axis: path(in: boundingRect(rect)))
            self
        }
    }
}
