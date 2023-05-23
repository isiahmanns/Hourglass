final class TimeUnit {
    struct Seconds {
        let value: Int

        var toMinutesSeconds: (minutes: Int, seconds: Int) {
            (minutes: value / 60, seconds: value % 60)
        }

        var toHoursMinutes: (hours: Int, minutes: Int) {
            (hours: value / 3600, minutes: (value % 3600) / 60)
        }
    }
}

extension Int {
    var asSeconds: TimeUnit.Seconds {
        TimeUnit.Seconds(value: self)
    }
}
