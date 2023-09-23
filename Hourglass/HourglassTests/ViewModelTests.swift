import XCTest
@testable import Hourglass

// TODO: - Eliminate Singletons
// TODO: - Restructure unit test providers
// TODO: - Snapshot tests to validate timer button state pixel for pixel. (#85)

final class ViewModelTests: XCTestCase {

    let (viewModel,
         dataManager,
         timerModelStateManager,
         timerPublisher,
         settingsManager) = UnitTestProviders.fakeViewModel
    let now = Date.now

    lazy var timerModels: [Int: TimerButton.PresenterModel] = {
        Dictionary(uniqueKeysWithValues: viewModel.timerModels.values.map {($0.length, $0)})
    }()

    var timerModel3s: TimerButton.PresenterModel { timerModels[3]! }
    var timerModel5s: TimerButton.PresenterModel { timerModels[5]! }

    override func setUpWithError() throws {
        verifyTimerButtonInitialStates()
    }

    override func tearDownWithError() throws {
    }

    private func verifyTimerButtonInitialStates() {
        XCTAssert(viewModel.timerModels.values.allSatisfy({$0.state == .inactive}))
    }

    /**
     Test starting timer while inactive.
     */
    func testStartTimerToCompletion() {
        assertUserNotification(.timerDidComplete, count: 0)

        viewModel.didTapTimer(from: timerModel3s)
        assertTimer(timerModel3s, state: .active)
        assertUserNotification(.timerDidComplete, count: 0)

        timerPublisher.send(now)
        assertTimer(timerModel3s, state: .active)
        assertUserNotification(.timerDidComplete, count: 0)

        timerPublisher.send(now + 1)
        assertTimer(timerModel3s, state: .active)
        assertUserNotification(.timerDidComplete, count: 0)

        timerPublisher.send(now + 2)
        assertTimer(timerModel3s, state: .inactive)
        assertUserNotification(.timerDidComplete, count: 1)
    }

    /**
     Test stopping timer while active.
     */
    func testStopTimer() {
        assertUserNotification(.timerDidComplete, count: 0)

        viewModel.didTapTimer(from: timerModel3s)
        timerPublisher.send(now)

        viewModel.didTapTimer(from: timerModel3s)
        assertTimer(timerModel3s, state: .inactive)
        assertUserNotification(.timerDidComplete, count: 0)
    }

    func testTimerCategoryToggle() {
        viewModel.timerCategoryTogglePresenterModel.state = .rest
        XCTAssertEqual(TimerCategory.current, .rest)
        viewModel.timerCategoryTogglePresenterModel.state = .focus
        XCTAssertEqual(TimerCategory.current, .focus)
        viewModel.timerCategoryTogglePresenterModel.state = .restOnly
        XCTAssertEqual(TimerCategory.current, .rest)
        viewModel.timerCategoryTogglePresenterModel.state = .focusOnly
        XCTAssertEqual(TimerCategory.current, .focus)
    }

    /**
     Test accepting start-new-timer flow (starting a new timer while current timer is active via alert response).
     */
    func testStartNewTimerFlowConfirm () {
        viewModel.didTapTimer(from: timerModel3s)
        viewModel.didTapTimer(from: timerModel5s)
        assertRequestingNewTimer(timerModel5s, from: timerModel3s)

        viewModel.didReceiveStartNewTimerDialog(response: .yes)
        viewModel.viewState.showStartNewTimerDialog = false
        assertStartNewTimer(timerModel5s, from: timerModel3s, response: .yes)
    }

    /**
     Test cancelling start-new-timer flow.
     */
    func testStartNewTimerFlowDeny () {
        viewModel.didTapTimer(from: timerModel3s)
        viewModel.didTapTimer(from: timerModel5s)
        assertRequestingNewTimer(timerModel5s, from: timerModel3s)

        viewModel.didReceiveStartNewTimerDialog(response: .no)
        viewModel.viewState.showStartNewTimerDialog = false
        assertStartNewTimer(timerModel5s, from: timerModel3s, response: .no)
    }

    func testRestWarning() {
        settingsManager.setRestWarningThreshold(.k2)
        settingsManager.setEnforceRestThreshold(.off)

        /// Complete 2 focus blocks, trigger rest warning
        viewModel.timerCategoryTogglePresenterModel.state = .focus
        (0..<2).forEach { _ in
            viewModel.didTapTimer(from: timerModel5s)
            runTimer(for: 5)
        }
        assertUserNotification(.timerDidComplete, count: 2)
        assertUserNotification(.restWarningThresholdMet, count: 1)

        /// Complete 2 more focus blocks, no rest warning
        (0..<2).forEach { _ in
            viewModel.didTapTimer(from: timerModel3s)
            runTimer(for: 3)
        }
        assertUserNotification(.timerDidComplete, count: 4)
        assertUserNotification(.restWarningThresholdMet, count: 1)

        /// Complete 1 rest block, reset rest warning trigger
        viewModel.timerCategoryTogglePresenterModel.state = .rest
        viewModel.didTapTimer(from: timerModel3s)
        runTimer(for: 3)
        assertUserNotification(.timerDidComplete, count: 5)
        assertUserNotification(.restWarningThresholdMet, count: 1)

        /// Complete 2 focus blocks again, re-trigger rest warning
        viewModel.timerCategoryTogglePresenterModel.state = .focus
        (0..<2).forEach { _ in
            viewModel.didTapTimer(from: timerModel5s)
            runTimer(for: 5)
        }
        assertUserNotification(.timerDidComplete, count: 7)
        assertUserNotification(.restWarningThresholdMet, count: 2)
    }

    func testEnforceRest() {
        settingsManager.setRestWarningThreshold(.off)
        settingsManager.setEnforceRestThreshold(.k2)
        settingsManager.setGetBackToWork(isEnabled: false)

        viewModel.timerCategoryTogglePresenterModel.state = .focus
        /// Complete 2 focus blocks, trigger enforce rest
        (0..<2).forEach { _ in
            viewModel.didTapTimer(from: timerModel5s)
            runTimer(for: 5)
        }
        assertUserNotification(.enforceRestThresholdMet, count: 1)
        assertTimerCategoryToggleState(.restOnly)

        /// Complete rest block, reset enforce rest trigger
        viewModel.didTapTimer(from: timerModel3s)
        runTimer(for: 3)
        assertTimerCategoryToggleState(.focus)

        /// Complete 2 focus blocks again, re-trigger enforce rest
        (0..<2).forEach { _ in
            viewModel.didTapTimer(from: timerModel5s)
            runTimer(for: 5)
        }
        assertUserNotification(.enforceRestThresholdMet, count: 2)
        assertTimerCategoryToggleState(.restOnly)
    }

    func testGetBackToWork() {
        settingsManager.setRestWarningThreshold(.off)
        settingsManager.setEnforceRestThreshold(.off)
        settingsManager.setGetBackToWork(isEnabled: true)

        viewModel.timerCategoryTogglePresenterModel.state = .focus
        viewModel.didTapTimer(from: timerModel5s)
        runTimer(for: 5)
        assertTimerCategoryToggleState(.focus)

        viewModel.timerCategoryTogglePresenterModel.state = .rest
        viewModel.didTapTimer(from: timerModel3s)
        runTimer(for: 3)
        assertTimerCategoryToggleState(.focusOnly)

        viewModel.didTapTimer(from: timerModel5s)
        runTimer(for: 5)
        assertTimerCategoryToggleState(.focus)
    }

    func testPomodoro() {
        settingsManager.setRestWarningThreshold(.off)
        settingsManager.setEnforceRestThreshold(.k1)
        settingsManager.setGetBackToWork(isEnabled: true)

        viewModel.timerCategoryTogglePresenterModel.state = .focus
        viewModel.didTapTimer(from: timerModel5s)
        runTimer(for: 5)
        assertTimerCategoryToggleState(.restOnly)

        viewModel.didTapTimer(from: timerModel3s)
        runTimer(for: 3)
        assertTimerCategoryToggleState(.focusOnly)

        viewModel.didTapTimer(from: timerModel5s)
        runTimer(for: 5)
        assertTimerCategoryToggleState(.restOnly)
    }

    private func runTimer(for length: Int) {
        (0..<length).forEach { _ in
            timerPublisher.send(now)
        }
    }

    private func assertUserNotification(_ event: HourglassEventKey.Timer, count: Int) {
        XCTAssertEqual(viewModel.notificationCount.timerEvents[event] ?? 0, count)
    }

    private func assertUserNotification(_ event: HourglassEventKey.Progress, count: Int) {
        XCTAssertEqual(viewModel.notificationCount.progressEvents[event] ?? 0, count)
    }

    private func assertTimer(_ timerModel: Hourglass.TimerButton.PresenterModel,
                             state: Hourglass.TimerButton.State) {
        XCTAssertEqual(timerModel.state, state)
    }

    private func assertTimerCategoryToggleState(_ state: TimerCategoryToggle.State) {
        XCTAssertEqual(viewModel.timerCategoryTogglePresenterModel.state, state)
    }

    private func assertStartNewTimer(_ newTimer: Hourglass.TimerButton.PresenterModel,
                                     from currentTimer: Hourglass.TimerButton.PresenterModel,
                                     response: ViewModel.StartNewTimerDialogResponse) {
        switch response {
        case .yes:
            assertTimer(newTimer, state: .active)
            assertTimer(currentTimer, state: .inactive)
        case .no:
            assertTimer(newTimer, state: .inactive)
            assertTimer(currentTimer, state: .active)
        }

        XCTAssertFalse(viewModel.viewState.showStartNewTimerDialog)
    }

    private func assertRequestingNewTimer(_ newTimer: Hourglass.TimerButton.PresenterModel,
                                          from currentTimer: Hourglass.TimerButton.PresenterModel) {
        assertTimer(newTimer, state: .inactive)
        assertTimer(currentTimer, state: .active)
        XCTAssertTrue(viewModel.viewState.showStartNewTimerDialog)
    }
}
