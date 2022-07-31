import SwiftUI
import ViewInspector
import XCTest

@testable import PlotUI

extension BarView: Inspectable {}

final class BarViewTests: XCTestCase {
    func testContentDisposition() throws {
        let bar = BarView(x: [0.0, -1.0, 2.0, -3.0], y: [-30.0, 20.0, 10.0, 40.0])

        XCTAssertEqual(
            bar.disposition,
            ContentDisposition(minX: -3.0, maxX: 2.0, minY: 0.0, maxY: 40.0))
    }
}
