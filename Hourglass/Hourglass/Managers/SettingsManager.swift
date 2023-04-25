import Foundation

struct SettingsManager {
    static let shared = SettingsManager(store: UserDefaults.standard)
    let store: UserDefaults

    private init(store: UserDefaults) {
        self.store = store
    }

    // Timer
    func setTimer(length: Int, for key: SettingsKeys.TimerSetting) {
        store.set(length, forKey: key.rawValue)
    }

    func getTimerLength(for timerSetting: SettingsKeys.TimerSetting) -> Int {
        let value = store.object(forKey: timerSetting.rawValue)

        if let intValue = value as? Int {
            return intValue
        }

        // Note: This supports launch args in UI Testing
        if let stringValue = value as? String {
            return Int(stringValue)!
        }

        switch timerSetting {
        case .timerFocusSmall:
            return Constants.timerFocusSmallDefault
        case .timerFocusMedium:
            return Constants.timerFocusMediumDefault
        case .timerFocusLarge:
            return Constants.timerFocusLargeDefault
        case .timerRestSmall:
            return Constants.timerRestSmallDefault
        case .timerRestMedium:
            return Constants.timerRestMediumDefault
        case .timerRestLarge:
            return Constants.timerRestLargeDefault
        }
    }

    // Rest Warning Threshold
    func setRestWarningThreshold(_ value: Int) {
        store.set(value, forKey: SettingsKeys.restWarningThreshold.rawValue)
    }

    func getRestWarningThreshold() -> Int {
        let value = store.object(forKey: SettingsKeys.restWarningThreshold.rawValue)
        return value as? Int ?? Constants.restWarningThresholdDefault
    }

    // Enforce Rest Threshold
    func setEnforceRestThreshold(_ value: Int) {
        store.set(value, forKey: SettingsKeys.enforceRestThreshold.rawValue)
    }

    func getEnforceRestThreshold() -> Int {
        let value = store.object(forKey: SettingsKeys.enforceRestThreshold.rawValue)
        return value as? Int ?? Constants.enforceRestThresholdDefault
    }

    // Get Back to Work
    func setGetBackToWork(isEnabled: Bool) {
        store.set(isEnabled, forKey: SettingsKeys.getBackToWork.rawValue)
    }

    func getGetBackToWorkIsEnabled() -> Bool {
        let value = store.object(forKey: SettingsKeys.getBackToWork.rawValue)
        return value as? Bool ?? Constants.getBackToWorkIsEnabled
    }

    // Sound
    func setSound(isEnabled: Bool) {
        store.set(isEnabled, forKey: SettingsKeys.soundIsEnabled.rawValue)
    }

    func getSoundIsEnabled() -> Bool {
        let value = store.object(forKey: SettingsKeys.soundIsEnabled.rawValue)
        return value as? Bool ?? Constants.soundIsEnabled
    }

    // Fullscreen Break
    func setFullScreenOnBreak(isEnabled: Bool) {
        store.set(isEnabled, forKey: SettingsKeys.fullScreenOnBreak.rawValue)
    }

    func getFullScreenOnBreakIsEnabled() -> Bool {
        let value = store.object(forKey: SettingsKeys.fullScreenOnBreak.rawValue)
        return value as? Bool ?? Constants.fullscreenOnBreak
    }

    // Notification Style
    func setNotification(style: NotificationStyle) {
        store.set(style.rawValue, forKey: SettingsKeys.notificationStyle.rawValue)
    }

    func getNotificationStyle() -> NotificationStyle {
        let value = store.object(forKey: SettingsKeys.notificationStyle.rawValue)

        if let intValue = value as? Int {
            return NotificationStyle(rawValue: intValue)!
        }

        if let stringValue = value as? String {
            return NotificationStyle(rawValue: Int(stringValue)!)!
        }

        return NotificationStyle(rawValue: Constants.notificationStyle)!
    }
}
