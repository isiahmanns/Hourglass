import XCTest
@testable import Hourglass

// TODO: - Snapshot tests to validate timer button state pixel for pixel. (#85)

final class ViewModelTests: XCTestCase {

    let (viewModel,
         inMemoryStore,
         dataManager,
         timerModelStateManager,
         timerPublisher,
         timerManager,
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
        viewModel.timerModels.values.forEach { timerModel in
            assertTimer(timerModel, state: .inactive)
        }
    }

    /**
     Test starting timer while inactive.
     */
    func testStartTimerToCompletion() {
        assertUserNotification(.timerDidComplete, count: 0)

        viewModel.didTapTimer(from: timerModel3s)
        assertTimerManager(activeTimerId: timerModel3s.id)
        assertTimer(timerModel3s, state: .active)
        assertUserNotification(.timerDidComplete, count: 0)

        timerPublisher.send(now)
        assertTimer(timerModel3s, state: .active)
        assertUserNotification(.timerDidComplete, count: 0)

        timerPublisher.send(now + 1)
        assertTimer(timerModel3s, state: .active)
        assertUserNotification(.timerDidComplete, count: 0)

        timerPublisher.send(now + 2)
        assertTimerManager(activeTimerId: nil)
        assertTimer(timerModel3s, state: .inactive)
        assertUserNotification(.timerDidComplete, count: 1)
        XCTAssertEqual(inMemoryStore.fetch(TimeBlock.fetchRequest())!.count, 1)
    }

    /**
     Test stopping timer while active.
     */
    func testStopTimer() {
        assertUserNotification(.timerDidComplete, count: 0)

        viewModel.didTapTimer(from: timerModel3s)
        assertTimerManager(activeTimerId: timerModel3s.id)
        assertTimer(timerModel3s, state: .active)

        timerPublisher.send(now)
        assertTimer(timerModel3s, state: .active)

        viewModel.didTapTimer(from: timerModel3s)
        assertTimerManager(activeTimerId: nil)
        assertTimer(timerModel3s, state: .inactive)
        assertUserNotification(.timerDidComplete, count: 0)
        XCTAssertEqual(inMemoryStore.fetch(TimeBlock.fetchRequest())!.count, 0)
    }

    func testPersistCompletedTimers() {
        viewModel.timerCategoryTogglePresenterModel.state = .focus
        settingsManager.setEnforceRestThreshold(2)

        viewModel.didTapTimer(from: timerModel3s)
        (0..<3).forEach { _ in
            timerPublisher.send(now)
        }

        (0..<2).forEach { _ in
            viewModel.didTapTimer(from: timerModel5s)
            (0..<5).forEach { _ in
                timerPublisher.send(now)
            }
        }

        let timeBlocks = inMemoryStore.fetch(TimeBlock.fetchRequest())!
        XCTAssertEqual(timeBlocks.count, 3)

        let categories = timeBlocks.reduce(into: [TimerCategory: Int]()) { partialResult, value in
            partialResult[TimerCategory(rawValue: Int(value.category)), default: 0] += 1
        }
        XCTAssertEqual(categories[.focus], 2)
        XCTAssertEqual(categories[.rest], 1)
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
        let timerModel3sFocus = timerModel3s
        settingsManager.setRestWarningThreshold(2)

        viewModel.didTapTimer(from: timerModel3sFocus)
        (0..<3).forEach { _ in
            timerPublisher.send(now)
        }
        assertUserNotification(.timerDidComplete, count: 1)
        assertUserNotification(.restWarningThresholdMet, count: 0)

        viewModel.didTapTimer(from: timerModel3sFocus)
        (0..<3).forEach { _ in
            timerPublisher.send(now)
        }
        assertUserNotification(.timerDidComplete, count: 2)
        assertUserNotification(.restWarningThresholdMet, count: 1)
    }

    /*
    func testRestWarningResetAfterCompletedRestBlock() {
        let timerModel3sFocus = timerModels[.focus]![0]
        let timerModel5sRest = timerModels[.rest]![0]
        settingsManager.setRestWarningThreshold(2)

        // Complete focus blocks
        viewModel.didTapTimer(from: timerModel3sFocus)
        (0..<3).forEach { _ in
            timerPublisher.send(now)
        }
        assertUserNotification(.timerDidComplete, count: 1)
        assertUserNotification(.restWarningThresholdMet, count: 0)

        viewModel.didTapTimer(from: timerModel3sFocus)
        (0..<3).forEach { _ in
            timerPublisher.send(now)
        }
        assertUserNotification(.timerDidComplete, count: 2)
        assertUserNotification(.restWarningThresholdMet, count: 1)

        // Complete rest block
        viewModel.didTapTimer(from: timerModel5sRest)
        (0..<5).forEach { _ in
            timerPublisher.send(now)
        }
        assertUserNotification(.timerDidComplete, count: 3)

        // Run focus blocks and verify that rest warning is triggered again
        (0..<2).forEach { _ in
            viewModel.didTapTimer(from: timerModel3sFocus)
            (0..<3).forEach { _ in
                timerPublisher.send(now)
            }
        }
        assertUserNotification(.timerDidComplete, count: 5)
        assertUserNotification(.restWarningThresholdMet, count: 2)
    }

    func testRestWarningDoesNotResetAfterIncompleteRestBlock() {
        let timerModel3sFocus = timerModels[.focus]![0]
        let timerModel5sRest = timerModels[.rest]![0]
        settingsManager.setRestWarningThreshold(1)

        // Complete focus block
        viewModel.didTapTimer(from: timerModel3sFocus)
        (0..<3).forEach { _ in
            timerPublisher.send(now)
        }
        // Verify rest warning is triggered
        assertUserNotification(.timerDidComplete, count: 1)
        assertUserNotification(.restWarningThresholdMet, count: 1)

        // Start and cancel rest block
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

    func testEnforceRest() {
        let timerModel3sFocus = timerModels[.focus]![0]
        settingsManager.setEnforceRestThreshold(2)

        viewModel.didTapTimer(from: timerModel3sFocus)
        (0..<3).forEach { _ in
            timerPublisher.send(now)
        }
        assertUserNotification(.timerDidComplete, count: 1)
        assertUserNotification(.enforceRestThresholdMet, count: 0)

        viewModel.didTapTimer(from: timerModel3sFocus)
        (0..<3).forEach { _ in
            timerPublisher.send(now)
        }
        assertUserNotification(.timerDidComplete, count: 2)
        assertUserNotification(.enforceRestThresholdMet, count: 1)
        assertTimer(timerModel3sFocus, state: .disabled)
    }

    func testEnforceRestResetAfterCompletedRestBlock() {
        let timerModel3sFocus = timerModels[.focus]![0]
        let timerModel5sRest = timerModels[.rest]![0]
        settingsManager.setEnforceRestThreshold(2)

        // Complete focus blocks
        viewModel.didTapTimer(from: timerModel3sFocus)
        (0..<3).forEach { _ in
            timerPublisher.send(now)
        }
        assertUserNotification(.timerDidComplete, count: 1)
        assertUserNotification(.enforceRestThresholdMet, count: 0)

        viewModel.didTapTimer(from: timerModel3sFocus)
        (0..<3).forEach { _ in
            timerPublisher.send(now)
        }
        // Verify enforce rest is triggered
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
        assertTimer(timerModel3sFocus, state: .inactive)

        // Complete focus blocks and verify that enforce rest is triggered again
        (0..<2).forEach { _  in
            viewModel.didTapTimer(from: timerModel3sFocus)
            (0..<3).forEach { _ in
                timerPublisher.send(now)
            }
        }
        // Verify that enforce rest is triggered again
        assertUserNotification(.timerDidComplete, count: 5)
        assertUserNotification(.enforceRestThresholdMet, count: 2)
        assertTimer(timerModel3sFocus, state: .disabled)
    }

    func testEnforceRestDoesNotResetAfterIncompleteRestBlock() {
        let timerModel3sFocus = timerModels[.focus]![0]
        let timerModel5sRest = timerModels[.rest]![0]
        settingsManager.setEnforceRestThreshold(1)

        // Complete focus block
        viewModel.didTapTimer(from: timerModel3sFocus)
        (0..<3).forEach { _ in
            timerPublisher.send(now)
        }
        // Verify enforce rest is triggered
        assertUserNotification(.timerDidComplete, count: 1)
        assertUserNotification(.enforceRestThresholdMet, count: 1)
        assertTimer(timerModel3sFocus, state: .disabled)

        // Start and cancel rest block
        viewModel.didTapTimer(from: timerModel5sRest)
        timerPublisher.send(now)
        viewModel.didTapTimer(from: timerModel5sRest)

        // Verify that enforce rest is *still* triggered
        assertUserNotification(.timerDidComplete, count: 1)
        assertUserNotification(.enforceRestThresholdMet, count: 1)
        assertTimer(timerModel3sFocus, state: .disabled)
    }

    func testRestWarningWithEnforceRestHappyPath() {
        let timerModel3sFocus = timerModels[.focus]![0]
        settingsManager.setRestWarningThreshold(1)
        settingsManager.setEnforceRestThreshold(3)

        // Run focus blocks
        viewModel.didTapTimer(from: timerModel3sFocus)
        (0..<3).forEach { _ in
            timerPublisher.send(now)
        }
        assertUserNotification(.timerDidComplete, count: 1)
        assertUserNotification(.enforceRestThresholdMet, count: 0)
        assertUserNotification(.restWarningThresholdMet, count: 1)
        assertTimer(timerModel3sFocus, state: .inactive)

        viewModel.didTapTimer(from: timerModel3sFocus)
        (0..<3).forEach { _ in
            timerPublisher.send(now)
        }
        assertUserNotification(.timerDidComplete, count: 2)
        assertUserNotification(.enforceRestThresholdMet, count: 0)
        assertUserNotification(.restWarningThresholdMet, count: 1)
        assertTimer(timerModel3sFocus, state: .inactive)

        viewModel.didTapTimer(from: timerModel3sFocus)
        (0..<3).forEach { _ in
            timerPublisher.send(now)
        }
        assertUserNotification(.timerDidComplete, count: 3)
        assertUserNotification(.enforceRestThresholdMet, count: 1)
        assertUserNotification(.restWarningThresholdMet, count: 1)
        assertTimer(timerModel3sFocus, state: .disabled)
    }

    func testRestWarningAndEnforceRestOff() {
        let timerModel3sFocus = timerModels[.focus]![0]
        settingsManager.setRestWarningThreshold(-1)
        settingsManager.setEnforceRestThreshold(-1)

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
        assertUserNotification(.getBackToWork, count: 1)
        assertTimer(timerModel5sRest, state: .disabled)
        assertTimer(timerModel3sFocus, state: .inactive)

        // Complete focus block
        viewModel.didTapTimer(from: timerModel3sFocus)
        (0..<3).forEach { _ in
            timerPublisher.send(now)
        }
        assertTimer(timerModel5sRest, state: .inactive)
        assertTimer(timerModel3sFocus, state: .inactive)
    }

    func testGetBackToWorkAndEnforceRest() {
        let timerModel3sFocus = timerModels[.focus]![0]
        let timerModel5sRest = timerModels[.rest]![0]
        settingsManager.setEnforceRestThreshold(2)
        settingsManager.setGetBackToWork(isEnabled: true)

        // Complete rest block
        viewModel.didTapTimer(from: timerModel5sRest)
        (0..<5).forEach { _ in
            timerPublisher.send(now)
        }
        assertUserNotification(.getBackToWork, count: 1)
        assertTimer(timerModel5sRest, state: .disabled)
        assertTimer(timerModel3sFocus, state: .inactive)

        // Complete focus blocks
        viewModel.didTapTimer(from: timerModel3sFocus)
        (0..<3).forEach { _ in
            timerPublisher.send(now)
        }
        assertTimer(timerModel5sRest, state: .inactive)
        assertTimer(timerModel3sFocus, state: .inactive)

        viewModel.didTapTimer(from: timerModel3sFocus)
        (0..<3).forEach { _ in
            timerPublisher.send(now)
        }
        assertTimer(timerModel5sRest, state: .inactive)
        assertTimer(timerModel3sFocus, state: .disabled)

        assertUserNotification(.enforceRestThresholdMet, count: 1)
    }
     */

    private func assertTimerCategoryToggleState(_ state: TimerCategoryToggle.State) {
        XCTAssertEqual(viewModel.timerCategoryTogglePresenterModel.state, state)
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

    private func assertTimerManager(activeTimerId: Hourglass.TimerButton.PresenterModel.ID?) {
        XCTAssertEqual(timerManager.activeTimerModelId, activeTimerId)
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
