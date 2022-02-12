import Foundation
import SwiftUI

public protocol TickShape: Shape {
    init(_ disposition: ContentDisposition, at: CGFloat)
}

public struct VerticalTick: TickShape {
    private var at: CGFloat

    // TODO: move x-tick and y-tick sizes into observed object.
    private var xtick: CGFloat = 40
    private var ytick: CGFloat = 20

    @ObservedObject var disposition: ContentDisposition

    public init(_ disposition: ContentDisposition, at: CGFloat) {
        self.at = at
        self.disposition = disposition
    }

    public func path(in rect: CGRect) -> Path {
        let xScale = (rect.size.width - xtick) / disposition.bounds.width
        let yOffset = rect.size.height - ytick

        let x = (at - disposition.bounds.left) * xScale

        return Path { path in
            path.move(to: CGPoint(x: x, y: yOffset))
            path.addLine(to: CGPoint(x: x, y: 0))
        }
    }
}

public struct HorizontalTick: TickShape {
    private var at: CGFloat

    private var xtick: CGFloat = 40
    private var ytick: CGFloat = 20

    @ObservedObject var disposition: ContentDisposition

    public init(_ disposition: ContentDisposition, at: CGFloat) {
        self.at = at
        self.disposition = disposition
    }

    public func path(in rect: CGRect) -> Path {
        let limit = disposition.bounds.height

        // All y-axis ticks are located on the horizontal axis, hence subtract the
        // size of y-tick from the width of this axis.
        let xOffset = rect.size.width - ytick
        let yScale = (rect.size.height - xtick) / limit

        let y = (rect.size.height - xtick) - (at - disposition.bounds.bottom) * yScale

        return Path { path in
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: xOffset, y: y))
        }
    }
}
