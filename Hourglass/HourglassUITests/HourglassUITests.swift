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
        XCTAssertTrue(app.staticTexts["Rest"].exists)

        let (timerGrid, timerGridButtons) = timerGrid
        XCTAssertTrue(timerGrid.exists)

        XCTAssertEqual(timerGridButtons.count, 6)
        timerGridButtons.forEach { timerButton in
            XCTAssertTrue(timerButton.exists)
            XCTAssertTrue(timerButton.isHittable)
        }

        let settingsButton = app.popUpButtons["settings-button"]
        XCTAssertTrue(settingsButton.exists)
    }

    func testStartTimerToCompletionPopup() {
        app.setNotificationStyle(.popup)
        app.launchMenu()

        // Tap 3s timer
        let (_, timerGridButtons) = timerGrid
        timerGridButtons[3].tap()

        let alert = app.sheets.matching(identifier: "alert").element
        XCTAssertTrue(alert.waitForExistence(timeout: 4))

        let alertTitle = alert.staticTexts["Time is up."]
        let okButton = alert.buttons["OK"]
        [alertTitle, okButton].forEach { element in
            XCTAssertTrue(element.exists)
        }

        okButton.tap()
    }

    /**
     Test local notification via UNUserNotificationCenter on timer complete.

     For this test to work:
     - Locally, notifications must be visible (DND off)
     - System settings notifications enabled for app,  style is alert (not banner)
        - For some reason, when banner is elected, the notification appears quietly in Notification Center during testing
     - Menu bar is not hidden (Desktop and Dock system settings)
     */
    func DISABLED_testStartTimerToCompletionBanner() {
        app.setNotificationStyle(.banner)
        app.launchMenu()

        // Tap 3s timer
        let (_, timerGridButtons) = timerGrid
        timerGridButtons[3].tap()

        // sleep(4)
        // XCUIApplication(bundleIdentifier: "com.apple.notificationcenterui").log()

        XCTAssertTrue(macosNotification.waitForExistence(timeout: 5))
        let notificationTitle = macosNotification.staticTexts["Hourglass"]
        let notificationSubtitle = macosNotification.staticTexts["Time is up."]
        [notificationTitle, notificationSubtitle].forEach { element in
            XCTAssert(element.exists)
        }
        macosNotification.tap()
    }

    func testStopTimer() {
        app.launchMenu()

        let (_, timerGridButtons) = timerGrid
        timerGridButtons[3].tap()
        timerGridButtons[3].tap()

        XCTAssertEqual(app.statusItems["menu-bar-button"].title, "00:00")
    }

    func testStartNewTimerFlowConfirm() {
        app.launchMenu()

        let (_, timerGridButtons) = timerGrid
        timerGridButtons[4].tap()
        //sleep(1)
        timerGridButtons[5].tap()

        let alert = app.sheets.matching(identifier: "alert").element
        XCTAssertTrue(alert.waitForExistence(timeout: 4))

        let alertTitle = alert.staticTexts["Are you sure you want to start a new timer?"]
        let affirmButton = alert.buttons["Start timer"]
        let denyButton = alert.buttons["Cancel"]
        [alertTitle, affirmButton, denyButton].forEach { element in
            XCTAssertTrue(element.exists)
        }

        affirmButton.tap()
        app.log()
        XCTAssertEqual(app.statusItems["menu-bar-button"].title, "00:20")
    }

    func testStartNewTimerFlowDeny() {
        app.launchMenu()

        let (_, timerGridButtons) = timerGrid
        timerGridButtons[4].tap()
        //sleep(1)
        timerGridButtons[5].tap()

        let alert = app.sheets.matching(identifier: "alert").element
        XCTAssertTrue(alert.waitForExistence(timeout: 4))

        let alertTitle = alert.staticTexts["Are you sure you want to start a new timer?"]
        let affirmButton = alert.buttons["Start timer"]
        let denyButton = alert.buttons["Cancel"]
        [alertTitle, affirmButton, denyButton].forEach { element in
            XCTAssertTrue(element.exists)
        }

        denyButton.tap()
        // Note: - Assuming execution will be the same on each run could mean a flaky test.
        XCTAssertEqual(app.statusItems["menu-bar-button"].title, "00:07")
    }

    func testSetTimerLengthWhileInProgressFlow() {
        app.launchMenu()

        let (_, timerGridButtons) = timerGrid
        timerGridButtons[4].tap()

        let settingsButton = app.popUpButtons["settings-button"]
        settingsButton.tap()

        let timerSetting = app.menuItems["Rest Timers"].menuItems["15"]
        timerSetting.tap()

        let alert = app.sheets.matching(identifier: "alert").element
        XCTAssertTrue(alert.waitForExistence(timeout: 1))

        let alertTitle = alert.staticTexts["Timer has been reset."]
        let okButton = alert.buttons["OK"]
        [alertTitle, okButton].forEach { element in
            XCTAssertTrue(element.exists)
        }

        okButton.tap()

        // Cleanup
        settingsButton.tap()
        app.menuItems["Rest Timers"].menuItems["10"].tap()
    }
}

// App utility helpers
extension XCUIApplication {
    func launchMenu() {
        launch()
        // Note: - Locally, menu bar must be "always visible" or mouse should hover on menu bar for tests to work.
        // NSStatusBar.system
        statusItems["menu-bar-button"].tap()
    }

    func log() {
        print(debugDescription)
    }
}

// Settings override helpers via launch environment
extension XCUIApplication {
    func setNotificationStyle(_ style: NotificationStyle) {
        launchEnvironment[SettingsKeys.notificationStyle.rawValue] = String(style.rawValue)
    }
}
