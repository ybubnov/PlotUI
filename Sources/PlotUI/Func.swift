import Foundation
import SwiftUI

public protocol FuncView: View {
    /// The type that represents the numbers that are valid for domain and image
    /// of the function view.
    typealias Numbers = ClosedRange<Double>

    /// The set of inputs accepted by the function.
    var domain: Numbers { get }

    /// The set of all output values the function may produce.
    var image: Numbers { get }
}

/// A type-erased FuncView view.
public struct AnyFuncView: FuncView {

    public typealias Body = AnyView

    private var _domain: Numbers
    private var _image: Numbers
    private var _view: AnyView

    public init<V: FuncView>(_ view: V) {
        self._view = AnyView(view)
        self._domain = view.domain
        self._image = view.image
    }

    public var domain: Numbers { _domain }

    public var image: Numbers { _image }

    public var body: AnyView {
        _view
    }

}

extension ClosedRange where Bound == Double {
    /// The absolute difference between upper and lower bounds.
    var length: Double { abs(upperBound - lowerBound) }
}
