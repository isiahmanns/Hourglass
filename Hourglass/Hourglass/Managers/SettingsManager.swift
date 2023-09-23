import Combine
import Foundation

/**
 Computed properties for app settings values in UserDefaults.

 The UserDefaults values primarily get set via the SettingsMenu UI bindings.
 The computed property setters are used for unit testing.
 These properties are exposed to objc to support KVO.
 */

extension UserDefaults {
    // MARK: - Rest Settings
    @objc dynamic var restWarningThreshold: SettingsThreshold.RawValue {
        object(forKey: SettingsKeys.restWarningThreshold.rawValue)
        as? Int ?? Constants.restWarningThreshold
    }

    @objc dynamic var enforceRestThreshold: SettingsThreshold.RawValue {
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

    // MARK: - Rest Warning Threshold
    func setRestWarningThreshold(_ threshold: SettingsThreshold) {
        let thresholdRawValue = threshold.rawValue
        if store.restWarningThreshold != thresholdRawValue {
            store.set(thresholdRawValue, forKey: SettingsKeys.restWarningThreshold.rawValue)
        }
    }

    func getRestWarningThreshold() -> SettingsThreshold {
        let thresholdRawValue = store.restWarningThreshold
        return SettingsThreshold(rawValue: thresholdRawValue)!
    }

    // MARK: - Enforce Rest Threshold
    func setEnforceRestThreshold(_ threshold: SettingsThreshold) {
        let thresholdRawValue = threshold.rawValue
        if store.enforceRestThreshold != thresholdRawValue {
            store.set(thresholdRawValue, forKey: SettingsKeys.enforceRestThreshold.rawValue)
        }
    }

    func getEnforceRestThreshold() -> SettingsThreshold {
        let thresholdRawValue = store.enforceRestThreshold
        return SettingsThreshold(rawValue: thresholdRawValue)!
    }

    // MARK: - Get Back to Work
    func setGetBackToWork(isEnabled: Bool) {
        if store.getBackToWork != isEnabled {
            store.set(isEnabled, forKey: SettingsKeys.getBackToWork.rawValue)
        }
    }

    func getGetBackToWorkIsEnabled() -> Bool {
        store.getBackToWork
    }

    // MARK: - Sound
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

enum SettingsThreshold: Int {
    case off = 0
    case k1 = 1
    case k2 = 2
    case k3 = 3
    case k4 = 4
    case k5 = 5
    case k6 = 6
}
