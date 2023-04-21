import XCTest
@testable import Hourglass

// TODO: - Snapshot test is a better solution to create a state for the button and verify its appearance pixel for pixel.

final class ViewModelTests: XCTestCase {

    let (viewModel,
         timerModelStateManager,
         timerPublisher,
         userNotificationManager,
         settingsManager) = UnitTestProviders.fakeViewModel
    let now = Date.now

    var viewModelTimerModels: [Hourglass.Timer.Model] {
        viewModel.timerModels.values
            .sorted(by: { $0.length < $1.length })
    }

    override func setUpWithError() throws {
    }

    override func tearDownWithError() throws {
    }

    /**
     Test starting timer while inactive. Popup, Sound On
     */
    func testStartTimerToCompletionPopupSoundOn() {
        let timerModel = viewModelTimerModels[0]
        let notificationStyle: NotificationStyle = .popup
        let soundIsEnabled = true
        settingsManager.setNotification(style: notificationStyle)
        settingsManager.setSound(isEnabled: soundIsEnabled)

        assertTimerDefault(for: timerModel)

        viewModel.didTapTimer(from: timerModel)
        assertTimerInProgress(for: timerModel)

        timerPublisher.send(now)
        assertTimerInProgress(for: timerModel)

        timerPublisher.send(now + 1)
        assertTimerInProgress(for: timerModel)

        timerPublisher.send(now + 2)
        assertTimerComplete(for: timerModel,
                            notificationStyle: notificationStyle,
                            soundIsEnabled: soundIsEnabled)
    }

    /**
     Test starting timer while inactive.  Popup, Sound Off
     */
    func testStartTimerToCompletionPopupSoundOff() {
        let timerModel = viewModelTimerModels[0]
        let notificationStyle: NotificationStyle = .popup
        let soundIsEnabled = false
        settingsManager.setNotification(style: notificationStyle)
        settingsManager.setSound(isEnabled: soundIsEnabled)

        viewModel.didTapTimer(from: timerModel)
        timerPublisher.send(now)
        timerPublisher.send(now + 1)
        timerPublisher.send(now + 2)

        assertTimerComplete(for: timerModel,
                            notificationStyle: notificationStyle,
                            soundIsEnabled: soundIsEnabled)
    }

    /**
     Test starting timer while inactive.  Banner, Sound On
     */
    func testStartTimerToCompletionBannerSoundOn() {
        let timerModel = viewModelTimerModels[0]
        let notificationStyle: NotificationStyle = .banner
        let soundIsEnabled = true
        settingsManager.setNotification(style: notificationStyle)
        settingsManager.setSound(isEnabled: soundIsEnabled)

        viewModel.didTapTimer(from: timerModel)
        timerPublisher.send(now)
        timerPublisher.send(now + 1)
        timerPublisher.send(now + 2)

        assertTimerComplete(for: timerModel,
                            notificationStyle: notificationStyle,
                            soundIsEnabled: soundIsEnabled)
    }

    /**
     Test starting timer while inactive.  Banner, Sound Off
     */
    func testStartTimerToCompletionBannerSoundOff() {
        let timerModel = viewModelTimerModels[0]
        let notificationStyle: NotificationStyle = .banner
        let soundIsEnabled = false
        settingsManager.setNotification(style: notificationStyle)
        settingsManager.setSound(isEnabled: soundIsEnabled)

        viewModel.didTapTimer(from: timerModel)
        timerPublisher.send(now)
        timerPublisher.send(now + 1)
        timerPublisher.send(now + 2)

        assertTimerComplete(for: timerModel,
                            notificationStyle: notificationStyle,
                            soundIsEnabled: soundIsEnabled)
    }

    /**
     Test stopping timer while active.
     */
    func testStopTimer() {
        let timerModel = viewModelTimerModels[0]
        assertTimerDefault(for: timerModel)

        viewModel.didTapTimer(from: timerModel)
        assertTimerInProgress(for: timerModel)

        timerPublisher.send(now)
        assertTimerInProgress(for: timerModel)

        viewModel.didTapTimer(from: timerModel)
        assertTimerDefault(for: timerModel)
    }

    /**
     Test accepting start-new-timer flow (starting a new timer while current timer is active via alert response).
     */
    func testStartNewTimerFlowConfirm () {
        let timerModelA = viewModelTimerModels[0]
        let timerModelB = viewModelTimerModels[1]

        viewModel.didTapTimer(from: timerModelA)
        viewModel.didTapTimer(from: timerModelB)
        assertRequestingNewTimer(timerModelB, from: timerModelA)

        viewModel.didReceiveStartNewTimerDialog(response: .yes)
        viewModel.viewState.showStartNewTimerDialog = false
        assertStartNewTimer(timerModelB, from: timerModelA, response: .yes)
    }

    /**
     Test cancelling start-new-timer flow.
     */
    func testStartNewTimerFlowDeny () {
        let timerModelA = viewModelTimerModels[0]
        let timerModelB = viewModelTimerModels[1]

        viewModel.didTapTimer(from: timerModelA)
        viewModel.didTapTimer(from: timerModelB)
        assertRequestingNewTimer(timerModelB, from: timerModelA)

        viewModel.didReceiveStartNewTimerDialog(response: .no)
        viewModel.viewState.showStartNewTimerDialog = false
        assertStartNewTimer(timerModelB, from: timerModelA, response: .no)
    }

    private func assertTimerInProgress(for timerModel: Hourglass.Timer.Model) {
        XCTAssertEqual(timerModel.state, .active)
        XCTAssertFalse(viewModel.viewState.showTimerCompleteAlert)
    }

    private func assertTimerComplete(for timerModel: Hourglass.Timer.Model,
                                     notificationStyle: NotificationStyle,
                                     soundIsEnabled: Bool) {
        XCTAssertEqual(timerModel.state, .inactive)

        switch (notificationStyle, soundIsEnabled) {
        case (.banner, _):
            XCTAssertTrue(userNotificationManager.didFireNotification)
            XCTAssertFalse(viewModel.viewState.showTimerCompleteAlert)
        case (.popup, true):
            XCTAssertTrue(userNotificationManager.didFireNotification)
            XCTAssertTrue(viewModel.viewState.showTimerCompleteAlert)
        case (.popup, false):
            XCTAssertFalse(userNotificationManager.didFireNotification)
            XCTAssertTrue(viewModel.viewState.showTimerCompleteAlert)
        }
    }

    private func assertTimerDefault(for timerModel: Hourglass.Timer.Model) {
        XCTAssertEqual(timerModel.state, .inactive)
        XCTAssertFalse(viewModel.viewState.showTimerCompleteAlert)
    }

    private func assertStartNewTimer(_ newTimer: Hourglass.Timer.Model,
                                     from currentTimer: Hourglass.Timer.Model,
                                     response: ViewModel.StartNewTimerDialogResponse) {
        switch response {
        case .yes:
            XCTAssertEqual(newTimer.state, .active)
            XCTAssertEqual(currentTimer.state, .inactive)
            XCTAssertFalse(viewModel.viewState.showTimerCompleteAlert)
        case .no:
            XCTAssertEqual(newTimer.state, .inactive)
            XCTAssertEqual(currentTimer.state, .active)
        }

        XCTAssertFalse(viewModel.viewState.showStartNewTimerDialog)
    }

    private func assertRequestingNewTimer(_ newTimer: Hourglass.Timer.Model,
                                          from currentTimer: Hourglass.Timer.Model) {
        XCTAssertEqual(newTimer.state, .inactive)
        XCTAssertEqual(currentTimer.state, .active)
        XCTAssertTrue(viewModel.viewState.showStartNewTimerDialog)
    }
}
