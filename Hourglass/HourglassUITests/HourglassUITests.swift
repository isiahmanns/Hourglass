import XCTest

final class HourglassUITests: XCTestCase {
    let app = XCUIApplication()

    var timerGrid: (XCUIElement, [XCUIElement]) {
        let timerGrid = app.groups["timer-grid"]
        let predicate = NSPredicate(format: "identifier contains 'timer-button'")
        let timerGridButtons = timerGrid.buttons.containing(predicate).allElementsBoundByIndex
        return (timerGrid, timerGridButtons)
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }

    override func tearDownWithError() throws {
    }

    func testMainUI() throws {
        XCTAssertTrue(app.staticTexts["Focus"].exists)
        XCTAssertTrue(app.staticTexts["Break"].exists)

        let (timerGrid, timerGridButtons) = timerGrid
        XCTAssertTrue(timerGrid.exists)

        XCTAssertEqual(timerGridButtons.count, 6)
        timerGridButtons.forEach { timerButton in
            XCTAssertTrue(timerButton.exists)
            XCTAssertTrue(timerButton.isHittable)
        }

        let settingsButton = app.buttons["settings-button"]
        XCTAssertTrue(settingsButton.exists)
    }

    // TODO: - Use launch arguments to override userdefault timer settings for testing (#15)
    func testStartTimerToCompletion() {
        // Tap 3s timer
        let (_, timerGridButtons) = timerGrid
        timerGridButtons[3].tap()

        let alert = app.sheets.matching(identifier: "alert").element
        XCTAssertTrue(alert.waitForExistence(timeout: 4))
        // print(app.debugDescription)

        let alertTitle = alert.staticTexts["Timer completed."]
        let okButton = alert.buttons["OK"]
        [alertTitle, okButton].forEach { element in
            XCTAssertTrue(element.exists)
        }

        okButton.tap()
    }

    func testStopTimer() {
        // Tap 3s timer
        let (_, timerGridButtons) = timerGrid
        timerGridButtons[3].tap()
        timerGridButtons[3].tap()

        // TODO: Assert time is at 00:00 using timer display in menu bar (#13)
    }

    func testStartNewTimerFlowConfirm() {
        let (_, timerGridButtons) = timerGrid
        timerGridButtons[3].tap()
        sleep(1)
        timerGridButtons[4].tap()

        let alert = app.sheets.matching(identifier: "alert").element
        XCTAssertTrue(alert.waitForExistence(timeout: 4))

        let alertTitle = alert.staticTexts["Are you sure you want to start a new timer?"]
        let affirmButton = alert.buttons["Start timer"]
        let denyButton = alert.buttons["Cancel"]
        [alertTitle, affirmButton, denyButton].forEach { element in
            XCTAssertTrue(element.exists)
        }

        affirmButton.tap()
        // TODO: Assert time == new time using timer display in menu bar (#13)

    }

    func testStartNewTimerFlowDeny() {
        let (_, timerGridButtons) = timerGrid
        timerGridButtons[3].tap()
        sleep(1)
        timerGridButtons[4].tap()

        let alert = app.sheets.matching(identifier: "alert").element
        XCTAssertTrue(alert.waitForExistence(timeout: 4))

        let alertTitle = alert.staticTexts["Are you sure you want to start a new timer?"]
        let affirmButton = alert.buttons["Start timer"]
        let denyButton = alert.buttons["Cancel"]
        [alertTitle, affirmButton, denyButton].forEach { element in
            XCTAssertTrue(element.exists)
        }

        denyButton.tap()
        // TODO: Assert time < prev. selected time using timer display in menu bar (#13)
    }
}
