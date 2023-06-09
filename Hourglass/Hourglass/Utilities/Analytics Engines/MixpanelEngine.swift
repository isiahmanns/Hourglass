import Foundation
import Mixpanel

struct MixpanelEngine: AnalyticsEngineType {
    static let shared = MixpanelEngine()

    private init() {
        guard let token = Bundle.main.object(forInfoDictionaryKey: "MIXPANEL_TOKEN") as? String
        else { fatalError() }

        Mixpanel.initialize(token: token)
    }

    func logEvent(name: String, metadata: [String: AnalyticsDataType]) {
        Mixpanel.mainInstance().track(event: name, properties: metadata)
    }
}
