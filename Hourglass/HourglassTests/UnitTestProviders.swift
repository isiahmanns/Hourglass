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

    static var fakeViewModel: (ViewModelMock,
                               CoreDataStore,
                               DataManaging,
                               TimerModelStateManagerFake,
                               TimerPublisher,
                               TimerManagerFake,
                               SettingsManager) {

        let (stubTimerPublisher, fakeTimerManager) = fakeTimerManager
        let inMemoryStore = CoreDataTestStore()
        let mockDataManager = DataManagerMock(timerLengths: [3, 5],
                                              store: inMemoryStore,
                                              timerEventProvider: fakeTimerManager)
        let userNotificationManager = UserNotificationManager.shared
        let settingsManager = SettingsManager.shared
        let analyticsManager = AnalyticsManager.shared

        let viewModel = ViewModelMock(analyticsManager: analyticsManager,
                                      dataManager: mockDataManager,
                                      settingsManager: settingsManager,
                                      timerManager: fakeTimerManager,
                                      userNotificationManager: userNotificationManager)

        let fakeTimerModelStateManager =
        TimerModelStateManagerFake(analyticsManager: analyticsManager,
                                   dataManager: mockDataManager,
                                   settingsManager: settingsManager,
                                   timerEventProvider: fakeTimerManager)
        fakeTimerModelStateManager.delegate = viewModel

        return (viewModel,
                inMemoryStore,
                mockDataManager,
                fakeTimerModelStateManager,
                stubTimerPublisher,
                fakeTimerManager,
                settingsManager)
    }
}
