import XCTest
@testable import Hourglass

// TODO: - Snapshot test is a better solution to create a state for the button and verify its appearance pixel for pixel.

final class ViewModelTests: XCTestCase {

    let (timerPublisher, viewModel) = UnitTestProviders.mockViewModel
    let now = Date.now

    override func setUpWithError() throws {
    }

    override func tearDownWithError() throws {
    }

    /**
     Test starting timer while inactive.
     */
    func testViewModelTimerButtonSelect() {
        let timerModel = viewModel.timerModels[.focus]![0]
        assertTimerDefault(for: timerModel)

        viewModel.didTapTimer(from: timerModel)
        assertTimerInProgress(for: timerModel)

        timerPublisher.send(now)
        assertTimerInProgress(for: timerModel)

        timerPublisher.send(now + 1)
        assertTimerInProgress(for: timerModel)

        timerPublisher.send(now + 2)
        assertTimerComplete(for: timerModel)
    }

    /**
     Test stopping timer while active.
     */
    func testViewModelTimerButtonDeselect() {
        let timerModel = viewModel.timerModels[.focus]![0]
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
    func testViewModelTimerButtonSwapAccept () {
        let timerModelA = viewModel.timerModels[.focus]![0]
        let timerModelB = viewModel.timerModels[.focus]![1]

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
    func testViewModelTimerButtonSwapCancel () {
        let timerModelA = viewModel.timerModels[.focus]![0]
        let timerModelB = viewModel.timerModels[.focus]![1]

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

    private func assertTimerComplete(for timerModel: Hourglass.Timer.Model) {
        XCTAssertEqual(timerModel.state, .inactive)
        XCTAssertTrue(viewModel.viewState.showTimerCompleteAlert)
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
