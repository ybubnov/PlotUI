import SwiftUI
import XCTest

@testable import PlotUI

final class ContentDispositionTests: XCTestCase {
    func testLeftRight() throws {
        let cd = ContentDisposition(left: 3.0)
        XCTAssertEqual(cd, ContentDisposition(left: 3.0, right: 4.0))
    }

    func testBottomTop() throws {
        let cd = ContentDisposition(bottom: 4.0)
        XCTAssertEqual(cd, ContentDisposition(bottom: 4.0, top: 5.0))
    }

    func testInverted() throws {
        let cd = ContentDisposition(left: 4.0, right: 2.0, bottom: 6.0, top: 3.0)
        XCTAssertEqual(cd, ContentDisposition(left: 4.0, right: 5.0, bottom: 6.0, top: 7.0))
    }

    func testMerge() throws {
        let cd1 = ContentDisposition(left: 1.0)
        let cd2 = ContentDisposition(right: 3.0)

        XCTAssertEqual(cd1.merge(cd2), ContentDisposition(left: 1.0, right: 3.0))
    }
}
