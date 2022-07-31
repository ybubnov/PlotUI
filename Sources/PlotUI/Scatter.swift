import Foundation
import SwiftUI

/// A view that that represents the data with a series of data points. The data are
/// displayed as a collection of points, each having the value of one variable
/// determining the position on the horizontal axis and the value of the other variable
/// determining the position on the vertical axis
///
/// You can create a line view by providing horizontal and vertical coordinates:
public struct ScatterView: FuncView {

    private var x: [Double]
    private var y: [Double]
    private var _disposition: ContentDisposition

    @Environment(\.contentDisposition) private var contentDisposition

    private var color: Color = .blue
    private var size: CGFloat = 7
    private var stroke: StrokeStyle = StrokeStyle(lineWidth: 2)
    private var strokeColor: Color = .white

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

    private func makePath(rect: ViewportProxy) -> Path {
        Path { path in
            x.indices.forEach { i in
                let x = rect.translateX(x[i])
                let y = rect.translateY(y[i])

                let circ = CGRect(x: x-size/2, y: y-size/2, width: size, height: size)

                if circ.width == size && circ.height == size {
                    path.addEllipse(in: circ)
                }
            }

        }
    }

    /// The content and behaviour of the view.
    public var body: some View {
        ViewportReader(disposition) { viewport in
            makePath(rect: viewport)
            .fill(color)

            if stroke.lineWidth > 0 {
                makePath(rect: viewport)
                .stroke(style: stroke)
                .fill(strokeColor)
            }
        }
    }
}

extension ScatterView {
    /// Modifies the size of the points within a scatter view.
    public func scatterSize(_ size: CGFloat) -> ScatterView {
        var view = self
        view.size = size
        return view
    }

    /// Modifies the color of the points within a scatter view.
    public func scatterColor(_ color: Color) -> ScatterView {
        var view = self
        view.color = color
        return view
    }

    /// Changes the stroke style of points' stroke within a scatter view.
    public func scatterStroke(style: StrokeStyle) -> ScatterView {
        var view = self
        view.stroke = style
        return view
    }

    /// Changes the stroke line width of points' stroke within a scatter view.
    public func scatterStroke(lineWidth: CGFloat) -> ScatterView {
        return scatterStroke(style: StrokeStyle(lineWidth: lineWidth))
    }

    /// Changes the color of the points' stroke within scatter view.
    public func scatterStrokeColor(_ color: Color) -> ScatterView {
        var view = self
        view.strokeColor = color
        return view
    }
}

struct ScatterViewPreviewer: PreviewProvider {
    static var previews: some View {
        PlotView{
            ScatterView(
                x: Array(stride(from: 0.0, to: 10.2, by: 1.0)),
                y: Array(stride(from: 0.0, to: 10.2, by: 1.0)).map{ v in pow(v, 2) }
            )
            .scatterSize(10)
            .scatterStroke(lineWidth: 10)
            .scatterStrokeColor(.blue.opacity(0.5))
        }
        .tickInsets(bottom: 20, trailing: 20)
        .contentDisposition(minX: 0, maxX: 15, minY: 0, maxY: 100)
        .padding(50)
        .frame(width: 600, height: 300)
        .background(Color.white)
    }
}
