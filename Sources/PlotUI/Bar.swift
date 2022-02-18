import Foundation
import SwiftUI

public struct Viewport {
    private var _rect: CGRect
    private var _frame: CGSize

    init(_ frame: CGSize, _ edges: Edge.Set = .all, _ length: CGFloat) {
        var origin = CGPoint()
        var size = frame

        if edges.contains(.trailing) {
            size.width -= length
        }
        if edges.contains(.bottom) {
            size.height -= length
        }
        if edges.contains(.leading) {
            origin.x += length
            size.width -= length
        }
        if edges.contains(.top) {
            origin.y += length
            size.height -= length
        }

        self._rect = CGRect(origin: origin, size: size)
        self._frame = frame
    }

    init() {
        self._rect = CGRect()
        self._frame = CGSize()
    }

    public var rect: CGRect { _rect }

    public var frame: CGSize { _frame }
}

extension CGSize: Comparable {
    public static func < (lhs: CGSize, rhs: CGSize) -> Bool {
        return (lhs.width * lhs.height) < (rhs.width * rhs.height)
    }
}

struct ViewportEnvironmentKey: EnvironmentKey {
    static var defaultValue: Viewport = Viewport()
}

extension EnvironmentValues {
    public var viewport: Viewport {
        get { self[ViewportEnvironmentKey.self] }
        set { self[ViewportEnvironmentKey.self] = newValue }
    }
}

extension View {
    public func viewport(_ edges: Edge.Set = .all, _ length: CGFloat) -> some View {
        GeometryReader { rect in
            environment(\.viewport, Viewport(rect.size, edges, length))
        }
    }
}

public struct BarView: FuncView {

    private var x: [Double]
    private var y: [Double]
    private var _disposition: ContentDisposition

    @Environment(\.viewport) var viewport
    @Environment(\.contentDisposition) var contentDisposition

    // Fill style of the bars.
    private var radius: CGFloat = 2
    private var width: CGFloat = 5
    private var color: Color = .gray

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

    public init(x: [Double], y: [Double]) {
        self.x = x
        self.y = y

        self._disposition = ContentDisposition(
            left: x.min(), right: x.max(), bottom: y.min(), top: y.max()
        )
    }

    public var body: some View {
        GeometryReader { rect in
            let width = viewport.rect.width
            let height = viewport.rect.height
            let bounds = disposition.bounds

            let xScale = CGFloat(width / bounds.width)
            let yScale = CGFloat(height / bounds.height)

            let cornerSize = CGSize(width: radius, height: radius)

            Path { path in
                x.indices.forEach { i in
                    let xpos = (x[i] - bounds.left) * xScale
                    let ypos = min(max(0, y[i] * yScale), height)

                    let x = xpos - self.width / 2 + viewport.rect.minX
                    let y = height - ypos + viewport.rect.minY

                    // TODO: what if the rectangle width out of the visible area?
                    let bar = CGRect(x: x, y: y, width: self.width, height: ypos)

                    let sharpHeight = min(ypos, radius)
                    let sharpOverlay = CGRect(
                        x: x, y: y + ypos - sharpHeight, width: self.width, height: sharpHeight)

                    // Draw the bar only if its x-axis position is within the view range.
                    // In case, when y does not fit into the view, draw only visible part.
                    if (0...width).contains(xpos) {
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

    public func barColor(_ color: Color) -> BarView {
        var view = self
        view.color = color
        return view
    }
}

struct BarViewPreview: PreviewProvider {
    static var previews: some View {
        BarView(
            x: [0, 1, 2, 3, -4],
            y: [10, 40, 30, 50, 5]
        )
        .barColor(.green)
        .viewport(.all, 40)
        .contentDisposition(left: -12, right: 5)
        .frame(width: 500, height: 300)
    }
}
