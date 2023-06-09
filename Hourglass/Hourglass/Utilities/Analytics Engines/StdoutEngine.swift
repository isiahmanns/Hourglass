struct StdoutEngine: AnalyticsEngineType {
    static let shared = StdoutEngine()

    private init() {}

    func logEvent(name: String, metadata: [String: AnalyticsDataType]?) {
        print("Logging event", name, metadata ?? "")
    }
}
