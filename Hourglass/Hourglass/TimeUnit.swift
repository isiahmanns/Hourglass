final class TimeUnit {
    struct Seconds {
        let value: Int
        var toMinutesSeconds: (minutes: Int, seconds: Int) {
            (minutes: value / 60, seconds: value % 60)
        }
    }
}

extension Int {
    var asSeconds: TimeUnit.Seconds {
        TimeUnit.Seconds(value: self)
    }
}
