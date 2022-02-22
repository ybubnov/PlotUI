import Foundation
import SwiftUI

public struct ContentDisposition: Equatable {
    public struct Bounds: Equatable {
        internal var _left: Double?
        internal var _right: Double?
        internal var _bottom: Double?
        internal var _top: Double?

        public var left: Double { _left ?? 0 }
        public var right: Double { max(_right ?? 1, left + 1) }
        public var bottom: Double { _bottom ?? 0 }
        public var top: Double { max(_top ?? 1, bottom + 1) }

        public init(
            left: Double? = nil, right: Double? = nil, bottom: Double? = nil, top: Double? = nil
        ) {
            _left = left
            _right = right
            _bottom = bottom
            _top = top
        }

        /// Returns the width of the bounds.
        public var width: Double { abs(right - left) }

        /// Returns the height of the bounds.
        public var height: Double { abs(top - bottom) }

        /// Returns a Boolean value indicating whether two values are equal.
        public static func == (lhs: Bounds, rhs: Bounds) -> Bool {
            return
                lhs.left == rhs.left && lhs.right == rhs.right && lhs.bottom == rhs.bottom
                && lhs.top == rhs.top
        }
    }

    public var bounds: Bounds

    public init(bounds: Bounds) {
        self.bounds = bounds
    }

    public init(
        left: Double? = nil, right: Double? = nil, bottom: Double? = nil, top: Double? = nil
    ) {
        self.bounds = Bounds(left: left, right: right, bottom: bottom, top: top)
    }

    /// Returns a content disposition with positive width and height.
    public var standardized: ContentDisposition {
        ContentDisposition(left: 0, right: bounds.width, bottom: 0, top: bounds.height)
    }

    /// Returns a Boolean value indicating whether two values are equal.
    public static func == (lhs: ContentDisposition, rhs: ContentDisposition) -> Bool {
        return lhs.bounds == rhs.bounds
    }

    public func horizontalOffset(at: Int, partition: Int) -> Double {
        return bounds.left + bounds.width / Double(partition) * Double(at)
    }

    public func verticalOffset(at: Int, partition: Int) -> Double {
        return bounds.bottom + bounds.height / Double(partition) * Double(at)
    }

    public subscript<H: Sequence, V: Sequence>(h: H, v: V) -> ([Double], [Double])
    where H.Element == Int, V.Element == Int {
        let hpartition = h.max() ?? 1
        let vpartition = v.max() ?? 1

        let hslice = h.map { at in horizontalOffset(at: at, partition: hpartition) }
        let vslice = v.map { at in verticalOffset(at: at, partition: vpartition) }
        return (hslice, vslice)
    }

    public func merge(_ other: ContentDisposition) -> ContentDisposition {
        return ContentDisposition(
            left: bounds._left ?? other.bounds._left,
            right: bounds._right ?? other.bounds._right,
            bottom: bounds._bottom ?? other.bounds._bottom,
            top: bounds._top ?? other.bounds._top
        )
    }
}

struct ContentDispositionEnvironmentKey: EnvironmentKey {
    static var defaultValue = ContentDisposition()
}

extension EnvironmentValues {
    public var contentDisposition: ContentDisposition {
        get { self[ContentDispositionEnvironmentKey.self] }
        set { self[ContentDispositionEnvironmentKey.self] = newValue }
    }
}

extension View {
    public func contentDisposition(
        left: Double? = nil, right: Double? = nil, bottom: Double? = nil, top: Double? = nil
    ) -> some View {
        @Environment(\.contentDisposition) var oldValue
        let newValue = ContentDisposition(left: left, right: right, bottom: bottom, top: top)

        return environment(\.contentDisposition, newValue.merge(oldValue))
    }

    public func contentDisposition(_ disposition: ContentDisposition) -> some View {
        return environment(\.contentDisposition, disposition)
    }
}

/// A view that represents plotting data.
public protocol FuncView: View {
    /// The content disposition of the data.
    var disposition: ContentDisposition { get }
}

/// A type-erased FuncView view.
///
/// An `AnyFuncView` allows changing the type of the `FuncView` used in a given view
/// hierarchy. Whenever the type of view used with an `AnyFuncView` changes, the old
/// hierarchy is destroyed and a new hierarchy is created for the new type.
public struct AnyFuncView: FuncView {
    /// The type of view representing the body of this view.
    public typealias Body = AnyView

    private var _disposition: ContentDisposition
    private var _view: AnyView

    /// Creates an instance that type-erases `view`.
    public init<V: FuncView>(_ view: V) {
        self._view = AnyView(view)
        self._disposition = view.disposition
    }

    /// The limits of the content.
    public var disposition: ContentDisposition {
        self._disposition
    }

    /// The content and behavior of the view.
    public var body: AnyView {
        _view
    }
}
