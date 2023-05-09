import XCTest
@testable import Hourglass

// TODO: - Snapshot test is a better solution to create a state for the button and verify its appearance pixel for pixel.

final class ViewModelTests: XCTestCase {

    let (viewModel,
         timerModelStateManager,
         timerPublisher,
         timerManager,
         settingsManager) = UnitTestProviders.fakeViewModel
    let now = Date.now

    lazy var timerModels: [Hourglass.Timer.Category: [Hourglass.Timer.Model]] = {
        Dictionary(grouping: Array(viewModel.timerModels.values).sortByLength(),
                   by: { $0.category })
    }()

    override func setUpWithError() throws {
        verifyTimerButtonInitialStates()
    }

    override func tearDownWithError() throws {
    }

    private func verifyTimerButtonInitialStates() {
        viewModel.timerModels.values.forEach { timerModel in
            assertTimer(timerModel, state: .inactive)
        }
    }

    /**
     Test starting timer while inactive.
     */
    func testStartTimerToCompletion() {
        let timerModel = timerModels[.focus]![0]

        assertUserNotification(.timerDidComplete, count: 0)

        viewModel.didTapTimer(from: timerModel)
        assertTimerManager(activeTimerId: timerModel.id)
        assertTimer(timerModel, state: .active)
        assertUserNotification(.timerDidComplete, count: 0)

        timerPublisher.send(now)
        assertTimer(timerModel, state: .active)
        assertUserNotification(.timerDidComplete, count: 0)

        timerPublisher.send(now + 1)
        assertTimer(timerModel, state: .active)
        assertUserNotification(.timerDidComplete, count: 0)

        timerPublisher.send(now + 2)
        assertTimerManager(activeTimerId: nil)
        assertTimer(timerModel, state: .inactive)
        assertUserNotification(.timerDidComplete, count: 1)
    }

    /**
     Test stopping timer while active.
     */
    func testStopTimer() {
        let timerModel = timerModels[.focus]![0]

        assertUserNotification(.timerDidComplete, count: 0)

        viewModel.didTapTimer(from: timerModel)
        assertTimerManager(activeTimerId: timerModel.id)
        assertTimer(timerModel, state: .active)

        timerPublisher.send(now)
        assertTimer(timerModel, state: .active)

        viewModel.didTapTimer(from: timerModel)
        assertTimerManager(activeTimerId: nil)
        assertTimer(timerModel, state: .inactive)
        assertUserNotification(.timerDidComplete, count: 0)
    }

    // TODO: - Test set timer, verify that new length is respected

    /**
     Test accepting start-new-timer flow (starting a new timer while current timer is active via alert response).
     */
    func testStartNewTimerFlowConfirm () {
        let timerModelA = timerModels[.focus]![0]
        let timerModelB = timerModels[.rest]![0]

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
        let timerModelA = timerModels[.focus]![0]
        let timerModelB = timerModels[.rest]![0]

        viewModel.didTapTimer(from: timerModelA)
        viewModel.didTapTimer(from: timerModelB)
        assertRequestingNewTimer(timerModelB, from: timerModelA)

        viewModel.didReceiveStartNewTimerDialog(response: .no)
        viewModel.viewState.showStartNewTimerDialog = false
        assertStartNewTimer(timerModelB, from: timerModelA, response: .no)
    }

    func testRestWarning() {
        let timerModel = timerModels[.focus]![0]
        settingsManager.setRestWarningThreshold(2)

        viewModel.didTapTimer(from: timerModel)
        (0..<2).forEach { _ in
            timerPublisher.send(now)
        }

        assertUserNotification(.timerDidComplete, count: 0)
        assertUserNotification(.restWarningThresholdMet, count: 1)
    }

    func testRestWarningResetAfterCompletedRestBlock() {
        let timerModel3sFocus = timerModels[.focus]![0]
        let timerModel5sRest = timerModels[.rest]![0]
        settingsManager.setRestWarningThreshold(5)

        // Complete 3s focus block
        viewModel.didTapTimer(from: timerModel3sFocus)
        (0..<3).forEach { _ in
            timerPublisher.send(now)
        }

        assertUserNotification(.timerDidComplete, count: 1)
        assertUserNotification(.restWarningThresholdMet, count: 0)

        // Start another 3s focus block
        viewModel.didTapTimer(from: timerModel3sFocus)
        (0..<2).forEach { _ in
            timerPublisher.send(now)
        }

        // Verify rest warning is triggered
        assertUserNotification(.timerDidComplete, count: 1)
        assertUserNotification(.restWarningThresholdMet, count: 1)

        timerPublisher.send(now)
        assertUserNotification(.timerDidComplete, count: 2)

        // Complete rest block
        viewModel.didTapTimer(from: timerModel5sRest)
        (0..<5).forEach { _ in
            timerPublisher.send(now)
        }
        assertUserNotification(.timerDidComplete, count: 3)

        // Run focus blocks and verify that rest warning is triggered again
        viewModel.didTapTimer(from: timerModel3sFocus)
        (0..<3).forEach { _ in
            timerPublisher.send(now)
        }
        assertUserNotification(.timerDidComplete, count: 4)

        viewModel.didTapTimer(from: timerModel3sFocus)
        (0..<2).forEach { _ in
            timerPublisher.send(now)
        }
        assertUserNotification(.timerDidComplete, count: 4)
        assertUserNotification(.restWarningThresholdMet, count: 2)
    }

    func testRestWarningDoesNotResetAfterIncompleteRestBlock() {
        let timerModel3sFocus = timerModels[.focus]![0]
        let timerModel5sRest = timerModels[.rest]![0]
        settingsManager.setRestWarningThreshold(2)

        // Run focus block
        viewModel.didTapTimer(from: timerModel3sFocus)
        (0..<2).forEach { _ in
            timerPublisher.send(now)
        }

        // Verify rest warning is triggered
        assertUserNotification(.timerDidComplete, count: 0)
        assertUserNotification(.restWarningThresholdMet, count: 1)

        timerPublisher.send(now)
        assertUserNotification(.timerDidComplete, count: 1)
        assertUserNotification(.restWarningThresholdMet, count: 1)

        // Cancel rest block
        viewModel.didTapTimer(from: timerModel5sRest)
        timerPublisher.send(now)
        viewModel.didTapTimer(from: timerModel5sRest)

        assertUserNotification(.timerDidComplete, count: 1)
        assertUserNotification(.restWarningThresholdMet, count: 1)

        // Run another focus block and verify that rest warning is *not* triggered again
        viewModel.didTapTimer(from: timerModel3sFocus)
        (0..<3).forEach { _ in
            timerPublisher.send(now)
        }
        assertUserNotification(.timerDidComplete, count: 2)
        assertUserNotification(.restWarningThresholdMet, count: 1)
    }

    func testRestWarningContinuesAfterCancelledFocusBlock() {
        let timerModel3sFocus = timerModels[.focus]![0]
        settingsManager.setRestWarningThreshold(5)

        // Start and cancel 3s focus block
        viewModel.didTapTimer(from: timerModel3sFocus)
        (0..<2).forEach { _ in
            timerPublisher.send(now)
        }
        viewModel.didTapTimer(from: timerModel3sFocus)

        assertUserNotification(.timerDidComplete, count: 0)
        assertUserNotification(.restWarningThresholdMet, count: 0)

        // Start 3s focus block again
        viewModel.didTapTimer(from: timerModel3sFocus)
        (0..<3).forEach { _ in
            timerPublisher.send(now)
        }

        // Verify rest warning is triggered
        assertUserNotification(.timerDidComplete, count: 1)
        assertUserNotification(.restWarningThresholdMet, count: 1)
    }

    func testEnforceRestOnTimerComplete() {
        let timerModel3sFocus = timerModels[.focus]![0]
        settingsManager.setEnforceRestThreshold(5)

        // Complete 3s focus block
        viewModel.didTapTimer(from: timerModel3sFocus)
        (0..<3).forEach { _ in
            timerPublisher.send(now)
        }
        assertUserNotification(.timerDidComplete, count: 1)
        assertUserNotification(.enforceRestThresholdMet, count: 0)

        // Start another 3s focus block
        viewModel.didTapTimer(from: timerModel3sFocus)
        (0..<2).forEach { _ in
            timerPublisher.send(now)
        }
        assertUserNotification(.timerDidComplete, count: 1)
        assertUserNotification(.enforceRestThresholdMet, count: 0)

        // Verify enforce rest is triggered when timer is complete
        timerPublisher.send(now)
        assertUserNotification(.timerDidComplete, count: 2)
        assertUserNotification(.enforceRestThresholdMet, count: 1)
        assertTimer(timerModel3sFocus, state: .disabled)
    }

    func testEnforceRestOnTimerCancel() {
        let timerModel3sFocus = timerModels[.focus]![0]
        settingsManager.setEnforceRestThreshold(2)

        // Run focus block
        viewModel.didTapTimer(from: timerModel3sFocus)
        (0..<2).forEach { _ in
            timerPublisher.send(now)
        }

        // Cancel focus block
        viewModel.didTapTimer(from: timerModel3sFocus)

        assertUserNotification(.timerDidComplete, count: 0)
        assertUserNotification(.enforceRestThresholdMet, count: 1)
        assertTimer(timerModel3sFocus, state: .disabled)
    }

    func testEnforceRestResetAfterCompletedRestBlock() {
        let timerModel3sFocus = timerModels[.focus]![0]
        let timerModel5sRest = timerModels[.rest]![0]
        settingsManager.setEnforceRestThreshold(5)

        // Complete 2 focus blocks
        viewModel.didTapTimer(from: timerModel3sFocus)
        (0..<3).forEach { _ in
            timerPublisher.send(now)
        }
        viewModel.didTapTimer(from: timerModel3sFocus)
        (0..<3).forEach { _ in
            timerPublisher.send(now)
        }

        // Verify enforce rest is triggered when timer is complete
        assertUserNotification(.timerDidComplete, count: 2)
        assertUserNotification(.enforceRestThresholdMet, count: 1)
        assertTimer(timerModel3sFocus, state: .disabled)

        // Complete rest block
        viewModel.didTapTimer(from: timerModel5sRest)
        (0..<5).forEach { _ in
            timerPublisher.send(now)
        }

        // Verify that enforce rest is de-triggered
        assertUserNotification(.timerDidComplete, count: 3)
        assertUserNotification(.enforceRestThresholdMet, count: 1)
        assertTimer(timerModel3sFocus, state: .inactive)

        // Complete 2 focus blocks again
        viewModel.didTapTimer(from: timerModel3sFocus)
        (0..<3).forEach { _ in
            timerPublisher.send(now)
        }
        viewModel.didTapTimer(from: timerModel3sFocus)
        (0..<3).forEach { _ in
            timerPublisher.send(now)
        }

        // Verify that enforce rest is triggered again
        assertUserNotification(.timerDidComplete, count: 5)
        assertUserNotification(.enforceRestThresholdMet, count: 2)
        assertTimer(timerModel3sFocus, state: .disabled)
    }

    func testEnforceRestDoesNotResetAfterIncompleteRestBlock() {
        let timerModel3sFocus = timerModels[.focus]![0]
        let timerModel5sRest = timerModels[.rest]![0]
        settingsManager.setEnforceRestThreshold(5)

        // Complete 2 focus blocks
        viewModel.didTapTimer(from: timerModel3sFocus)
        (0..<3).forEach { _ in
            timerPublisher.send(now)
        }
        viewModel.didTapTimer(from: timerModel3sFocus)
        (0..<3).forEach { _ in
            timerPublisher.send(now)
        }

        // Verify enforce rest is triggered when timer is complete
        assertUserNotification(.timerDidComplete, count: 2)
        assertUserNotification(.enforceRestThresholdMet, count: 1)
        assertTimer(timerModel3sFocus, state: .disabled)

        // Start and cancel rest block
        viewModel.didTapTimer(from: timerModel5sRest)
        (0..<4).forEach { _ in
            timerPublisher.send(now)
        }
        viewModel.didTapTimer(from: timerModel5sRest)

        // Verify that enforce rest is *still* triggered
        assertUserNotification(.timerDidComplete, count: 2)
        assertUserNotification(.enforceRestThresholdMet, count: 1)
        assertTimer(timerModel3sFocus, state: .disabled)
    }

    func testEnforceRestContinuesAfterCancelledFocusBlock() {
        let timerModel3sFocus = timerModels[.focus]![0]
        settingsManager.setEnforceRestThreshold(5)

        // Start and cancel focus block
        viewModel.didTapTimer(from: timerModel3sFocus)
        timerPublisher.send(now)
        viewModel.didTapTimer(from: timerModel3sFocus)

        assertUserNotification(.timerDidComplete, count: 0)
        assertUserNotification(.enforceRestThresholdMet, count: 0)

        // Complete focus block
        viewModel.didTapTimer(from: timerModel3sFocus)
        (0..<3).forEach { _ in
            timerPublisher.send(now)
        }
        assertUserNotification(.timerDidComplete, count: 1)
        assertUserNotification(.enforceRestThresholdMet, count: 0)

        // Start and cancel focus block
        viewModel.didTapTimer(from: timerModel3sFocus)
        timerPublisher.send(now)
        viewModel.didTapTimer(from: timerModel3sFocus)

        // Verify enforce rest is triggered when timer is complete
        assertUserNotification(.timerDidComplete, count: 1)
        assertUserNotification(.enforceRestThresholdMet, count: 1)
        assertTimer(timerModel3sFocus, state: .disabled)
    }

    func testRestWarningWithEnforceRestHappyPath() {
        let timerModel3sFocus = timerModels[.focus]![0]
        settingsManager.setRestWarningThreshold(2)
        settingsManager.setEnforceRestThreshold(5)

        // Run focus block
        viewModel.didTapTimer(from: timerModel3sFocus)
        (0..<2).forEach { _ in
            timerPublisher.send(now)
        }
        assertUserNotification(.timerDidComplete, count: 0)
        assertUserNotification(.enforceRestThresholdMet, count: 0)
        assertUserNotification(.restWarningThresholdMet, count: 1)
        assertTimer(timerModel3sFocus, state: .active)

        // Complete focus block
        timerPublisher.send(now)
        assertUserNotification(.timerDidComplete, count: 1)
        assertUserNotification(.enforceRestThresholdMet, count: 0)
        assertUserNotification(.restWarningThresholdMet, count: 1)
        assertTimer(timerModel3sFocus, state: .inactive)

        // Complete another focus block
        viewModel.didTapTimer(from: timerModel3sFocus)
        (0..<3).forEach { _ in
            timerPublisher.send(now)
        }
        assertUserNotification(.timerDidComplete, count: 2)
        assertUserNotification(.enforceRestThresholdMet, count: 1)
        assertUserNotification(.restWarningThresholdMet, count: 1)
        assertTimer(timerModel3sFocus, state: .disabled)
    }

    func testRestWarningAndEnforceRestOff() {
        let timerModel3sFocus = timerModels[.focus]![0]
        settingsManager.setRestWarningThreshold(0)
        settingsManager.setEnforceRestThreshold(0)

        // Run focus block twice
        (0..<2).forEach { _ in
            viewModel.didTapTimer(from: timerModel3sFocus)
            (0..<3).forEach { _ in
                timerPublisher.send(now)
            }
        }

        assertUserNotification(.timerDidComplete, count: 2)
        assertUserNotification(.enforceRestThresholdMet, count: 0)
        assertUserNotification(.restWarningThresholdMet, count: 0)
        assertTimer(timerModel3sFocus, state: .inactive)
    }

    /**
     Test that when getBackToWork is enabled, after completing a rest block, you cannot start another rest block until a focus block has been completed.
     */
    func testGetBackToWork() {
        let timerModel3sFocus = timerModels[.focus]![0]
        let timerModel5sRest = timerModels[.rest]![0]
        settingsManager.setGetBackToWork(isEnabled: true)

        // Complete rest block
        viewModel.didTapTimer(from: timerModel5sRest)
        (0..<5).forEach { _ in
            timerPublisher.send(now)
        }

        // Verify rest timer disabled after completion
        assertUserNotification(.timerDidComplete, count: 1)
        assertTimer(timerModel5sRest, state: .disabled)

        // Run focus block
        viewModel.didTapTimer(from: timerModel3sFocus)
        (0..<2).forEach { _ in
            timerPublisher.send(now)
        }

        // Verify rest timer is still disabled while focus timer runs
        assertUserNotification(.timerDidComplete, count: 1)
        assertTimer(timerModel3sFocus, state: .active)
        assertTimer(timerModel5sRest, state: .disabled)

        // Complete focus block
        timerPublisher.send(now)

        // Verify rest timer is enabled when focus timer completes
        assertUserNotification(.timerDidComplete, count: 2)
        assertTimer(timerModel3sFocus, state: .inactive)
        assertTimer(timerModel5sRest, state: .inactive)
    }

    private func assertUserNotification(_ event: HourglassEventKey.Timer, count: Int) {
        XCTAssertEqual(viewModel.notificationCount.timerEvents[event] ?? 0, count)
    }

    private func assertUserNotification(_ event: HourglassEventKey.Progress, count: Int) {
        XCTAssertEqual(viewModel.notificationCount.progressEvents[event] ?? 0, count)
    }

    private func assertTimer(_ timerModel: Hourglass.Timer.Model,
                             state: Hourglass.Timer.State) {
        XCTAssertEqual(timerModel.state, state)
    }

    private func assertTimerManager(activeTimerId: Hourglass.Timer.Model.ID?) {
        XCTAssertEqual(timerManager.activeTimerModelId, activeTimerId)
    }

    private func assertStartNewTimer(_ newTimer: Hourglass.Timer.Model,
                                     from currentTimer: Hourglass.Timer.Model,
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

    private func assertRequestingNewTimer(_ newTimer: Hourglass.Timer.Model,
                                          from currentTimer: Hourglass.Timer.Model) {
        assertTimer(newTimer, state: .inactive)
        assertTimer(currentTimer, state: .active)
        XCTAssertTrue(viewModel.viewState.showStartNewTimerDialog)
    }
}
