import Foundation
import SwiftUI

public struct BarView<Style: ShapeStyle>: FuncView {

    private var x: [Double]
    private var heights: [Double]

    private var _domain: Numbers
    private var _image: Numbers

    // Fill style of the bars.
    private var fillStyle: Style
    private var radius: CGFloat = 2
    private var width: CGFloat = 5

    public var domain: Numbers { _domain }
    public var image: Numbers { _image }

    internal init(
        _ x: [Double],
        _ heights: [Double],
        _ domain: Numbers,
        _ image: Numbers,
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
            let width = max(0, rect.size.width - 40)
            let height = max(0, rect.size.height - 40)

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
        heights: [Double],
        domain: Numbers? = nil,
        image: Numbers? = nil
    ) {
        self.x = x
        self.heights = heights

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
