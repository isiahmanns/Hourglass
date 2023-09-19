protocol AnalyticsEngine {
    func logEvent(name: String, metadata: Metadata?)
}

enum AnalyticsEvent {
    case timerCategoryToggled(TimerCategory)
    case timerDidComplete(TimerButton.PresenterModel, TimerCategory)
    case timerWasCancelled(TimerButton.PresenterModel, TimerCategory)
    case restWarningThresholdSet(Int)
    case enforceRestThresholdSet(Int)
    case getBackToWorkSet(Bool)
    case statisticsViewOpened

    var name: String {
        switch self {
        case .timerCategoryToggled:
            return "timerCategoryToggled"
        case .timerDidComplete:
            return "timerDidComplete"
        case .timerWasCancelled:
            return "timerWasCancelled"
        case .restWarningThresholdSet:
            return "restWarningThresholdSet"
        case .enforceRestThresholdSet:
            return "enforceRestThresholdSet"
        case .getBackToWorkSet:
            return "getBackToWorkSet"
        case .statisticsViewOpened:
            return String(describing: self)
        }
    }

    var metadata: Metadata? {
        switch self {
        case let .timerCategoryToggled(timerCategory):
            return ["Category": String(describing: timerCategory)]
        case let .timerDidComplete(timerModel, timerCategory),
             let .timerWasCancelled(timerModel, timerCategory):
            return ["Category" : String(describing: timerCategory),
                    "Length": timerModel.length]
        case let .restWarningThresholdSet(restWarningThreshold):
            return ["Rest Warning Threshold": restWarningThreshold]
        case let .enforceRestThresholdSet(enforceRestThreshold):
            return ["Enforce Rest Threshold": enforceRestThreshold]
        case let .getBackToWorkSet(getBackToWork):
            return ["Get Back to Work": getBackToWork]
        case .statisticsViewOpened:
            return nil
        }
    }
}

struct AnalyticsManager {
    #if CITESTING
    static let shared = AnalyticsManager(analyticsEngine: StdoutEngine.shared)
    #else
    static let shared = AnalyticsManager(analyticsEngine: MixpanelEngine.shared)
    #endif

    private let analyticsEngine: AnalyticsEngine

    func logEvent(_ event: AnalyticsEvent) {
        analyticsEngine.logEvent(name: event.name, metadata: event.metadata)
    }
}

