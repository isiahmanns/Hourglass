import UserNotifications

enum HourglassNotification: String {
    case timerCompleteBanner
    case restWarningThresholdMetBanner
    case soundOnly

    var contentBase: UNMutableNotificationContent {
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = title
        notificationContent.interruptionLevel = .active
        return notificationContent
    }

    var title: String {
        switch self {
        case .timerCompleteBanner:
            return Constants.timerCompleteAlert
        case .restWarningThresholdMetBanner:
            return Constants.restWarningAlert
        case .soundOnly:
            return ""
        }
    }

    var id: String {
        rawValue
    }
}
