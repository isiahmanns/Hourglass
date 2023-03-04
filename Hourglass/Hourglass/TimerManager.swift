import Foundation
import Combine

class TimerManager {
    static let shared = TimerManager()
    private var timerCancellable: AnyCancellable?
    private var count: Int = 0
    var activeTimerModelId: Timer.Model.ID?
    var isTimerActive: Bool {
        activeTimerModelId != nil
    }

    // TODO: - Inject publisher depencency. Abstract TimerManager to a protocol, and create a separate mock.
    private init() {}
    
    func startTimer(length: Int, activeTimerModelId: Timer.Model.ID, action: @escaping () -> Void) {
        self.count = length // * 60
        self.activeTimerModelId = activeTimerModelId

        timerCancellable = Foundation.Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                self.count -= 1

                // TODO: - emit change to timerView

                if self.count == 0 {
                    action()
                    self.stopTimer()
                }
            }
    }

    func stopTimer() {
        timerCancellable = nil
        activeTimerModelId = nil
    }
}
