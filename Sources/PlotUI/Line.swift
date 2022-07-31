import Foundation
import SwiftUI


/// A view that that represents the data with a series of data points called "markers"
/// connected by straight line segments. It is a basic type of chart common in many
/// fields.
///
/// You can create a line view by providing horizontal and vertical coordinates:
///
/// ```swift
/// LineView(
///     x: [0, 1, 2, 3, 4, 5],
///     y: [10, 20, 0, 45, 30, 50]
/// )
/// ```
/// ![A line view with line view](lineview.png)
///
/// Usually `LineView` is used within ``PlotView`` container that automatically defines
/// axes with appropriate ticks. You can use ``PlotView/contentDisposition(minX:maxX:minY:maxY:)``
/// to adjust the limits of the axes to position the view's content as you want.
///
/// ## Styling Line Views
///
/// You can customize the stroke of the line within the view using
/// ``LineView/lineStroke(style:)`` view modifier:
/// ```swift
/// PlotView {
///     LineView(
///         x: [1, 2, 3, 4, 5, 6]
///         y: [10, 20, 0, 45, 30, 50]
///     )
///     .lineStroke(style: StrokeStyle(lineWidth: 1.0, dash: [2]))
/// }
/// ```
/// ![A line view with dashed stroke 1 pixel width](lineview-linestroke.png)
///
/// You can also change the default color of the line using ``LineView/lineColor(_:)``:
/// ```swift
/// PlotView {
///     LineView(
///         x: [1, 2, 3, 4, 5, 6]
///         y: [10, 20, 0, 45, 30, 50]
///     )
///     .lineColor(.mint)
/// }
/// ```
/// ![A linew view with mint color line](lineview-linecolor.png)
///
/// Additionally, you can modify the background overlay of the line chart using
/// ``LineView/lineFill(_:)``:
/// ```swift
/// PlotView {
///     LineView(
///         x: [1, 2, 3, 4, 5, 6]
///         y: [10, 20, 5, 15, 18, 3]
///     )
///     .lineFill(.green.opacity(0.3))
/// }
/// ```
/// ![A line view with opaque green fill](lineview-linefill.png)
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public struct LineView: FuncView {

    private var x: [Double]
    private var y: [Double]
    private var _disposition: ContentDisposition

    @Environment(\.contentDisposition) private var contentDisposition

    private var stroke: StrokeStyle = StrokeStyle(lineWidth: 2.0)
    private var color: Color = .green
    private var fill: AnyShapeStyle = AnyShapeStyle(
        LinearGradient(
            colors: [.green.opacity(0.5), .green.opacity(0.0)],
            startPoint: .top, endPoint: .bottom
        )
    )

    /// The content disposition limits.
    public var disposition: ContentDisposition {
        return contentDisposition.merge(_disposition)
    }

    internal init(
        _ x: [Double],
        _ y: [Double],
        _ disposition: ContentDisposition
    ) {
        self.x = Array(x[0..<min(y.count, x.count)])
        self.y = y
        self._disposition = disposition
    }

    /// Creates a line chart at the given positions with determined height.
    ///
    /// - Parameters:
    ///   - x: Coordinates on a horizontal axis.
    ///   - y: Coordinates on a vertical axis.
    public init(x: [Double], y: [Double]) {
        self.init(x, y, ContentDisposition(
            minX: x.min(), maxX: x.max(), minY: y.min(), maxY: y.max()
        ))
    }

    /// The content and behaviour of the view.
    public var body: some View {
        ViewportReader(disposition) { viewport in
            let minX = (x.first ?? disposition.minX) * viewport.xScale
            let minY = (y.first ?? disposition.minY) * viewport.yScale
            let maxX = (x.last ?? disposition.maxX) * viewport.xScale

            let line = Path { path in
                path.move(to: CGPoint(x: viewport.xZero + minX, y: viewport.yZero - minY))
                x.indices.forEach { i in
                    let x = viewport.translateX(x[i])
                    let y = viewport.translateY(y[i])

                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
            .stroke(style: stroke)
            .fill(color)

            let overlay = Path { path in
                path.move(to: CGPoint(x: viewport.xZero + minX, y: viewport.yZero))
                x.indices.forEach { i in
                    let x = viewport.translateX(x[i])
                    let y = viewport.translateY(y[i])

                    path.addLine(to: CGPoint(x: x, y: y))
                }
                path.addLine(to: CGPoint(x: viewport.xZero + maxX, y: viewport.yZero))
            }

            overlay.fill(fill).overlay(line)
        }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
extension LineView {
    /// Changes the stroke style for a line within a line view.
    public func lineStroke(style: StrokeStyle) -> LineView {
        var view = self
        view.stroke = style
        return view
    }

    /// Changes the color of the line within the line view.
    public func lineColor(_ color: Color) -> LineView {
        var view = self
        view.color = color
        return view
    }

    /// Changes the color of the area under the line within the line view.
    public func lineFill<S: ShapeStyle>(_ style: S) -> LineView {
        var view = self
        view.fill = AnyShapeStyle(style)
        return view
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
struct LineViewPreview: PreviewProvider {
    static var previews: some View {
        PlotView{
            LineView(
                x: Array(stride(from: 0.0, to: 10.2, by: 0.2)),
                y: (0...100).map { _ in Double.random(in: 0..<1)}
            )
            .lineStroke(style: StrokeStyle(lineWidth: 1))
            .lineColor(.blue)
            .lineFill(Color.blue.opacity(0.3))
        }
        .tickColor(.white)
        .tickInsets(bottom: 20, trailing: 20)
        .contentDisposition(minX: -5, maxX: 15, minY: 0)
        .padding(50)
        .frame(width: 600, height: 300)
        .foregroundColor(.white.opacity(0.8))
        .background(Color.black)
    }
}
