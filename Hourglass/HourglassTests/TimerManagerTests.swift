import XCTest
@testable import Hourglass

final class TimerManagerTests: XCTestCase {

    let (timerPublisher, timerManager) = UnitTestProviders.fakeTimerManager
    let timerID = UUID()
    let now = Date.now

    override func setUpWithError() throws {
    }

    override func tearDownWithError() throws {
    }

    func testTimerCountdown() {
        assertTimerDefault()

        timerManager.startTimer(length: 3, activeTimerModelId: timerID)
        XCTAssertEqual(timerManager.timeStamp, "00:03")
        assertTimerInProgress()

        timerPublisher.send(now)
        XCTAssertEqual(timerManager.timeStamp, "00:02")
        assertTimerInProgress()

        timerPublisher.send(now + 1)
        XCTAssertEqual(timerManager.timeStamp, "00:01")
        assertTimerInProgress()

        timerPublisher.send(now + 2)
        XCTAssertEqual(timerManager.timeStamp, "00:00")
        assertTimerDefault()
    }

    func testTimerCountdownCancel() {
        assertTimerDefault()

        timerManager.startTimer(length: 3, activeTimerModelId: timerID)
        XCTAssertEqual(timerManager.timeStamp, "00:03")
        assertTimerInProgress()

        timerManager.cancelTimer()
        XCTAssertEqual(timerManager.timeStamp, "00:00")
        assertTimerDefault()
    }

    private func assertTimerInProgress() {
        XCTAssertTrue(timerManager.isTimerActive)
        XCTAssertEqual(timerManager.activeTimerModelId, timerID)
    }

    private func assertTimerDefault() {
        XCTAssertFalse(timerManager.isTimerActive)
        XCTAssertNil(timerManager.activeTimerModelId)
    }
}
