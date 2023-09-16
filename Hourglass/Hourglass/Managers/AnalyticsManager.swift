protocol AnalyticsEngine {
    func logEvent(name: String, metadata: Metadata?)
}

enum AnalyticsEvent {
    case timerDidComplete(Timer.Model)
    case timerWasCancelled(Timer.Model)
    case restWarningThresholdSet(Int)
    case enforceRestThresholdSet(Int)
    case getBackToWorkSet(Bool)
    case statisticsViewOpened
    case timerCategoryToggled

    var name: String {
        switch self {
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
        case .statisticsViewOpened, .timerCategoryToggled:
            return String(describing: self)
        }
    }

    var metadata: Metadata? {
        switch self {
        case let .timerDidComplete(timerModel), let .timerWasCancelled(timerModel):
            return ["Category" : String(describing: Timer.Model.category),
                    "Length": timerModel.length]
        case let .restWarningThresholdSet(restWarningThreshold):
            return ["Rest Warning Threshold": restWarningThreshold]
        case let .enforceRestThresholdSet(enforceRestThreshold):
            return ["Enforce Rest Threshold": enforceRestThreshold]
        case let .getBackToWorkSet(getBackToWork):
            return ["Get Back to Work": getBackToWork]
        case .statisticsViewOpened:
            return nil
        case .timerCategoryToggled:
            return ["Timer Category": String(describing: Timer.Model.category)]
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

