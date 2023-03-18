import XCTest

final class HourglassUITests: XCTestCase {
    let app = XCUIApplication()

    var timerGrid: (XCUIElement, [XCUIElement]) {
        let timerGrid = app.groups["timer-grid"]
        let predicate = NSPredicate(format: "identifier contains 'timer-button'")
        let timerGridButtons = timerGrid.buttons.containing(predicate).allElementsBoundByIndex
        return (timerGrid, timerGridButtons)
    }

    lazy var macosNotification: XCUIElement = {
        // https://en.wikipedia.org/wiki/List_of_macOS_built-in_apps#Launchpad + Activity Center
        XCUIApplication(bundleIdentifier: "com.apple.notificationcenterui")
            .dialogs["Notification Center"]
            .groups["Hourglass"]
            .firstMatch
    }()

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
    }

    func testMainUI() throws {
        app.launchMenu()

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
    func testStartTimerToCompletionPopup() {
        app.setNotificationStyle(.popup)
        app.launchMenu()

        // Tap 3s timer
        let (_, timerGridButtons) = timerGrid
        timerGridButtons[3].tap()

        let alert = app.sheets.matching(identifier: "alert").element
        XCTAssertTrue(alert.waitForExistence(timeout: 4))

        let alertTitle = alert.staticTexts["Time's up"]
        let okButton = alert.buttons["OK"]
        [alertTitle, okButton].forEach { element in
            XCTAssertTrue(element.exists)
        }

        okButton.tap()
    }

    // Note: - Locally, notifications must be visible (DND off).
    func testStartTimerToCompletionBanner() {
        app.setNotificationStyle(.banner)
        app.launchMenu()

        // Tap 3s timer
        let (_, timerGridButtons) = timerGrid
        timerGridButtons[3].tap()

        // sleep(4)
        // XCUIApplication(bundleIdentifier: "com.apple.notificationcenterui").log()

        XCTAssertTrue(macosNotification.waitForExistence(timeout: 5))
        let notificationTitle = macosNotification.staticTexts["Hourglass"]
        let notificationSubtitle = macosNotification.staticTexts["Time's up"]
        [notificationTitle, notificationSubtitle].forEach { element in
            XCTAssert(element.exists)
        }
        macosNotification.tap()
    }

    func testStopTimer() {
        app.launchMenu()

        // Tap 3s timer
        let (_, timerGridButtons) = timerGrid
        timerGridButtons[3].tap()
        timerGridButtons[3].tap()

        // TODO: Assert time is at 00:00 using timer display in menu bar (#13)
    }

    func testStartNewTimerFlowConfirm() {
        app.setNotificationStyle(.popup)
        app.launchMenu()

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
        app.setNotificationStyle(.popup)
        app.launchMenu()

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

// App utility helpers
extension XCUIApplication {
    func launchMenu() {
        launch()
        // Note: - Locally, menu bar must be "always visible" or mouse should hover on menu bar for tests to work.
        // NSStatusBar.system
        statusItems["menu-bar-select"].tap()
    }

    func log() {
        print(debugDescription)
    }
}

// UserDefaults override helpers via launch args
extension XCUIApplication {
    func setNotificationStyle(_ style: NotificationStyle) {
        launchArguments += ["-\(SettingsKeys.notificationStyle.rawValue)", "\(style.rawValue)"]
    }
}
