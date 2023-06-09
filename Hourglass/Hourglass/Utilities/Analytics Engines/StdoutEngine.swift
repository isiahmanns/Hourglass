struct StdoutEngine: AnalyticsEngineType {
    static let shared = StdoutEngine()

    private init() {}

    func logEvent(name: String, metadata: [String: String]) {
        print("Logging event", name, metadata)
    }
}
