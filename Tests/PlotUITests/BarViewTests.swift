import SwiftUI
import ViewInspector
import XCTest

@testable import PlotUI

extension BarView: Inspectable {}

final class BarViewTests: XCTestCase {
    func testComputedDisposition() throws {
        let bar = BarView(x: [0.0, -1.0, 2.0, -3.0], y: [-30.0, 20.0, 10.0, 40.0])

        XCTAssertEqual(
            bar.disposition.bounds,
            ContentDisposition.Bounds(left: -3.0, right: 2.0, bottom: -30.0, top: 40.0))
    }

    func testCustomDisposition() throws {
        let disposition = ContentDisposition(left: -10.0, right: 10.0, bottom: 5.0, top: 5.0)

        let bar = BarView(x: [0.0, -50.0], y: [10, 20], disposition: disposition)
        XCTAssertEqual(bar.disposition, disposition)
    }

    func testFill() throws {
        var bar = BarView(x: [0.0], y: [1.0])
        var shape = try bar.inspect().find(ViewType.GeometryReader.self).shape()

        // Ensure default fill style is gray.
        XCTAssertEqual(try shape.fillShapeStyle(Color.self), Color.gray)

        // Modify the default color, and ensure it was changed.
        bar = bar.fill(Color.red)
        shape = try bar.inspect().find(ViewType.GeometryReader.self).shape()
        XCTAssertEqual(try shape.fillShapeStyle(Color.self), Color.red)
    }
}
