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

    // MARK: - Rest Warning Threshold
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

    // MARK: - Enforce Rest Threshold
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

    // MARK: - Get Back to Work
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
