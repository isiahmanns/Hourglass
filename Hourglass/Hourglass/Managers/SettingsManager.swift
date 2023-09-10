import Combine
import Foundation

/**
 Computed properties for app settings values in UserDefaults.

 The UserDefaults values primarily get set via the SettingsMenu UI bindings.
 The computed property setters are used for unit testing.
 These properties are exposed to objc to support KVO.
 */
// TODO: - Remove timer settings
extension UserDefaults {
    // MARK: - Timer Lengths
    @objc dynamic var timerFocusSmall: Int {
        object(forKey: SettingsKeys.TimerSetting.timerFocusSmall.rawValue)
        as? Int ?? Constants.timerFocusSmall
    }

    @objc dynamic var timerFocusMedium: Int {
        object(forKey: SettingsKeys.TimerSetting.timerFocusMedium.rawValue)
        as? Int ?? Constants.timerFocusMedium
    }

    @objc dynamic var timerFocusLarge: Int {
        object(forKey: SettingsKeys.TimerSetting.timerFocusLarge.rawValue)
        as? Int ?? Constants.timerFocusLarge
    }

    @objc dynamic var timerRestSmall: Int {
        object(forKey: SettingsKeys.TimerSetting.timerRestSmall.rawValue)
        as? Int ?? Constants.timerRestSmall
    }

    @objc dynamic var timerRestMedium: Int {
        object(forKey: SettingsKeys.TimerSetting.timerRestMedium.rawValue)
        as? Int ?? Constants.timerRestMedium
    }

    @objc dynamic var timerRestLarge: Int {
        object(forKey: SettingsKeys.TimerSetting.timerRestLarge.rawValue)
        as? Int ?? Constants.timerRestLarge
    }

    // MARK: - Rest Settings
    @objc dynamic var restWarningThreshold: Int {
        object(forKey: SettingsKeys.restWarningThreshold.rawValue)
        as? Int ?? Constants.restWarningThreshold
    }

    @objc dynamic var enforceRestThreshold: Int {
        object(forKey: SettingsKeys.enforceRestThreshold.rawValue)
        as? Int ?? Constants.enforceRestThreshold
    }

    @objc dynamic var getBackToWork: Bool {
        object(forKey: SettingsKeys.getBackToWork.rawValue)
        as? Bool ?? Constants.getBackToWorkIsEnabled
    }
}

struct SettingsManager {
    static let shared = SettingsManager(store: UserDefaults.standard)
    private let store: UserDefaults

    private init(store: UserDefaults) {
        self.store = store
    }

    func observe<T>(_ keypath: KeyPath<UserDefaults, T>, handler: @escaping (T) -> Void) {
        let subscriber = Subscribers.Sink<T, Never> { _ in
        } receiveValue: { value in
            handler(value)
        }

        store.publisher(for: keypath, options: [.new])
            .subscribe(subscriber)
    }

    // Timer
    func setTimer(length: Int, for timerSetting: SettingsKeys.TimerSetting) {
        switch timerSetting {
        case .timerFocusSmall:
            store.set(length, forKey: SettingsKeys.TimerSetting.timerFocusSmall.rawValue)
        case .timerFocusMedium:
            store.set(length, forKey: SettingsKeys.TimerSetting.timerFocusMedium.rawValue)
        case .timerFocusLarge:
            store.set(length, forKey: SettingsKeys.TimerSetting.timerFocusLarge.rawValue)
        case .timerRestSmall:
            store.set(length, forKey: SettingsKeys.TimerSetting.timerRestSmall.rawValue)
        case .timerRestMedium:
            store.set(length, forKey: SettingsKeys.TimerSetting.timerRestMedium.rawValue)
        case .timerRestLarge:
            store.set(length, forKey: SettingsKeys.TimerSetting.timerRestLarge.rawValue)
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
    func setRestWarningThreshold(_ value: Int, conservatively: Bool = false) {
        if conservatively {
            if store.restWarningThreshold != value {
                store.set(value, forKey: SettingsKeys.restWarningThreshold.rawValue)
            }
        } else {
            store.set(value, forKey: SettingsKeys.restWarningThreshold.rawValue)
        }
    }

    func getRestWarningThreshold() -> Int {
        store.restWarningThreshold
    }

    // Enforce Rest Threshold
    func setEnforceRestThreshold(_ value: Int, conservatively: Bool = false) {
        if conservatively {
            if store.enforceRestThreshold != value {
                store.set(value, forKey: SettingsKeys.enforceRestThreshold.rawValue)
            }
        } else {
            store.set(value, forKey: SettingsKeys.enforceRestThreshold.rawValue)
        }
    }

    func getEnforceRestThreshold() -> Int {
        store.enforceRestThreshold
    }

    // Get Back to Work
    func setGetBackToWork(isEnabled: Bool, conservatively: Bool = false) {
        if conservatively {
            if store.getBackToWork != isEnabled {
                store.set(isEnabled, forKey: SettingsKeys.getBackToWork.rawValue)
            }
        } else {
            store.set(isEnabled, forKey: SettingsKeys.getBackToWork.rawValue)
        }
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

    // TODO: - Remove
    // Fullscreen Break
    /*
    func setFullScreenOnBreak(isEnabled: Bool) {
        store.set(isEnabled, forKey: SettingsKeys.fullScreenOnBreak.rawValue)
    }

    func getFullScreenOnBreakIsEnabled() -> Bool {
        store.object(forKey: SettingsKeys.fullScreenOnBreak.rawValue)
        as? Bool ?? Constants.fullscreenOnBreak
    }
     */
}
