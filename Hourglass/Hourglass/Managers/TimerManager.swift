import Foundation
import Combine

enum TimerManagerError: Error {
    case attemptToCancelInactiveTimer
}

typealias TimerEvent = PassthroughSubject<(TimerButton.PresenterModel.ID, TimerCategory), Never>

protocol TimerEventProviding {
    var events: [HourglassEventKey.Timer: TimerEvent] { get }
}

class TimerManager: ObservableObject, TimerEventProviding {
    static let shared: TimerManager = {
        let publisher = Foundation.Timer.publish(every: 1, on: .main, in: .common)
        return TimerManager(timerPublisher: publisher)
    }()

    private let timerPublisher: any ConnectablePublisher<Date, Never>
    private(set) var timerCancellables: Set<AnyCancellable> = []
    private var count: Int = 0 {
        didSet {
            let (minutes, seconds) = count.asSeconds.toMinutesSeconds
            timeStamp = String(format: "%02d:%02d", minutes, seconds)
        }
    }
    @Published private(set) var timeStamp: String = "00:00"
    private(set) var activeTimerModelId: TimerButton.PresenterModel.ID?

    let events: [HourglassEventKey.Timer: TimerEvent] = [
        .timerDidStart: .init(),
        .timerDidTick: .init(),
        .timerDidComplete: .init(),
        .timerWasCancelled: .init()
    ]

    fileprivate init(timerPublisher: some ConnectablePublisher<Date, Never>) {
        self.timerPublisher = timerPublisher
    }
    
    func startTimer(length: Int, activeTimerModelId: TimerButton.PresenterModel.ID) {
        self.count = length * Constants.countdownFactor
        self.activeTimerModelId = activeTimerModelId
        events[.timerDidStart]?.send((activeTimerModelId, TimerCategory.current))

        timerPublisher
            .sink { [weak self] _ in
                guard let self else { return }
                self.count -= 1
                events[.timerDidTick]?.send((activeTimerModelId, TimerCategory.current))

                if self.count == 0 {
                    events[.timerDidComplete]?.send((activeTimerModelId, TimerCategory.current))
                    self.stopTimer()
                }
            }
            .store(in: &timerCancellables)

        timerPublisher
            .connect()
            .store(in: &timerCancellables)
    }

    func cancelTimer() throws {
        guard let activeTimerModelId
        else { throw TimerManagerError.attemptToCancelInactiveTimer }

        stopTimer()
        events[.timerWasCancelled]?.send((activeTimerModelId, TimerCategory.current))
    }

    private func stopTimer() {
        timerCancellables.removeAll()
        activeTimerModelId = nil
        count = 0
    }
}

class TimerManagerFake: TimerManager {
    init(timerPublisher: some Subject<Date, Never>) {
        let connectableTimerPublisher = timerPublisher.makeConnectable()
        super.init(timerPublisher: connectableTimerPublisher)
    }
}
