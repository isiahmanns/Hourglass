import UserNotifications

enum HourglassNotification: String {
    case timerCompleteBanner
    case timerCompleteNoBanner

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
        case .timerCompleteNoBanner:
            return ""
        }
    }

    var id: String {
        rawValue
    }
}
