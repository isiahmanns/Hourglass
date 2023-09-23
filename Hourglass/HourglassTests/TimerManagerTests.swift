import Combine
import XCTest
@testable import Hourglass

final class TimerManagerTests: XCTestCase {

    let (timerPublisher, timerManager) = UnitTestProviders.fakeTimerManager
    let timerID = TimerButton.PresenterModel(length: 5).id
    let now = Date.now
    var cancellables: Set<AnyCancellable> = []
    var eventTriggerCount = (timerDidStart: 0,
                             timerDidTick: 0,
                             timerDidComplete: 0,
                             timerWasCancelled: 0)

    override func setUpWithError() throws {
        timerManager.events[.timerDidStart]?
            .sink { [weak self] timerModelID, _ in
                guard let self else { return }
                XCTAssertEqual(timerID, timerModelID)
                eventTriggerCount.timerDidStart += 1
            }
            .store(in: &cancellables)

        timerManager.events[.timerDidTick]?
            .sink { [weak self] timerModelID, _ in
                guard let self else { return }
                XCTAssertEqual(timerID, timerModelID)
                eventTriggerCount.timerDidTick += 1
            }
            .store(in: &cancellables)

        timerManager.events[.timerDidComplete]?
            .sink { [weak self] timerModelID, _ in
                guard let self else { return }
                XCTAssertEqual(timerID, timerModelID)
                eventTriggerCount.timerDidComplete += 1
            }
            .store(in: &cancellables)

        timerManager.events[.timerWasCancelled]?
            .sink { [weak self] timerModelID, _ in
                guard let self else { return }
                XCTAssertEqual(timerID, timerModelID)
                eventTriggerCount.timerWasCancelled += 1
            }
            .store(in: &cancellables)
    }

    override func tearDownWithError() throws {
    }

    func testTimerCountdown() {
        assertTimerIdle()

        timerManager.startTimer(length: 3, activeTimerModelId: timerID)
        XCTAssertEqual(timerManager.timeStamp, "00:03")
        XCTAssertEqual(eventTriggerCount.timerDidStart, 1)
        assertTimerInProgress()

        timerPublisher.send(now)
        XCTAssertEqual(timerManager.timeStamp, "00:02")
        XCTAssertEqual(eventTriggerCount.timerDidTick, 1)
        assertTimerInProgress()

        timerPublisher.send(now + 1)
        XCTAssertEqual(timerManager.timeStamp, "00:01")
        XCTAssertEqual(eventTriggerCount.timerDidTick, 2)
        assertTimerInProgress()

        timerPublisher.send(now + 2)
        XCTAssertEqual(timerManager.timeStamp, "00:00")
        XCTAssertEqual(eventTriggerCount.timerDidTick, 3)
        XCTAssertEqual(eventTriggerCount.timerDidComplete, 1)
        assertTimerIdle()

        XCTAssertEqual(eventTriggerCount.timerWasCancelled, 0)
    }

    func testTimerCountdownCancel() {
        assertTimerIdle()

        timerManager.startTimer(length: 3, activeTimerModelId: timerID)
        XCTAssertEqual(timerManager.timeStamp, "00:03")
        XCTAssertEqual(eventTriggerCount.timerDidStart, 1)
        assertTimerInProgress()

        try! timerManager.cancelTimer()
        XCTAssertEqual(timerManager.timeStamp, "00:00")
        XCTAssertEqual(eventTriggerCount.timerWasCancelled, 1)
        assertTimerIdle()

        XCTAssertEqual(eventTriggerCount.timerDidTick, 0)
        XCTAssertEqual(eventTriggerCount.timerDidComplete, 0)
    }

    private func assertTimerInProgress() {
        XCTAssertFalse(timerManager.timerCancellables.isEmpty)
        XCTAssertEqual(timerManager.activeTimerModelId, timerID)
    }

    private func assertTimerIdle() {
        XCTAssertTrue(timerManager.timerCancellables.isEmpty)
        XCTAssertNil(timerManager.activeTimerModelId)
    }
}
