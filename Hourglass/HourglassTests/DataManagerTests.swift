import XCTest
@testable import Hourglass

final class DataManagerTests: XCTestCase {

    let (viewModel,
         dataManager,
         _,
         timerPublisher,
         settingsManager) = UnitTestProviders.fakeViewModel
    let now = Date.now

    lazy var timerModels: [Int: TimerButton.PresenterModel] = {
        Dictionary(uniqueKeysWithValues: viewModel.timerModels.values.map {($0.length, $0)})
    }()

    var timerModel3s: TimerButton.PresenterModel { timerModels[3]! }
    var timerModel5s: TimerButton.PresenterModel { timerModels[5]! }

    func testPersistCompletedTimers() {
        viewModel.timerCategoryTogglePresenterModel.state = .focus
        settingsManager.setRestWarningThreshold(.off)
        settingsManager.setEnforceRestThreshold(.k2)

        viewModel.didTapTimer(from: timerModel3s)
        runTimer(for: 3)

        (0..<2).forEach { _ in
            viewModel.didTapTimer(from: timerModel5s)
            runTimer(for: 5)
        }

        let timeBlocks = try! dataManager.fetchTimeBlocks()
        XCTAssertEqual(timeBlocks.count, 3)

        let timerCountByCategory = timeBlocks.reduce(into: [TimerCategory: Int]()) { partialResult, value in
            partialResult[TimerCategory(rawValue: Int(value.category)), default: 0] += 1
        }
        XCTAssertEqual(timerCountByCategory[.focus], 2)
        XCTAssertEqual(timerCountByCategory[.rest], 1)
    }

    private func runTimer(for length: Int) {
        (0..<length).forEach { _ in
            timerPublisher.send(now)
        }
    }
}
