import Foundation
import Combine

class TimerManager {
    private var timerCancellable: AnyCancellable?

    func startTimer() {
        timerCancellable = Foundation.Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { date in
                print(date)
            }
    }

    func stopTimer() {
        timerCancellable = nil
    }
}

// TODO: - Implement counter logic for injected timer length
// TODO: - Publish when timer length is reached 
