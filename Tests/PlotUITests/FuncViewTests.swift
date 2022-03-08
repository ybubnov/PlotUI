import SwiftUI
import XCTest

@testable import PlotUI

final class ContentDispositionTests: XCTestCase {
    func testLeftRight() throws {
        let cd = ContentDisposition(minX: 3.0)
        XCTAssertEqual(cd, ContentDisposition(minX: 3.0, maxX: 4.0))
    }

    func testBottomTop() throws {
        let cd = ContentDisposition(minY: 4.0)
        XCTAssertEqual(cd, ContentDisposition(minY: 4.0, maxY: 5.0))
    }

    func testInverted() throws {
        let cd = ContentDisposition(minX: 4.0, maxX: 2.0, minY: 6.0, maxY: 3.0)
        XCTAssertEqual(cd, ContentDisposition(minX: 4.0, maxX: 5.0, minY: 6.0, maxY: 7.0))
    }

    func testMerge() throws {
        let cd1 = ContentDisposition(minX: 1.0)
        let cd2 = ContentDisposition(maxX: 3.0)

        XCTAssertEqual(cd1.merge(cd2), ContentDisposition(minX: 1.0, maxX: 3.0))
    }
}
