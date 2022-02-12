import Foundation
import SwiftUI



public struct BarView<Style: ShapeStyle>: FuncView {

    private var x: [Double]
    private var y: [Double]

    private var _disposition: ContentDisposition

    // Fill style of the bars.
    private var fillStyle: Style
    private var radius: CGFloat = 2
    private var width: CGFloat = 5

    public var disposition: ContentDisposition { _disposition }

    internal init(
        _ x: [Double],
        _ y: [Double],
        _ disposition: ContentDisposition,
        _ fillStyle: Style
    ) {
        self.x = x
        self.y = y
        self._disposition = disposition
        self.fillStyle = fillStyle
    }

    public var body: some View {
        GeometryReader { rect in
            let width = max(0, rect.size.width - 40)
            let height = max(0, rect.size.height - 40)

            let xScale = width / CGFloat(disposition.bounds.width)
            let yScale = height / CGFloat(disposition.bounds.height)

            let cornerSize = CGSize(width: radius, height: radius)

            Path { path in
                x.indices.forEach { i in
                    let xpos = (x[i] - disposition.bounds.bottom) * xScale
                    let ypos = min(max(0, y[i] * yScale), height)

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
        y: [Double],
        disposition: ContentDisposition? = nil
    ) {
        self.x = x
        self.y = y

        // If data limits are not specified, try to calculate the maximum
        // value from the provided data array, then set to 1.0 if the array
        // is empty.
        self._disposition = disposition ?? ContentDisposition(
            left: x.min(), right: x.max(), bottom: y.min(), top: y.max()
        )

        // Set default fill style, which is just a gray color.
        self.fillStyle = .gray
    }
}

extension BarView {
    public func fill<S: ShapeStyle>(_ style: S) -> BarView<S> {
        return BarView<S>(x, y, disposition, style)
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
