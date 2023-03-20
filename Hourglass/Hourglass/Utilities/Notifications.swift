import UserNotifications

enum HourglassNotification: String {
    // TODO: - Centralize string constants in separate file
    case timerCompleteBanner = "Time's up"
    case noBanner = ""

    var contentBase: UNMutableNotificationContent {
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = self.rawValue
        notificationContent.interruptionLevel = .active
        return notificationContent
    }
}
