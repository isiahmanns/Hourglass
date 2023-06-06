struct StdoutEngine: AnalyticsEngine {
    func logEvent(name: String, metadata: [String : Any]) {
        print("Logging event", name, metadata)
    }
}
