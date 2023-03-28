import SwiftUI

struct TimestampView: View {
    @StateObject var timerManager: TimerManager

    var body: some View {
        Text(timerManager.timeStamp)
            .monospacedDigit()
            .padding([.leading, .trailing], 5)
            .padding([.top, .bottom], 1)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .inset(by: 0.5)
                    .stroke(lineWidth: 1)
            )
    }
}
