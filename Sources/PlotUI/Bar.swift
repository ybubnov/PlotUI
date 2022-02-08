import Foundation
import SwiftUI

public protocol FuncView: View {

    var domain: ClosedRange<Double> { get }

    var image: ClosedRange<Double> { get }
}

public struct AnyFuncView: FuncView {

    public typealias Body = AnyView

    private var _domain: ClosedRange<Double>
    private var _image: ClosedRange<Double>
    private var _view: AnyView

    public init<V: FuncView>(_ view: V) {
        self._view = AnyView(view)
        self._domain = view.domain
        self._image = view.image
    }

    public var domain: ClosedRange<Double> { _domain }

    public var image: ClosedRange<Double> { _image }

    public var body: AnyView {
        _view
    }

}

extension ClosedRange where Bound == Double {

    var length: Double { abs(upperBound - lowerBound) }
}

public struct BarView<Style: ShapeStyle>: FuncView {

    private var x: [Double]
    private var heights: [Double]

    private var _domain: ClosedRange<Double>
    private var _image: ClosedRange<Double>

    // Fill style of the bars.
    private var fillStyle: Style
    private var radius: CGFloat = 2
    private var width: CGFloat = 5

    public var domain: ClosedRange<Double> { _domain }
    public var image: ClosedRange<Double> { _image }

    internal init(
        _ x: [Double],
        _ heights: [Double],
        _ domain: ClosedRange<Double>,
        _ image: ClosedRange<Double>,
        _ fillStyle: Style
    ) {
        self.x = x
        self.heights = heights
        self._domain = domain
        self._image = image
        self.fillStyle = fillStyle
    }

    public var body: some View {
        GeometryReader { rect in
            let width = rect.size.width - 40
            let height = rect.size.height - 40

            let xScale = width / CGFloat(domain.length)
            let yScale = height / CGFloat(image.length)

            let cornerSize = CGSize(width: radius, height: radius)

            Path { path in
                x.indices.forEach { i in
                    let xpos = (x[i] - domain.lowerBound) * xScale
                    let ypos = min(max(0, heights[i] * yScale), height)

                    // Draw the bar only if its x-axis position is within the view range.
                    // In case, when y does not fit into the view, draw only visible part.
                    if (0...width).contains(xpos) {
                        let x = xpos - self.width / 2
                        let y = height - ypos

                        // TODO: what if the rectangle width out of the visible area?
                        let roundedRect = CGRect(x: x, y: y, width: self.width, height: ypos)

                        path.addRoundedRect(in: roundedRect, cornerSize: cornerSize)
                    }
                }
            }
            .fill(fillStyle)
        }
    }
}

extension BarView where Style == Color {
    public init(
        x: [Double],
        height: [Double],
        domain: ClosedRange<Double>? = nil,
        image: ClosedRange<Double>? = nil
    ) {
        self.x = x
        self.heights = height

        // If data limits are not specified, try to calculate the maximum
        // value from the provided data array, then set to 1.0 if the array
        // is empty.
        self._domain = domain ?? ((x.min() ?? 0.0)...(x.max() ?? 1.0))
        self._image = image ?? ((heights.min() ?? 0.0)...(heights.max() ?? 1.0))

        // Set default fill style, which is just a gray color.
        self.fillStyle = .gray
    }
}

extension BarView {
    public func fill<S: ShapeStyle>(_ style: S) -> BarView<S> {
        return BarView<S>(x, heights, domain, image, style)
    }

    public func barCornerRadius(_ radius: CGFloat) -> BarView {
        var view = self
        view.radius = radius
        return view
    }

    public func barWidth(_ width: CGFloat) -> BarView {
        var view = self
        view.width = width
        return view
    }
}
