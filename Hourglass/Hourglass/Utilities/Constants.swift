import Foundation

enum Constants {
    // Notification style default
    static let notificationStyle = NotificationStyle.popup.rawValue

    // Fullscreen-on-break default
    static let fullscreenOnBreak = true

    // Sound default
    static let soundIsEnabled = true

    // Timer length defaults
    static let timerFocusSmallDefault = 15
    static let timerFocusMediumDefault = 25
    static let timerFocusLargeDefault = 35
    static let timerRestSmallDefault = 3
    static let timerRestMediumDefault = 10
    static let timerRestLargeDefault = 20

    // Timer threshold defaults
    // TODO: - Decide these values!
    static let restWarningThresholdDefault: Int = 15
    static let enforceRestThresholdDefault: Int = 0

    // Timer alert dialog
    static let timerCompleteAlert = "Time's up"
    static let restWarningAlert = "Take a rest, soon."

    // Timestamp default
    static let timeStampZero = "00:00"

    // Timer length multiplier
#if RELEASE
    static let countdownFactor = 60
#elseif DEBUG || CITESTING
    static let countdownFactor = 1
#endif
}
