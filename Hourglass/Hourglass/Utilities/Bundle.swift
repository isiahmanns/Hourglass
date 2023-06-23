import Foundation

extension Bundle {
    var mixpanelToken: String? {
        object(forInfoDictionaryKey: "MIXPANEL_TOKEN") as? String
    }

    var releaseVersionNumber: String? {
        object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }

    var buildVersionNumber: String? {
        object(forInfoDictionaryKey: "CFBundleVersion") as? String
    }
}
