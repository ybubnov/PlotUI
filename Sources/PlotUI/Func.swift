import Foundation
import SwiftUI

public class ContentDisposition: ObservableObject, Equatable {
    public struct Bounds: Equatable {
        public var left: Double
        public var right: Double
        public var bottom: Double
        public var top: Double

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

    @Published var bounds: Bounds

    public init(bounds: Bounds) {
        self.bounds = bounds
    }

    public init(left: Double, right: Double, bottom: Double, top: Double) {
        self.bounds = Bounds(left: left, right: right, bottom: bottom, top: top)
    }

    public init() {
        self.bounds = Bounds(left: 0.0, right: 1.0, bottom: 0.0, top: 1.0)
    }

    public init(left: Double?, right: Double?, bottom: Double?, top: Double?) {
        self.bounds = Bounds(
            left: left ?? 0.0, right: right ?? 1.0, bottom: bottom ?? 0.0, top: top ?? 1.0)
    }

    /// Returns a content disposition with positive width and height.
    public var standardized: ContentDisposition {
        ContentDisposition(left: 0, right: bounds.width, bottom: 0, top: bounds.height)
    }

    /// Returns a Boolean value indicating whether two values are equal.
    public static func == (lhs: ContentDisposition, rhs: ContentDisposition) -> Bool {
        return lhs.bounds == rhs.bounds
    }
}

public protocol FuncView: View {
    var disposition: ContentDisposition { get }
}

/// A type-erased FuncView view.
public struct AnyFuncView: FuncView {

    public typealias Body = AnyView

    private var _disposition: ContentDisposition
    private var _view: AnyView

    public init<V: FuncView>(_ view: V) {
        self._view = AnyView(view)
        self._disposition = view.disposition
    }

    public var disposition: ContentDisposition {
        self._disposition
    }

    public var body: AnyView {
        _view
    }
}
