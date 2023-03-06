import Foundation
import Combine

class TimerManager {
    static let shared: TimerManager = {
        let publisher = Foundation.Timer.publish(every: 1, on: .main, in: .common)
            .eraseToAnyPublisher()
            .makeConnectable()
        return TimerManager(timerPublisher: publisher)
        // TODO: - Investigate why this is breaking the time countdown behavior
    }()

    private let timerPublisher: Publishers.MakeConnectable<AnyPublisher<Date, Never>>
    private var timerCancellable: AnyCancellable?
    private var count: Int = 0 {
        didSet {
            let (minutes, seconds) = count.asSeconds.toMinutesSeconds
            timeStamp = "\(minutes):\(seconds)"
            // TODO: - format string to display 2-digit integers
        }
    }
    @Published var timeStamp: String = "00:00"
    var activeTimerModelId: Timer.Model.ID?
    var isTimerActive: Bool {
        timerCancellable != nil
    }

    fileprivate init(timerPublisher: Publishers.MakeConnectable<AnyPublisher<Date, Never>>) {
        self.timerPublisher = timerPublisher
    }
    
    func startTimer(length: Int, activeTimerModelId: Timer.Model.ID, action: @escaping () -> Void) {
        self.count = length // * 60
        self.activeTimerModelId = activeTimerModelId

        timerCancellable = timerPublisher
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
        count = 0
    }
}

class TimerManagerMock: TimerManager {
    override init(timerPublisher: Publishers.MakeConnectable<AnyPublisher<Date, Never>>) {
        super.init(timerPublisher: timerPublisher)
    }
}
