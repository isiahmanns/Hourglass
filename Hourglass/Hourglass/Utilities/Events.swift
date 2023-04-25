enum HourglassEventKey {
    enum Timer {
        case timerDidStart
        case timerDidTick
        case timerDidComplete
        case timerWasCancelled
    }

    enum Progress {
        case restWarningThresholdMet
        case enforceRestThresholdMet
    }
}
