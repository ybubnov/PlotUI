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
