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
    case restWarningThreshold
    case enforceRestThreshold
}

enum NotificationStyle: Int {
    case popup
    case banner
}
