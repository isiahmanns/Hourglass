import Combine
import XCTest
@testable import Hourglass

/**
 UnitTests:
  - TimerButton test for tapping an inactive button, and expecting state to change to active
  - TimerButton test for tapping an active button, and expecting state change to inactive
  - Test view model state logic
    - Separate responsibilities with delegate
    - Use handler for alert to simulate alert response
 */

final class HourglassTests: XCTestCase {

    override func setUpWithError() throws {
    }

    override func tearDownWithError() throws {
    }

    func disabled_testTimerButtonSelect() {
        let publisher = PassthroughSubject<Hourglass.Timer.State, Never>()
        let wrappedPublisher = publisher.eraseToAnyPublisher()

        let timerButton = TimerButton(value: 5, state: .inactive, publisher: wrappedPublisher) {}
        publisher.send(.active)
        XCTAssertEqual(timerButton.state, .active)
        // TODO: - Test is failing, due to timerButton being a value type. Can't unit test views for reactivitiy to @state properties
        // TODO: - Could test sinking on the Timer.Model publisher for changed state, but this is implied by declaring a property @published
        // TODO: - UI tests can only verify if UIElement is hittable and exists. Not state of the instance or value.
        // TODO: - *Snapshot test is a better solution to create a state for the button and verify its appearance pixel for pixel.
        // TODO: - *Unit test view model to verify model state change when didTapButton message is received
    }

    func testTimerCountdown() {
        let publisher = PassthroughSubject<Date, Never>()
        let wrappedPublisher = publisher
            .makeConnectable()

        let timerManager = TimerManagerMock(timerPublisher: wrappedPublisher)
        let now = Date.now
        let timerID = UUID()

        XCTAssertFalse(timerManager.isTimerActive)

        timerManager.startTimer(length: 3, activeTimerModelId: timerID) {}
        XCTAssertTrue(timerManager.isTimerActive)
        XCTAssertEqual(timerManager.activeTimerModelId, timerID)
        XCTAssertEqual(timerManager.timeStamp, "0:3")

        publisher.send(now)
        XCTAssertEqual(timerManager.timeStamp, "0:2")

        publisher.send(now + 1)
        XCTAssertEqual(timerManager.timeStamp, "0:1")

        publisher.send(now + 2)
        XCTAssertEqual(timerManager.timeStamp, "0:0")
        XCTAssertFalse(timerManager.isTimerActive)
        XCTAssertNil(timerManager.activeTimerModelId)
    }

    func testTimerCountdownCancel() {
        let publisher = PassthroughSubject<Date, Never>()
        let wrappedPublisher = publisher
            .makeConnectable()

        let timerManager = TimerManagerMock(timerPublisher: wrappedPublisher)
        let now = Date.now
        let timerID = UUID()

        XCTAssertFalse(timerManager.isTimerActive)

        timerManager.startTimer(length: 3, activeTimerModelId: timerID) {}
        XCTAssertTrue(timerManager.isTimerActive)
        XCTAssertEqual(timerManager.activeTimerModelId, timerID)
        XCTAssertEqual(timerManager.timeStamp, "0:3")

        publisher.send(now)
        XCTAssertEqual(timerManager.timeStamp, "0:2")

        timerManager.stopTimer()
        XCTAssertFalse(timerManager.isTimerActive)
        XCTAssertNil(timerManager.activeTimerModelId)
        XCTAssertEqual(timerManager.timeStamp, "0:0")
    }
}
