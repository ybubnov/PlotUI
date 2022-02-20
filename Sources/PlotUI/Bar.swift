import Foundation
import SwiftUI

public struct Viewport {
    private var insets: EdgeInsets

    public init(_ insets: EdgeInsets) {
        self.insets = insets
    }

    public init() {
        self.insets = EdgeInsets()
    }

    /// Adjust the given rectangle by the edge insets.
    public func inset(rect: CGRect) -> CGRect {
        return CGRect(
            x: rect.minX + insets.leading,
            y: rect.minY + insets.top,
            width: rect.width - insets.trailing,
            height: rect.height - insets.bottom
        )
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
    public func viewport(_ insets: EdgeInsets) -> some View {
        environment(\.viewport, Viewport(insets))
    }

    public func viewport(
        top: CGFloat? = nil, leading: CGFloat? = nil, bottom: CGFloat? = nil,
        trailing: CGFloat? = nil
    ) -> some View {
        let insets = EdgeInsets(
            top: top ?? 0.0,
            leading: leading ?? 0.0,
            bottom: bottom ?? 0.0,
            trailing: trailing ?? 0.0
        )
        return environment(\.viewport, Viewport(insets))
    }
}

public struct BarView: FuncView {

    private var x: [Double]
    private var y: [Double]
    private var _disposition: ContentDisposition

    @Environment(\.viewport) private var viewport
    @Environment(\.contentDisposition) private var contentDisposition

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
            let frame = viewport.inset(rect: CGRect(origin: .zero, size: rect.size))
            let bounds = disposition.bounds

            let xScale = CGFloat(frame.width / bounds.width)
            let yScale = CGFloat(frame.height / bounds.height)

            let cornerSize = CGSize(width: radius, height: radius)

            Path { path in
                x.indices.forEach { i in
                    let xpos = (x[i] - bounds.left) * xScale
                    let ypos = min(max(0, (y[i] - bounds.bottom) * yScale), frame.height)

                    let x = xpos - self.width / 2 + frame.minX
                    let y = frame.height - ypos + frame.minY

                    // TODO: what if the rectangle width out of the visible area?
                    let bar = CGRect(x: x, y: y, width: self.width, height: ypos)

                    let sharpHeight = min(ypos, radius)
                    let sharpOverlay = CGRect(
                        x: x, y: y + ypos - sharpHeight, width: self.width, height: sharpHeight)

                    // Draw the bar only if its x-axis position is within the view range.
                    // In case, when y does not fit into the view, draw only visible part.
                    if frame.intersects(bar) {
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
        .viewport(bottom: 10, trailing: 20)
        .contentDisposition(bottom: 1)
        .frame(width: 500, height: 300)
    }
}
