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

    private static var stubTimerModels: [Hourglass.Timer.Model] {
        [Timer.Model(length: 3, category: .focus, size: .small),
         Timer.Model(length: 5, category: .rest, size: .medium)]
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
        let mockDataManager = DataManagerMock(timerModels: stubTimerModels,
                                              store: inMemoryStore,
                                              timerEventProvider: fakeTimerManager)
        let userNotificationManager = UserNotificationManager.shared
        let settingsManager = SettingsManager.shared
        let analyticsManager = AnalyticsManager.shared.stdout

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
