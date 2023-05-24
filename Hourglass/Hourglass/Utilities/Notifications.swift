import UserNotifications

/// A notification content provider for use with `UNNotificationRequest`.
enum HourglassNotification: String {
    case timerCompleteBanner
    case restWarningThresholdMetBanner

    var content: UNMutableNotificationContent {
        let notificationContent = UNMutableNotificationContent()
        notificationContent.interruptionLevel = .active
        return notificationContent
    }

    var soundFX: UNNotificationSound? {
        switch self {
        case .restWarningThresholdMetBanner:
            return nil
        default:
            return UNNotificationSound.default
        }
    }

    var title: String {
        switch self {
        case .timerCompleteBanner:
            return Constants.timerCompleteAlert
        case .restWarningThresholdMetBanner:
            return Constants.restWarningAlert
        }
    }

    var id: String {
        rawValue
    }
}
