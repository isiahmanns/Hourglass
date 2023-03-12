import XCTest

/**
 UITests:
  - Launch app
  - Assert that headers exist
  - Assert that grid has 6 timers, which exist and are hittable
  - Test start timer flow (tap timer, expect timer to begin..
    - Try using waitForExistence to assert timer countdown values with real timer
  - Test start-new-timer flow (tap different timer, expect alert, respond to alert)
*/

final class HourglassUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
    }

    func testMainFlow() throws {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.staticTexts["Focus"].exists)
    }
}
