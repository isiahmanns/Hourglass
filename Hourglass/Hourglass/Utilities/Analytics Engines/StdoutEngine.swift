struct StdoutEngine: AnalyticsEngineType {
    static let shared = StdoutEngine()

    private init() {}

    func logEvent(name: String, metadata: Metadata?) {
        print("Logging event", name, metadata ?? "")
    }
}
