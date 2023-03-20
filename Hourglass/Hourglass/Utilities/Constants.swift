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

    // Window Ids
    static let aboutWindowId = UUID().uuidString
}
