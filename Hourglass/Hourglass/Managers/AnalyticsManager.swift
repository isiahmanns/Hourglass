protocol AnalyticsEngineType {
    func logEvent(name: String, metadata: [String: Any])
}

enum AnalyticsEngine: AnalyticsEngineType {
    case mixpanel
    case stdout

    func logEvent(name: String, metadata: [String : Any]) {
        switch self {
        case .mixpanel:
            MixpanelEngine.shared.logEvent(name: name, metadata: metadata)
        case .stdout:
            StdoutEngine.shared.logEvent(name: name, metadata: metadata)
        }
    }
}

enum AnalyticsEvent {
    case timerDidComplete(Timer.Model) // TMSM observer or TimerManager (inject DataManaging for TimerModels)
    case timerWasCancelled(Timer.Model) // TMSM observer or TimerManager (inject DataManaging for TimerModels)
    case restWarningThresholdSet(Int) // TMSM observer
    case enforceRestThresholdSet(Int) // TMSM observer
    case getBackToWorkSet(Bool) // TMSM observer
    case timerPresetSet(Timer.Model) // *TMSM observer* or menu
    case notificationStyleSet(NotificationStyle)
    case statisticsViewOpened

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
        case .timerPresetSet:
            return "timerPresetSet"
        case .notificationStyleSet:
            return "notificationStyleSet"
        case .statisticsViewOpened:
            return String(describing: self)
        }
    }

    var metadata: [String: Any] {
        switch self {
        case let .timerDidComplete(timerModel), let .timerWasCancelled(timerModel):
            return ["Category" : String(describing: timerModel.category),
                    "Size": String(describing: timerModel.size),
                    "Length": timerModel.length]
        case let .restWarningThresholdSet(restWarningThreshold):
            return ["Rest Warning Threshold": restWarningThreshold]
        case let .enforceRestThresholdSet(enforceRestThreshold):
            return ["Enforce Rest Threshold": enforceRestThreshold]
        case let .getBackToWorkSet(getBackToWork):
            return ["Get Back to Work": getBackToWork]
        case let .timerPresetSet(timerModel):
            return ["Category" : String(describing: timerModel.category),
                    "Size": String(describing: timerModel.size),
                    "New Length": timerModel.length]
        case let .notificationStyleSet(notificationStyle):
            return ["Notification Style": String(describing: notificationStyle)]
        case .statisticsViewOpened:
            return [:]
        }
    }
}

struct AnalyticsManager {
    enum shared {
        static let mixpanel = AnalyticsManager(analyticsEngine: .mixpanel)
        static let stdout = AnalyticsManager(analyticsEngine: .stdout)
    }

    private let analyticsEngine: AnalyticsEngine

    private init(analyticsEngine: AnalyticsEngine) {
        self.analyticsEngine = analyticsEngine
    }

    func logEvent(_ event: AnalyticsEvent) {
        analyticsEngine.logEvent(name: event.name, metadata: event.metadata)
    }
}

