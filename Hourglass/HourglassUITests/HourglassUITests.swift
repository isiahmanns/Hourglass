import XCTest

// TODO: - Test toggling timer category state flows
final class HourglassUITests: XCTestCase {
    var app: XCUIApplication!
    var timerButtons: [XCUIElement]!

    override func setUp() {
        continueAfterFailure = false

        app = XCUIApplication()
        app.launchMenu()
        let predicate = NSPredicate(format: "identifier contains 'timer-button'")
        timerButtons = app.buttons.containing(predicate).allElementsBoundByIndex
    }

    func testMainUI() {
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
        timerButtons[3].tap()

        let alert = app.sheets["alert"]
        let alertTitle = alert.staticTexts["Are you sure you want to start a new timer?"]
        let affirmButton = alert.buttons["Start timer"]
        let denyButton = alert.buttons["Cancel"]
        XCTAssertTrue([alertTitle, affirmButton, denyButton].allSatisfy({ $0.exists }))

        affirmButton.tap()
        XCTAssertEqual(app.statusItems["menu-bar-button"].title, "00:20")
    }

    func testStartNewTimerFlowDeny() {
        timerButtons[1].tap()
        timerButtons[0].tap()

        let alert = app.sheets["alert"]
        let alertTitle = alert.staticTexts["Are you sure you want to start a new timer?"]
        let affirmButton = alert.buttons["Start timer"]
        let denyButton = alert.buttons["Cancel"]
        XCTAssertTrue([alertTitle, affirmButton, denyButton].allSatisfy({ $0.exists }))


        denyButton.tap()
        let timestamp = app.statusItems["menu-bar-button"].title
        let remainingSec = Int(timestamp.split(separator: ":").last!)!
        XCTAssertLessThan(remainingSec, 10)
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

        let alert = app.sheets["alert"]
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
