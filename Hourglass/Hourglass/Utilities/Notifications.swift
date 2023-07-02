import UserNotifications

/// A notification content provider for use with `UNNotificationRequest`.
enum HourglassNotification: String {
    case timerCompleteNotif
    case restWarningThresholdMetNotif

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
        case .timerCompleteNotif:
            return Constants.timerCompleteAlert
        case .restWarningThresholdMetNotif:
            return Constants.restWarningAlert
        }
    }

    var id: String {
        rawValue
    }
}
