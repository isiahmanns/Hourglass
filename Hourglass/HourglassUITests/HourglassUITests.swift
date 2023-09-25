import XCTest

final class HourglassUITests: XCTestCase {
    var app: XCUIApplication!
    var timerButtons: [XCUIElement]!

    override func setUpWithError() throws {
        continueAfterFailure = false

        app = XCUIApplication()
        app.launchMenu()
        let predicate = NSPredicate(format: "identifier contains 'timer-button'")
        timerButtons = app.buttons.containing(predicate).allElementsBoundByIndex
    }

    func testMainUI() throws {
        let focusButton = app.buttons["Focus"]
        let restButton = app.buttons["Rest"]
        let settingsButton = app.popUpButtons["settings-button"]
        XCTAssertTrue(([focusButton, restButton, settingsButton]
                       + timerButtons).allSatisfy({ $0.exists && $0.isHittable }))
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
        // Tap 3s timer
        timerButtons[0].tap()

        // sleep(4)
        // XCUIApplication(bundleIdentifier: "com.apple.notificationcenterui").log()

        // https://en.wikipedia.org/wiki/List_of_macOS_built-in_apps#Launchpad + Activity Center
        let macosNotification = XCUIApplication(bundleIdentifier: "com.apple.notificationcenterui")
            .dialogs["Notification Center"]
            .groups["Hourglass"]
            .firstMatch

        XCTAssertTrue(macosNotification.waitForExistence(timeout: 5))
        let notificationTitle = macosNotification.staticTexts["Hourglass"]
        let notificationSubtitle = macosNotification.staticTexts["Time is up."]
        XCTAssertTrue([notificationTitle, notificationSubtitle].allSatisfy({ $0.exists }))
        macosNotification.tap()
    }

    func testStopTimer() {
        timerButtons[3].tap()
        timerButtons[3].tap()

        XCTAssertEqual(app.statusItems["menu-bar-button"].title, "00:00")
    }

    func testStartNewTimerFlowConfirm() {
        timerButtons[2].tap()
        //sleep(1)
        timerButtons[3].tap()

        let alert = app.sheets.matching(identifier: "alert").element
        XCTAssertTrue(alert.waitForExistence(timeout: 4))

        let alertTitle = alert.staticTexts["Are you sure you want to start a new timer?"]
        let affirmButton = alert.buttons["Start timer"]
        let denyButton = alert.buttons["Cancel"]
        XCTAssertTrue([alertTitle, affirmButton, denyButton].allSatisfy({ $0.exists }))

        affirmButton.tap()
        app.log()
        XCTAssertEqual(app.statusItems["menu-bar-button"].title, "00:20")
    }

    func testStartNewTimerFlowDeny() {
        timerButtons[1].tap()
        //sleep(1)
        timerButtons[0].tap()

        let alert = app.sheets.matching(identifier: "alert").element
        XCTAssertTrue(alert.waitForExistence(timeout: 4))

        let alertTitle = alert.staticTexts["Are you sure you want to start a new timer?"]
        let affirmButton = alert.buttons["Start timer"]
        let denyButton = alert.buttons["Cancel"]
        XCTAssertTrue([alertTitle, affirmButton, denyButton].allSatisfy({ $0.exists }))


        denyButton.tap()
        // Note: - Assuming execution will be the same on each run could mean a flaky test.
        XCTAssertEqual(app.statusItems["menu-bar-button"].title, "00:07")
    }

    func testChangeRestSettingsWhileTimerInProgress() {
        timerButtons[4].tap()

        let settingsButton = app.popUpButtons["settings-button"]
        settingsButton.tap()

        let editRestSettings = app.menuItems["Edit Rest Settings"]
        editRestSettings.tap()

        let restReminderPicker = app.popUpButtons["rest-reminder-picker"]
        restReminderPicker.tap()

        let offOption = app.menuItems["Off"]
        offOption.tap()

        let closeButton = app.buttons["Close"]
        closeButton.tap()

        let alert = app.sheets.matching(identifier: "alert").element
        XCTAssertTrue(alert.waitForExistence(timeout: 1))

        let alertTitle = alert.staticTexts["Timer settings have been reset."]
        let okButton = alert.buttons["OK"]
        XCTAssertTrue([alertTitle, okButton].allSatisfy({ $0.exists }))

        okButton.tap()
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
