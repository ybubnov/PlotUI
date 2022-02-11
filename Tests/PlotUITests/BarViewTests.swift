import SwiftUI
import ViewInspector
import XCTest

@testable import PlotUI

extension BarView: Inspectable {}

final class BarViewTests: XCTestCase {
    func testComputedDomainAndImage() throws {
        let bar = BarView(x: [0.0, -1.0, 2.0, -3.0], heights: [-30.0, 20.0, 10.0, 40.0])
        XCTAssertEqual(bar.domain, -3.0...2.0)
        XCTAssertEqual(bar.image, -30.0...40.0)
    }

    func testCustomDomainAndImage() throws {
        let bar = BarView(
            x: [0.0, -50.0], heights: [10, 20], domain: -10.0...10.0, image: 5.0...5.0)
        XCTAssertEqual(bar.domain, -10.0...10.0)
        XCTAssertEqual(bar.image, 5.0...5.0)
    }

    func testFill() throws {
        var bar = BarView(x: [0.0], heights: [1.0])
        var shape = try bar.inspect().find(ViewType.GeometryReader.self).shape()

        // Ensure default fill style is gray.
        XCTAssertEqual(try shape.fillShapeStyle(Color.self), Color.gray)

        // Modify the default color, and ensure it was changed.
        bar = bar.fill(Color.red)
        shape = try bar.inspect().find(ViewType.GeometryReader.self).shape()
        XCTAssertEqual(try shape.fillShapeStyle(Color.self), Color.red)
    }
}
