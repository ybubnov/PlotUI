import Foundation
import SwiftUI

public protocol TickShape: Shape {
    init(_ disposition: ContentDisposition, _ viewport: Viewport, at: Double)
}

public struct VerticalTick: TickShape {
    private var at: Double

    private var disposition: ContentDisposition
    private var viewport: Viewport

    public init(_ disposition: ContentDisposition, _ viewport: Viewport, at: Double) {
        self.at = at
        self.disposition = disposition
        self.viewport = viewport
    }

    public func path(in rect: CGRect) -> Path {
        let xScale = viewport.rect.width / disposition.bounds.width

        let x = viewport.rect.minX + (at - disposition.bounds.left) * xScale

        return Path { path in
            path.move(to: CGPoint(x: x, y: viewport.rect.minY))
            path.addLine(to: CGPoint(x: x, y: rect.size.height))
        }
    }
}

struct VerticalTickPreview: PreviewProvider {
    static var previews: some View {
        GeometryReader { rect in
            VerticalTick(
                ContentDisposition(left: 0, right: 10, bottom: 0, top: 10),
                Viewport(rect.size, [.top, .bottom, .leading], 10),
                at: 5
            )
            .stroke(style: StrokeStyle(lineWidth: 5))
        }
        .viewport(.all, 50)
        .frame(width: 400, height: 400)
        .background(Color.white)
    }
}

public struct HorizontalTick: TickShape {
    private var at: Double

    private var xtick: CGFloat = 40
    private var ytick: CGFloat = 20

    private var disposition: ContentDisposition
    private var viewport: Viewport

    public init(_ disposition: ContentDisposition, _ viewport: Viewport, at: Double) {
        self.at = at
        self.disposition = disposition
        self.viewport = viewport
    }

    public func path(in rect: CGRect) -> Path {
        let limit = disposition.bounds.height

        // All y-axis ticks are located on the horizontal axis, hence subtract the
        // size of y-tick from the width of this axis.
        let yScale = viewport.rect.height / limit

        let y = viewport.rect.height - (at - disposition.bounds.bottom) * yScale

        return Path { path in
            path.move(to: CGPoint(x: viewport.rect.minX, y: y))
            path.addLine(to: CGPoint(x: viewport.rect.maxX, y: y))
        }
    }
}
