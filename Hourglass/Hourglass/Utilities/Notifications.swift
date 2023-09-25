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
            return Copy.timerCompleteAlert
        case .restWarningThresholdMet:
            return Copy.restWarningAlert
        case .enforceRestThresholdMet:
            return Copy.enforceRestAlert
        case .getBackToWork:
            return Copy.getBackToWorkAlert
        }
    }

    var id: String {
        rawValue
    }
}

extension HourglassNotification {
    enum Copy {
        static let timerCompleteAlert = "Time is up."
        static let restWarningAlert = "Take a rest, soon."
        static let enforceRestAlert = "You've been focused for a while, now.\nTake a rest."
        static let getBackToWorkAlert = "Get back to work!"
    }
}
