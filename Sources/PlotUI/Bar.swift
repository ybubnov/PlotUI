import Foundation
import SwiftUI

/// A view that represents the data with rectangular vertical bars with height 
/// proportional to values that thay represent.
///
/// You can create a bar view by providing horizontal and vertical coordinates:
///
/// ```swift
/// BarView(
///     x: [1, 2, 3, 4, 5],
///     y: [10, 20, 30, 40, 50]
/// )
/// ```
/// Usually `BarView` is used within ``PlotView`` container that automatically defines
/// axes with appropriate ticks. By default, vertical limit is set to `0`, to render
/// only positive bars. You can use ``PlotView/contentDisposition(minX:maxX:minY:maxY:)``
/// to adjust the limits of the axes and include negative values into the view.
///
/// ## Styling Bar Views
///
/// You can customize the width of the bars within the view using ``BarView/barWidth(_:)``
/// view modifier:
/// ```swift
/// PlotView {
///     BarView(
///         x: [1, 3, 5],
///         y: [10, 20, 15]
///     )
///     .barWidth(20)
/// }
/// .tickInsets(bottom: 20)
/// .contentDisposition(minX: 0, maxX: 10)
/// ```
/// ![A bar view with 20-pixels wide bars](barview-barwidth.png)
/// 
/// You can also change the default color of the bar using ``BarView/barColor(_:)``:
/// ```swift
/// PlotView {
///     BarView(
///         x: [1, 3, 5],
///         y: [10, 20, 15]
///     )
///     .barWidth(20)
///     .barColor(.green)
/// }
/// .tickInsets(bottom: 20)
/// .contentDisposition(minX: 0, maxX: 10)
/// ```
/// ![A bar view with green 20-pixels wide bars](barview-barcolor.png)
///
/// Additionally, you can modify the corner radius of the bars using ``BarView/barCornerRadius(_:)``:
///
/// ```swift
/// PlotView {
///     BarView(
///         x: [1, 3, 5],
///         y: [10, 20, 15]
///     )
///     .barWidth(20)
///     .barColor(.green)
///     .barCornerRadius(10)
/// }
/// .tickInsets(bottom: 20)
/// .contentDisposition(minX: 0, maxX: 10)
/// ```
/// ![A bar view with green rounded 20-pixels wide bars](barview-barcornerradius.png)
public struct BarView: FuncView {

    private var x: [Double]
    private var y: [Double]
    private var _disposition: ContentDisposition

    @Environment(\.viewport) private var viewport
    @Environment(\.contentDisposition) private var contentDisposition

    private var radius: CGFloat = 2
    private var width: CGFloat = 5
    private var color: Color = .gray

    /// The content disposition limits.
    public var disposition: ContentDisposition {
        return contentDisposition.merge(_disposition)
    }

    internal init(
        _ x: [Double],
        _ y: [Double],
        _ disposition: ContentDisposition
    ) {
        self.x = x
        self.y = y
        self._disposition = disposition
    }

    /// Creates hozizontal bars at the given positions with determined height.
    ///
    /// - Parameters:
    ///   - x: The coordinates of the bars on horizontal axis.
    ///   - y: The height of the bars on vertical axis.
    public init(x: [Double], y: [Double]) {
        self.x = x
        self.y = y

        self._disposition = ContentDisposition(
            minX: x.min(), maxX: x.max(), minY: 0.0, maxY: y.max()
        )
    }

    /// The content and behaviour of the view.
    public var body: some View {
        GeometryReader { rect in
            let frame = viewport.inset(rect: CGRect(origin: .zero, size: rect.size))

            let xScale = CGFloat(frame.width / disposition.width)
            let yScale = CGFloat(frame.height / disposition.height)
            
            let xZero = (disposition.width - disposition.maxX) * xScale
            let yZero = frame.height - (disposition.height - disposition.maxY) * yScale

            let cornerSize = CGSize(width: radius, height: radius)

            Path { path in
                x.indices.forEach { i in
                    let xpos = x[i] * xScale
                    let ypos = y[i] * yScale
                    let height = abs(ypos)

                    let x = xZero + xpos - self.width / 2
                    let y = ypos > 0 ? yZero - ypos : yZero

                    let bar = frame.intersection(
                        CGRect(x: x, y: y, width: self.width, height: height)
                    )

                    let sharpHeight = min(height, radius)
                    let sharpY = ypos > 0 ? bar.maxY - sharpHeight : yZero
                    
                    let sharpOverlay = frame.intersection(
                        CGRect(x: x, y: sharpY, width: self.width, height: sharpHeight)
                    )
                    // Draw the bar only if its x-axis position is within the view range.
                    // In case, when y does not fit into the view, draw only visible part.
                    if !bar.isEmpty {
                        path.addRoundedRect(in: bar, cornerSize: cornerSize)
                        path.addRect(sharpOverlay)
                        path.closeSubpath()
                    }
                }
            }
            .fill(color)
        }
    }
}

extension BarView {
    /// Modifies the corner radius for the bars within the bar view.
    public func barCornerRadius(_ radius: CGFloat) -> BarView {
        var view = self
        view.radius = radius
        return view
    }

    /// Changes the width of the bars within the bar view.
    public func barWidth(_ width: CGFloat) -> BarView {
        var view = self
        view.width = width
        return view
    }

    /// Changes the color of the bars within the bar view.
    public func barColor(_ color: Color) -> BarView {
        var view = self
        view.color = color
        return view
    }
}

struct BarViewPreview: PreviewProvider {
    static var previews: some View {
        PlotView {
            BarView(
                x: [0, 2, 3],
                y: [2, 5, 20]
            )
            .barWidth(20)
            .barColor(.green)
            .barCornerRadius(3)
        }
        .contentDisposition(minX: 0, maxX: 10)
        .viewport(bottom: 20)
        .padding(50)
        .frame(width: 600, height: 300)
        .background(Color.white)
    }
}
