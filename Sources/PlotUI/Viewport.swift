import SwiftUI

/// The inset distances for the sides of a `PlotView`'s invisible frame.
struct Viewport {
    private var insets: EdgeInsets

    /// Creates a `Viewport` from `EdgeInsets`.
    init(_ insets: EdgeInsets) {
        self.insets = insets
    }

    /// Creates a `Viewport` with insests set to `0.0` for all edges.
    init() {
        self.insets = EdgeInsets()
    }

    /// Adjust the given rectangle by the edge insets.
    func inset(rect: CGRect) -> CGRect {
        return CGRect(
            x: rect.minX + insets.leading,
            y: rect.minY + insets.top,
            width: rect.width - insets.trailing,
            height: rect.height - insets.bottom
        )
    }
}

/// A proxy for access to the size and coordinate space (for anchor resolution)
/// of the container view.
struct ViewportProxy {
    let frame: CGRect
    let xScale: CGFloat
    let yScale: CGFloat
    let xZero: CGFloat
    let yZero: CGFloat

    /// Projects x coordinate into the viewport coordinate space.
    public func translateX(_ x: Double) -> CGFloat {
        return xZero + x * xScale
    }

    /// Projects y coordinate into the viewport coordinate space.
    public func translateY(_ y: Double) -> CGFloat {
        return yZero - y * yScale
    }
}

/// A container view that defines its content as a function of its own size and
/// coordinate space.
///
/// This view returns a flexible preferred size to its parent layout.
struct ViewportReader<Content>: View where Content: View  {

    private var content: (ViewportProxy) -> Content
    private var disposition: ContentDisposition

    @Environment(\.viewport) private var viewport

    init(
        _ disposition: ContentDisposition,
        @ViewBuilder content: @escaping (ViewportProxy) -> Content
    ) {
        self.disposition = disposition
        self.content = content
    }

    var body: some View {
        GeometryReader { rect in
            let frame = viewport.inset(rect: CGRect(origin: .zero, size: rect.size))

            let xScale = CGFloat(frame.width / disposition.width)
            let yScale = CGFloat(frame.height / disposition.height)

            let xZero = (disposition.width - disposition.maxX) * xScale
            let yZero = frame.height - (disposition.height - disposition.maxY) * yScale

            content(ViewportProxy(
                frame: frame,
                xScale: xScale,
                yScale: yScale,
                xZero: xZero,
                yZero: yZero
            ))
        }
    }
}

/// An environment value to control the viewport of plots within view hierarchy.
struct ViewportEnvironmentKey: EnvironmentKey {
    static var defaultValue: Viewport = Viewport()
}

extension EnvironmentValues {
    /// The viewport insets to apply to ``PlotView`` view.
    var viewport: Viewport {
        get { self[ViewportEnvironmentKey.self] }
        set { self[ViewportEnvironmentKey.self] = newValue }
    }
}

extension View {
    /// Adds a different padding amount to each edge of ``PlotView`` view.
    ///
    /// Use this modifier to add a different amount of padding on each edge of a
    /// ``PlotView``:
    ///
    /// ```swift
    /// PlotView {
    ///     BarView(x: [1, 2], y: [10, 20])
    /// }
    /// .viewport(EdgeInsets(top: 0, leading: 0, bottom: 40, trailing: 40))
    /// ```
    ///
    /// Usually, it's more convenient to use
    /// ``PlotView/tickInsets(top:leading:bottom:trailing:)`` instead to define padding
    /// for specific edges.
    public func viewport(_ insets: EdgeInsets) -> some View {
        environment(\.viewport, Viewport(insets))
    }

    /// Adds a specific padding amount to each edge of ``PlotView``.
    ///
    /// Use this modifier to control padding for specified edges of a ``PlotView``, when
    /// any of the values are omitted, the value is defaulted to `0.0`.
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
