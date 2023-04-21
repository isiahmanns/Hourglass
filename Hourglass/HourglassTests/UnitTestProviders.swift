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

    private static var mockDataManager: DataManaging {
        let stubTimerModels = [Timer.Model(length: 3, category: .focus, size: .small),
                               Timer.Model(length: 5, category: .rest, size: .medium)]
        return DataManagerMock(timerModels: stubTimerModels)
    }

    static var fakeViewModel: (ViewModel,
                               TimerModelStateManager,
                               TimerPublisher,
                               UserNotificationManagerMock,
                               SettingsManager) {

        let mockDataManager = mockDataManager
        let (stubTimerPublisher, fakeTimerManager) = fakeTimerManager
        let mockUserNotificationManager = UserNotificationManagerMock()
        let settingsManager = SettingsManager.shared

        let viewModel = ViewModel(dataManager: mockDataManager,
                                  settingsManager: settingsManager,
                                  timerManager: fakeTimerManager,
                                  userNotificationManager: mockUserNotificationManager)

        let fakeTimerModelStateManager =
        TimerModelStateManagerFake(dataManager: mockDataManager,
                                   settingsManager: settingsManager,
                                   timerEventProvider: fakeTimerManager)
        fakeTimerModelStateManager.delegate = viewModel

        return (viewModel,
                fakeTimerModelStateManager,
                stubTimerPublisher,
                mockUserNotificationManager,
                settingsManager)
    }
}
