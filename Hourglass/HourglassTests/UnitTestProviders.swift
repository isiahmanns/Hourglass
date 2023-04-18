import Combine
import Foundation
@testable import Hourglass

struct UnitTestProviders {
    typealias TimerPublisher = PassthroughSubject<Date, Never>

    static var fakeTimerManager: (TimerPublisher, TimerManager) {
        let stubTimerPublisher = TimerPublisher()
        let fakeTimerManager = TimerManagerFake(timerPublisher: stubTimerPublisher)
        return (stubTimerPublisher, fakeTimerManager)
    }

    private static var stubTimerModels: [Hourglass.Timer.Model] {
        [Timer.Model(length: 3, category: .focus, size: .small),
         Timer.Model(length: 5, category: .rest, size: .medium)]
    }

    static var fakeViewModel: (TimerPublisher,
                               ViewModel,
                               UserNotificationManagerMock,
                               SettingsManager) {

        let stubTimerModels = stubTimerModels
        let (stubTimerPublisher, fakeTimerManager) = fakeTimerManager
        let mockUserNotificationManager = UserNotificationManagerMock()
        let settingsManager = SettingsManager.shared
        let mockWindowCoordinator = WindowCoordinatorMock()

        let viewModel = ViewModel(timerModels: stubTimerModels,
                                  timerManager: fakeTimerManager,
                                  userNotificationManager: mockUserNotificationManager,
                                  settingsManager: settingsManager,
                                  windowCoordinator: mockWindowCoordinator)
        return (stubTimerPublisher,
                viewModel,
                mockUserNotificationManager,
                settingsManager)
    }
}
