import Foundation
import Combine

class TimerManager: ObservableObject {
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
    @Published private(set) var timeStamp: String = Constants.timeStampZero
    private(set) var activeTimerModelId: Timer.Model.ID?

    typealias Event<G> = PassthroughSubject<G, Never>
    let events: [HourglassEvent.Timer: Event<Timer.Model.ID>] = [
        .timerDidStart: .init(),
        .timerDidTick: .init(),
        .timerDidComplete: .init(),
        .timerWasCancelled: .init()
    ]

    fileprivate init(timerPublisher: some ConnectablePublisher<Date, Never>) {
        self.timerPublisher = timerPublisher
    }
    
    func startTimer(length: Int, activeTimerModelId: Timer.Model.ID) {
        self.count = length * Constants.countdownFactor
        self.activeTimerModelId = activeTimerModelId
        events[.timerDidStart]?.send(activeTimerModelId)

        timerPublisher
            .sink { [weak self] _ in
                guard let self else { return }
                self.count -= 1
                events[.timerDidTick]?.send(activeTimerModelId)

                if self.count == 0 {
                    events[.timerDidComplete]?.send(activeTimerModelId)
                    self.stopTimer()
                }
            }
            .store(in: &timerCancellables)

        timerPublisher
            .connect()
            .store(in: &timerCancellables)
    }

    func cancelTimer() {
        guard let activeTimerModelId else { fatalError() }
        stopTimer()
        events[.timerWasCancelled]?.send(activeTimerModelId)
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
