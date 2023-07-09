enum HourglassEventKey {
    @objc enum Timer: Int {
        case timerDidStart
        case timerDidTick
        case timerDidComplete
        case timerWasCancelled
    }

    @objc enum Progress: Int {
        case restWarningThresholdMet
        case enforceRestThresholdMet
        case getBackToWork
    }
}
