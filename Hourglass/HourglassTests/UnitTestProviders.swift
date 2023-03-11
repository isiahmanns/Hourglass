import Combine
import Foundation
@testable import Hourglass

struct UnitTestProviders {
    static var mockTimerManager: (PassthroughSubject<Date, Never>, TimerManager) {
        let timerPublisher = PassthroughSubject<Date, Never>()
        let timerManager = TimerManagerMock(timerPublisher: timerPublisher)
        return (timerPublisher, timerManager)
    }

    private static var mockTimerModels: [Hourglass.Timer.Category : [Hourglass.Timer.Model]] {
        [.focus: [Timer.Model(length: 3, category: .focus, size: .small),
                  Timer.Model(length: 5, category: .focus, size: .medium)],
         .rest: [Timer.Model(length: 3, category: .rest, size: .small),
                 Timer.Model(length: 5, category: .rest, size: .medium)]]
    }

    static var mockViewModel: (PassthroughSubject<Date, Never>, ViewModel) {
        let timerModels = mockTimerModels
        let (timerPublisher, timerManager) = mockTimerManager
        let viewModel = ViewModel(timerModels: timerModels, timerManager: timerManager)
        return (timerPublisher, viewModel)
    }
}
