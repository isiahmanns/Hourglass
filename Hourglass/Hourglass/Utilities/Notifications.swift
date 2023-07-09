import UserNotifications

/// A notification content provider for use with `UNNotificationRequest`.
enum HourglassNotification: String {
    case timerCompleted
    case restWarningThresholdMet
    case enforceRestThresholdMet
    case getBackToWork

    var content: UNMutableNotificationContent {
        let notificationContent = UNMutableNotificationContent()
        notificationContent.interruptionLevel = .active
        return notificationContent
    }

    var soundFX: UNNotificationSound? {
        return UNNotificationSound.default
    }

    var title: String {
        switch self {
        case .timerCompleted:
            return Constants.timerCompleteAlert
        case .restWarningThresholdMet:
            return Constants.restWarningAlert
        case .enforceRestThresholdMet:
            return Constants.enforceRestAlert
        case .getBackToWork:
            return Constants.getBackToWorkAlert
        }
    }

    var id: String {
        rawValue
    }
}
