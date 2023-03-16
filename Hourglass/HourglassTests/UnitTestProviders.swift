import Combine
import Foundation
@testable import Hourglass

struct UnitTestProviders {
    static var fakeTimerManager: (PassthroughSubject<Date, Never>, TimerManager) {
        let stubTimerPublisher = PassthroughSubject<Date, Never>()
        let fakeTimerManager = TimerManagerFake(timerPublisher: stubTimerPublisher)
        return (stubTimerPublisher, fakeTimerManager)
    }

    private static var stubTimerModels: [Hourglass.Timer.Category : [Hourglass.Timer.Model]] {
        [.focus: [Timer.Model(length: 3, category: .focus, size: .small),
                  Timer.Model(length: 5, category: .focus, size: .medium)],
         .rest: [Timer.Model(length: 3, category: .rest, size: .small),
                 Timer.Model(length: 5, category: .rest, size: .medium)]]
    }

    static var mockUserNotificationManager: UserNotificationManagerMock {
        return UserNotificationManagerMock()
    }

    static var fakeViewModel: (PassthroughSubject<Date, Never>,
                               ViewModel,
                               UserNotificationManagerMock,
                               SettingsManager) {

        let stubTimerModels = stubTimerModels
        let (timerPublisher, fakeTimerManager) = fakeTimerManager
        let mockUserNotificationManager = mockUserNotificationManager
        let settingsManager = SettingsManager.shared

        let viewModel = ViewModel(timerModels: stubTimerModels,
                                  timerManager: fakeTimerManager,
                                  userNotificationManager: mockUserNotificationManager,
                                  settingsManager: settingsManager)
        return (timerPublisher,
                viewModel,
                mockUserNotificationManager,
                settingsManager)
    }
}
