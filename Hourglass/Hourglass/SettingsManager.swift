import Foundation

struct SettingsManager {
    static let shared = SettingsManager()
    let store: UserDefaults

    private init(store: UserDefaults = .standard) {
        self.store = store
    }

    // Timer
    func setTimer(length: Int, for key: SettingsKeys.TimerSetting) {
        store.set(length, forKey: key.rawValue)
    }

    func getTimerLength(for timerSetting: SettingsKeys.TimerSetting) -> Int? {
        let value = store.object(forKey: timerSetting.rawValue)

        if let intValue = value as? Int {
            return intValue
        }

        // Note: This supports launch args in UI Testing
        if let stringValue = value as? String {
            return Int(stringValue)
        }

        return nil
    }

    // Sound
    func setSound(isEnabled: Bool) {
        store.set(isEnabled, forKey: SettingsKeys.soundEnabled.rawValue)
    }

    func getSoundIsEnabled() -> Bool {
        store.bool(forKey: SettingsKeys.soundEnabled.rawValue)
    }

    // Fullscreen Break
    func setFullScreenOnBreak(isEnabled: Bool) {
        store.set(isEnabled, forKey: SettingsKeys.fullScreenOnBreak.rawValue)
    }

    func getFullScreenOnBreakIsEnabled() -> Bool {
        store.bool(forKey: SettingsKeys.fullScreenOnBreak.rawValue)
    }

    // Notification Style
    func setNotification(style: NotificationStyle) {
        store.set(style.rawValue, forKey: SettingsKeys.notificationStyle.rawValue)
    }

    func getNotificationStyle() -> NotificationStyle {
        let value = store.integer(forKey: SettingsKeys.notificationStyle.rawValue)
        return NotificationStyle(rawValue: value)!
    }
}

enum SettingsKeys: String {
    enum TimerSetting: String {
        case timerFocusSmall
        case timerFocusMedium
        case timerFocusLarge
        case timerRestSmall
        case timerRestMedium
        case timerRestLarge
    }
    case soundEnabled
    case fullScreenOnBreak
    case notificationStyle
}

enum NotificationStyle: Int {
    case popup
    case banner
}
