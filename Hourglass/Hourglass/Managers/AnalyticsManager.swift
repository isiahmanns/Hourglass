protocol AnalyticsEngine {
    func logEvent(name: String, metadata: [String: Any])
}

enum AnalyticsEvent {
    case timerDidComplete(Timer.Model)
    case timerWasCancelled(Timer.Model)
    case restSettingsElected(restWarningThreshold: Int, enforceRestThreshold: Int, getBackToWork: Bool)
    case timerPresetElected(Timer.Model, newLength: Int)
    case notificationStyleElected(NotificationStyle)
    case statisticsViewOpened

    var name: String {
        switch self {
        case .timerDidComplete:
            return "timerDidComplete"
        case .timerWasCancelled:
            return "timerWasCancelled"
        case .restSettingsElected:
            return "restSettingsElected"
        case .timerPresetElected:
            return "restSettingsElected"
        case .notificationStyleElected:
            return "notificationStyleElected"
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
        case let .restSettingsElected(restWarningThreshold: restWarningThreshold,
                                      enforceRestThreshold: enforceRestThreshold,
                                      getBackToWork: getBackToWork):
            return ["Rest Warning Threshold": restWarningThreshold,
                    "Enforce Rest Threshold": enforceRestThreshold,
                    "Get Back to Work": getBackToWork]
        case let .timerPresetElected(timerModel, newLength: newLength):
            return ["Category" : String(describing: timerModel.category),
                    "Size": String(describing: timerModel.size),
                    "Prev Length": timerModel.length,
                    "New Length": newLength]
        case let .notificationStyleElected(notificationStyle):
            return ["Notification Style": String(describing: notificationStyle)]
        case .statisticsViewOpened:
            return [:]
        }
    }
}

struct AnalyticsManager {
    private let analyticsEngine: AnalyticsEngine

    func logEvent(_ event: AnalyticsEvent) {
        analyticsEngine.logEvent(name: event.name, metadata: event.metadata)
    }
}

