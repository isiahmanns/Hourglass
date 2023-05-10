import Foundation

enum Constants {
    // Notification style default
    static let notificationStyle = NotificationStyle.popup.rawValue

    // Fullscreen-on-break default
    static let fullscreenOnBreak = true

    // Sound default
    static let soundIsEnabled = true

    // Timer length defaults
    static let timerFocusSmall = 15
    static let timerFocusMedium = 25
    static let timerFocusLarge = 35
    static let timerRestSmall = 3
    static let timerRestMedium = 10
    static let timerRestLarge = 20

    // Timer threshold defaults
    // TODO: - Decide these values!
    static let restWarningThreshold: Int = 15
    static let enforceRestThreshold: Int = 0
    static let getBackToWorkIsEnabled: Bool = false

    // Timer alert dialog
    static let timerCompleteAlert = "Time's up."
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
