import Foundation
import Combine

class TimerManager {
    static let shared: TimerManager = {
        let publisher = Foundation.Timer.publish(every: 1, on: .main, in: .common)
        return TimerManager(timerPublisher: publisher)
    }()

    private let timerPublisher: any ConnectablePublisher<Date, Never>
    private var timerCancellables: Set<AnyCancellable> = []
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
        !timerCancellables.isEmpty
    }

    fileprivate init(timerPublisher: some ConnectablePublisher<Date, Never>) {
        self.timerPublisher = timerPublisher
    }
    
    func startTimer(length: Int, activeTimerModelId: Timer.Model.ID, action: @escaping () -> Void) {
        self.count = length // * 60
        self.activeTimerModelId = activeTimerModelId

        timerPublisher
            .sink { [weak self] _ in
                guard let self else { return }
                self.count -= 1

                if self.count == 0 {
                    action()
                    self.stopTimer()
                }
            }
            .store(in: &timerCancellables)

        timerPublisher
            .connect()
            .store(in: &timerCancellables)
    }

    func stopTimer() {
        timerCancellables.removeAll()
        activeTimerModelId = nil
        count = 0
    }
}

class TimerManagerMock: TimerManager {
    init(timerPublisher: some Subject<Date, Never>) {
        let connectableTimerPublisher = timerPublisher.makeConnectable()
        super.init(timerPublisher: connectableTimerPublisher)
    }
}
