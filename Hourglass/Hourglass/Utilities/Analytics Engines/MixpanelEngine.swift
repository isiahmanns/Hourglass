import Foundation
import Mixpanel

struct MixpanelEngine: AnalyticsEngineType {
    static let shared = MixpanelEngine()

    private init() {
        guard let token = Bundle.main.object(forInfoDictionaryKey: "MIXPANEL_TOKEN") as? String
        else { fatalError() }

        Mixpanel.initialize(token: token)
    }
    
    func logEvent(name: String, metadata: [String : Any]) {
        let metadata = metadata.mapValues { value in
            value as? MixpanelType
        }
        Mixpanel.mainInstance().track(event: name, properties: metadata)
    }
}
