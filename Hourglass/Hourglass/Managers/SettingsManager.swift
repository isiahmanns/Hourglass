import Foundation

/**
 Computed properties for app settings values in UserDefaults.

 The UserDefaults values primarily get set via the SettingsMenu UI bindings.
 The computed property setters are used for unit testing.
 These properties are exposed to objc to support KVO.
 */
private extension UserDefaults {
    // MARK: - Timer Lengths
    @objc dynamic var timerFocusSmall: Int {
        set {
            set(newValue, forKey: SettingsKeys.TimerSetting.timerFocusSmall.rawValue)
        }
        get {
            object(forKey: SettingsKeys.TimerSetting.timerFocusSmall.rawValue)
            as? Int ?? Constants.timerFocusSmallDefault
        }
    }

    @objc dynamic var timerFocusMedium: Int {
        set {
            set(newValue, forKey: SettingsKeys.TimerSetting.timerFocusMedium.rawValue)
        }
        get {
            object(forKey: SettingsKeys.TimerSetting.timerFocusMedium.rawValue)
            as? Int ?? Constants.timerFocusMediumDefault
        }
    }

    @objc dynamic var timerFocusLarge: Int {
        set {
            set(newValue, forKey: SettingsKeys.TimerSetting.timerFocusLarge.rawValue)
        }
        get {
            object(forKey: SettingsKeys.TimerSetting.timerFocusLarge.rawValue)
            as? Int ?? Constants.timerFocusLargeDefault
        }
    }

    @objc dynamic var timerRestSmall: Int {
        set {
            set(newValue, forKey: SettingsKeys.TimerSetting.timerRestSmall.rawValue)
        }
        get {
            object(forKey: SettingsKeys.TimerSetting.timerRestSmall.rawValue)
            as? Int ?? Constants.timerRestSmallDefault
        }
    }

    @objc dynamic var timerRestMedium: Int {
        set {
            set(newValue, forKey: SettingsKeys.TimerSetting.timerRestMedium.rawValue)
        }
        get {
            object(forKey: SettingsKeys.TimerSetting.timerRestMedium.rawValue)
            as? Int ?? Constants.timerRestMediumDefault
        }
    }

    @objc dynamic var timerRestLarge: Int {
        set {
            set(newValue, forKey: SettingsKeys.TimerSetting.timerRestLarge.rawValue)
        }
        get {
            object(forKey: SettingsKeys.TimerSetting.timerRestLarge.rawValue)
            as? Int ?? Constants.timerRestLargeDefault
        }
    }

    // MARK: - Rest Settings
    @objc dynamic var restWarningThreshold: Int {
        set {
            set(newValue, forKey: SettingsKeys.restWarningThreshold.rawValue)
        }
        get {
            object(forKey: SettingsKeys.restWarningThreshold.rawValue)
            as? Int ?? Constants.restWarningThresholdDefault
        }
    }

    @objc dynamic var enforceRestThreshold: Int {
        set {
            set(newValue, forKey: SettingsKeys.enforceRestThreshold.rawValue)
        }
        get {
            object(forKey: SettingsKeys.enforceRestThreshold.rawValue)
            as? Int ?? Constants.enforceRestThresholdDefault
        }
    }

    @objc dynamic var getBackToWork: Bool {
        set {
            set(newValue, forKey: SettingsKeys.getBackToWork.rawValue)
        }
        get {
            object(forKey: SettingsKeys.getBackToWork.rawValue)
            as? Bool ?? Constants.getBackToWorkIsEnabled
        }
    }
}

struct SettingsManager {
    static let shared = SettingsManager(store: UserDefaults.standard)
    let store: UserDefaults

    private init(store: UserDefaults) {
        self.store = store
    }

    // Timer
    func setTimer(length: Int, for timerSetting: SettingsKeys.TimerSetting) {
        switch timerSetting {
        case .timerFocusSmall:
            store.timerFocusSmall = length
        case .timerFocusMedium:
            store.timerFocusMedium = length
        case .timerFocusLarge:
            store.timerFocusLarge = length
        case .timerRestSmall:
            store.timerRestSmall = length
        case .timerRestMedium:
            store.timerRestMedium = length
        case .timerRestLarge:
            store.timerRestLarge = length
        }
    }

    func getTimerLength(for timerSetting: SettingsKeys.TimerSetting) -> Int {
        switch timerSetting {
        case .timerFocusSmall:
            return store.timerFocusSmall
        case .timerFocusMedium:
            return store.timerFocusMedium
        case .timerFocusLarge:
            return store.timerFocusLarge
        case .timerRestSmall:
            return store.timerRestSmall
        case .timerRestMedium:
            return store.timerRestMedium
        case .timerRestLarge:
            return store.timerRestLarge
        }
    }

    // Rest Warning Threshold
    func setRestWarningThreshold(_ value: Int) {
        store.restWarningThreshold = value
    }

    func getRestWarningThreshold() -> Int {
        store.restWarningThreshold
    }

    // Enforce Rest Threshold
    func setEnforceRestThreshold(_ value: Int) {
        store.enforceRestThreshold = value
    }

    func getEnforceRestThreshold() -> Int {
        store.enforceRestThreshold
    }

    // Get Back to Work
    func setGetBackToWork(isEnabled: Bool) {
        store.getBackToWork = isEnabled
    }

    func getGetBackToWorkIsEnabled() -> Bool {
        store.getBackToWork
    }

    // Sound
    func setSound(isEnabled: Bool) {
        store.set(isEnabled, forKey: SettingsKeys.soundIsEnabled.rawValue)
    }

    func getSoundIsEnabled() -> Bool {
        store.object(forKey: SettingsKeys.soundIsEnabled.rawValue)
        as? Bool ?? Constants.soundIsEnabled
    }

    // Fullscreen Break
    func setFullScreenOnBreak(isEnabled: Bool) {
        store.set(isEnabled, forKey: SettingsKeys.fullScreenOnBreak.rawValue)
    }

    func getFullScreenOnBreakIsEnabled() -> Bool {
        store.object(forKey: SettingsKeys.fullScreenOnBreak.rawValue)
        as? Bool ?? Constants.fullscreenOnBreak
    }

    // Notification Style
    func setNotification(style: NotificationStyle) {
        store.set(style.rawValue, forKey: SettingsKeys.notificationStyle.rawValue)
    }

    func getNotificationStyle() -> NotificationStyle {
        #if DEBUG || CITESTING
        if let overrideValue = ProcessInfo.processInfo.environment[SettingsKeys.notificationStyle.rawValue] {
            return NotificationStyle(rawValue: Int(overrideValue)!)!
        }
        #endif
        let value = store.object(forKey: SettingsKeys.notificationStyle.rawValue)
        as? Int ?? Constants.notificationStyle

        return NotificationStyle(rawValue: value)!
    }
}
