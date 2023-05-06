import Combine
import Foundation
@testable import Hourglass

struct UnitTestProviders {
    typealias TimerPublisher = PassthroughSubject<Date, Never>

    static var fakeTimerManager: (TimerPublisher, TimerManagerFake) {
        let stubTimerPublisher = TimerPublisher()
        let fakeTimerManager = TimerManagerFake(timerPublisher: stubTimerPublisher)
        return (stubTimerPublisher, fakeTimerManager)
    }

    private static var mockDataManager: DataManaging {
        let stubTimerModels = [Timer.Model(length: 3, category: .focus, size: .small),
                               Timer.Model(length: 5, category: .rest, size: .medium)]
        return DataManagerMock(timerModels: stubTimerModels)
    }

    static var fakeViewModel: (ViewModelMock,
                               TimerModelStateManagerFake,
                               TimerPublisher,
                               TimerManagerFake,
                               SettingsManager) {

        let mockDataManager = mockDataManager
        let (stubTimerPublisher, fakeTimerManager) = fakeTimerManager
        let userNotificationManager = UserNotificationManager.shared
        let settingsManager = SettingsManager.shared

        let viewModel = ViewModelMock(dataManager: mockDataManager,
                                      settingsManager: settingsManager,
                                      timerManager: fakeTimerManager,
                                      userNotificationManager: userNotificationManager)

        let fakeTimerModelStateManager =
        TimerModelStateManagerFake(dataManager: mockDataManager,
                                   settingsManager: settingsManager,
                                   timerEventProvider: fakeTimerManager)
        fakeTimerModelStateManager.delegate = viewModel

        return (viewModel,
                fakeTimerModelStateManager,
                stubTimerPublisher,
                fakeTimerManager,
                settingsManager)
    }
}
