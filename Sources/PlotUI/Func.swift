import Foundation
import SwiftUI

/// The bounds of function's domain and image within a hierarchy of `PlotView`.
/// 
/// You can configure the visible area of a data by adjusting it's content disposition.
/// By default, content disposition is taken from the ``FuncView/disposition``,
/// while in practice it might be needed to specify fixed bounds of a function.
///
/// In the following example, an X axis is limited by `[0; 100]` range and an Y axis
/// is limited by `[0; 10]`.
/// ```swift
/// var disposition = ContentDisposition(minX: 0, maxX: 100, minY: 0, maxY: 10)
/// ```
///
/// Use ``PlotView/contentDisposition(minX:maxX:minY:maxY:)`` to partially update
/// the content disposition or ``PlotView/contentDisposition(_:)`` to completely
/// override the content disposition within a view hierarchy.
public struct ContentDisposition: Equatable, CustomStringConvertible {
    internal var _minX: Double?
    internal var _maxX: Double?
    internal var _minY: Double?
    internal var _maxY: Double?

    /// Returns the smallest value of the x-coordinate of the X axis.
    public var minX: Double { _minX ?? 0 }

    /// Returns the largest value of the x-coordinate of the X axis.
    public var maxX: Double { max(_maxX ?? 1, minX + 1) }

    /// Returns the smallest value of the y-coordinate of the Y axis.
    public var minY: Double { _minY ?? 0 }

    /// Returns the largest value of the y-coordinate of the Y axis.
    public var maxY: Double { max(_maxY ?? 1, minY + 1) }

    /// Returns the width of the X axis.
    ///
    /// This function returns the width as if the content disposition were standardized.
    ///
    /// - Parameter contentDisposition: The content disposition to examine.
    /// - Returns: the width of the X axis.
    public var width: Double { abs(maxX - minX) }

    /// Returns the height of the Y axis.
    ///
    /// This function returns the height as if the content disposition were standardized.
    ///
    /// - Parameter contentDisposition: The content disposition to examine.
    /// - Returns: the heigh of the Y axis.
    public var height: Double { abs(maxY - minY) }

    /// Creates a content disposition from explicit upper and lower bounds of the
    /// corresponding axes.
    ///
    /// - Parameters:
    ///   - minX: A lower bound of an X axis.
    ///   - maxX: An upper bound of an X axis.
    ///   - minY: A lower bound of an Y axis.
    ///   - maxY: An upper bound of an Y axis.
    public init(
        minX: Double? = nil, maxX: Double? = nil, minY: Double? = nil, maxY: Double? = nil
    ) {
        _minX = minX
        _maxX = maxX
        _minY = minY
        _maxY = maxY
    }

    /// A textual representation of this instance.
    public var description: String {
        return "([\(minX), \(maxX)], [\(minY), \(maxY)])"
    }

    /// Returns a content disposition with positive width and height.
    ///
    /// - Parameter contentDisposition: The source content disposition.
    /// - Returns: A content disposition that represents the source disposition, but
    /// with positive width and height values.
    public var standardized: ContentDisposition {
        ContentDisposition(minX: 0, maxX: width, minY: 0, maxY: height)
    }

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`, `a == b`
    /// implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: ContentDisposition, rhs: ContentDisposition) -> Bool {
        return
            lhs.minX == rhs.minX && lhs.maxX == rhs.maxX && lhs.minY == rhs.minY
            && lhs.maxY == rhs.maxY
    }

    /// Returns coordinates of the partitioned content disposition space.
    ///
    /// You can use it to calculate positions for equidistant ticks for both X and Y axes.
    /// For example, to partition the X axis by 4 parts and Y axis by 2 parts, use the
    /// following:
    ///
    /// ```swift
    /// let disposition = ContentDisposition(minX: -10, maxX: 10, minY: -3, maxY: 3)
    /// let (xticks, yticks) = disposition[0...4, 0...2]
    ///
    /// print(xticks)
    /// // [-10.0, 5.0, 0.0, 5.0, 10.0]
    ///
    /// print(yticks)
    /// // [-3.0, 0.0, 3]
    /// ```
    ///
    /// - Parameters:
    ///   - h: A list of partitions of X axis.
    ///   - v: A list of partitions of Y axis.
    public subscript<H: Sequence, V: Sequence>(h: H, v: V) -> ([Double], [Double])
    where H.Element == Int, V.Element == Int {
        let horizontalPartitions = h.max() ?? 1
        let verticalPartitions = v.max() ?? 1

        let hSlice = h.map { partition in
            minX + width / Double(horizontalPartitions) * Double(partition)
        }
        let vSlice = v.map { partition in
            minY + height / Double(verticalPartitions) * Double(partition)
        }
        return (hSlice, vSlice)
    }

    /// Merges the bounds of the source content disposition with `other` disposition,
    /// prioritizing the bounds of the source disposition.
    ///
    /// The following example show how the function works:
    /// ```swift
    /// // If bounds are not defined, it's lower value is defaulted to 0.0
    /// // and upper value is defaulted to 1.0
    /// let d1 = ContentDisposition(minX: -4)
    /// let d2 = ContentDisposition(minX: 0, maxX: 5)
    ///
    /// let d3 = d1.merge(d2)
    /// print(d3)
    /// // ([-4, 5], [0, 1])
    ///
    /// let d4 = d2.merge(d1)
    /// print(d4)
    /// // ([0, 5], [0, 1])
    /// ```
    ///
    /// - Parameters other: A content disposition to merge.
    /// - Returns: A new content disposition, where source bounds are updated with
    /// bounds from `other` disposition if source bounds are set to `nil`.
    public func merge(_ other: ContentDisposition) -> ContentDisposition {
        return ContentDisposition(
            minX: _minX ?? other._minX,
            maxX: _maxX ?? other._maxX,
            minY: _minY ?? other._minY,
            maxY: _maxY ?? other._maxY
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
    /// Modifies the content disposition of plot views within a view hierarchy.
    ///
    /// Use this modifier to adjust bounds for each axis of a ``PlotView``. You can use
    /// this modifier to shift the lower and upper bounds for X axis:
    ///
    /// ```swift
    /// PlotView {
    ///     BarView(x: [1, 2], y: [10, 20])
    /// }
    /// .contentDisposition(minX: 0, maxX: 5)
    /// // Content disposition is: ([0, 5], [10, 20])
    /// ```
    /// 
    /// And also Y axis:
    ///
    /// ```swift
    /// PlotView {
    ///     BarView(x: [1, 2], y: [10, 20])
    /// }
    /// .contentDisposition(minY: -10, maxY: 30)
    /// // Content disposition is: ([1, 2], [-10, 30])
    /// ```
    ///
    /// The specified values are merged into the existing content disposition using
    /// the ``ContentDisposition/merge(_:)`` method. Use ``PlotView/contentDisposition(_:)``
    /// to set completely new content disposition.
    ///
    /// - Parameters:
    ///   - minX: A lower bound of an X axis.
    ///   - maxX: An upper bound of an X axis.
    ///   - minY: A lower bound of an Y axis.
    ///   - maxY: An upper bound of an Y axis.
    /// - Returns: A view with modified content disposition.
    public func contentDisposition(
        minX: Double? = nil, maxX: Double? = nil, minY: Double? = nil, maxY: Double? = nil
    ) -> some View {
        @Environment(\.contentDisposition) var oldValue
        let newValue = ContentDisposition(minX: minX, maxX: maxX, minY: minY, maxY: maxY)

        return environment(\.contentDisposition, newValue.merge(oldValue))
    }

    /// Sets new content disposition for plot views within a view hierarchy.
    ///
    /// Use this modifier to override existing content disposition of a ``PlotView``:
    ///
    /// ```swift
    /// PlotView {
    ///     BarView(x: [1, 2], y: [10, 20])
    /// }
    /// .contentDisposition(ContentDisposition(minX: 0, maxX: 100, minY: 0, maxY: 100))
    /// // Content disposition is ([0, 100], [0, 100])
    /// ```
    ///
    /// Use ``PlotView/contentDisposition(minX:maxX:minY:maxY:)`` to adjust existing
    /// content disposition of a plot.
    ///
    /// - Parameter disposition: A new content disposition.
    /// - Returns: A view with modified content disposition.
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
