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
            ContentDisposition(left: -3.0, right: 2.0, bottom: -30.0, top: 40.0))
    }

    func testFill() throws {
        var bar = BarView(x: [0.0], y: [1.0])
        var shape = try bar.inspect().find(ViewType.GeometryReader.self).shape()

        // Ensure default fill style is gray.
        XCTAssertEqual(try shape.fillShapeStyle(Color.self), Color.gray)

        // Modify the default color, and ensure it was changed.
        bar = bar.barColor(.red)
        shape = try bar.inspect().find(ViewType.GeometryReader.self).shape()
        XCTAssertEqual(try shape.fillShapeStyle(Color.self), Color.red)
    }
}
