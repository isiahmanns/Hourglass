enum SettingsKeys: String {
    enum TimerSetting: String {
        case timerFocusSmall
        case timerFocusMedium
        case timerFocusLarge
        case timerRestSmall
        case timerRestMedium
        case timerRestLarge
    }
    case soundIsEnabled
    case fullScreenOnBreak
    case notificationStyle
}

enum NotificationStyle: Int {
    case popup
    case banner
}
