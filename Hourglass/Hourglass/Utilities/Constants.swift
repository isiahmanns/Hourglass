import Foundation

enum Constants {
    // TODO: - Remove
    // Fullscreen-on-break default
    // static let fullscreenOnBreak = true

    // Timer length defaults
    static let timerLengths = [5, 10, 15, 20, 25, 30, 35, 40, 45]

    // UserDefaults Fallback Defaults
    /// Sound
    static let soundIsEnabled: Bool = true

    /// Rest Settings
    static let restWarningThreshold: SettingsThreshold.RawValue = SettingsThreshold.k1.rawValue
    static let enforceRestThreshold: SettingsThreshold.RawValue = SettingsThreshold.k2.rawValue
    static let getBackToWorkIsEnabled: Bool = false

    // Timer alert dialog
    static let timerCompleteAlert = "Time is up."
    static let restWarningAlert = "Take a rest, soon."
    static let enforceRestAlert = "You've been focused for a while, now.\nTake a rest."
    static let getBackToWorkAlert = "Get back to work!"

    // Timestamp default
    static let timeStampZero = "00:00"

    // Timer length multiplier
#if RELEASE
    static let countdownFactor = 60
#elseif DEBUG || CITESTING
    static let countdownFactor = 1
#endif
}
