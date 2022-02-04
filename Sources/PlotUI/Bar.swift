import SwiftUI
import Foundation


public struct BarView<Style: ShapeStyle> : View {
    
    private var x: [Double]
    private var heights: [Double]
    
    public var xmin: Double
    public var xmax: Double
    public var ymin: Double
    public var ymax: Double
    
    // Fill style of the bars.
    private var fillStyle: Style
    private var radius: CGFloat = 2
    private var width: CGFloat = 5
    
    public var body: some View {
        GeometryReader { rect in
            let width = rect.size.width - 40
            let height = rect.size.height - 40
            
            let xScale = width / CGFloat(abs(xmax - xmin))
            let yScale = height / CGFloat(abs(ymax - ymin))
            
            let cornerSize = CGSize(width: radius, height: radius)
            
            Path { path in
                x.indices.forEach { i in
                    let xpos = (x[i] - xmin) * xScale
                    let ypos = min(max(0, heights[i] * yScale), height)

                    // Draw the bar only if its x-axis position is within the view range.
                    // In case, when y does not fit into the view, draw only visible part.
                    if (0...width).contains(xpos) {
                        let x = xpos - self.width/2
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
    public init(x: [Double],
         height: [Double],
         xmin: Double? = nil, xmax: Double? = nil,
         ymin: Double? = nil, ymax: Double? = nil
    ) {
        self.x = x
        self.heights = height
        // If axis limits are not specified, try to calculate the maximum
        // value from the provided data array, then set to 1.0 if the array
        // is empty.
        self.xmax = xmax ?? x.max() ?? 1.0
        self.ymax = ymax ?? height.max() ?? 1.0
        
        self.xmin = xmin ?? x.min() ?? 0.0
        self.ymin = ymin ?? height.min() ?? 0.0
        
        // Set default fill style, which is just a gray color.
        self.fillStyle = .gray
    }
}


extension BarView {
    public func fill<S: ShapeStyle>(_ style: S) -> BarView<S> {
        return BarView<S>(x: x, heights: heights, xmin: xmin, xmax: xmax, ymin: ymin, ymax: ymax, fillStyle: style)
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
