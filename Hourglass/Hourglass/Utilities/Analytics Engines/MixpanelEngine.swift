import Foundation
import Mixpanel

struct MixpanelEngine: AnalyticsEngineType {
    static let shared = MixpanelEngine(mixpanel: Mixpanel.self, bundle: Bundle.main)

    let mixpanel: Mixpanel.Type

    private init(mixpanel: Mixpanel.Type, bundle: Bundle) {
        self.mixpanel = mixpanel
        guard let token = bundle.mixpanelToken else { fatalError() }
        configure(token: token)
    }

    private func configure(token: String) {
        mixpanel.initialize(token: token)
    }

    func logEvent(name: String, metadata: Metadata?) {
        mixpanel.mainInstance().track(event: name, properties: metadata)
    }
}
