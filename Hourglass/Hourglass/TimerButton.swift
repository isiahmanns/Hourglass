import SwiftUI
import Combine

struct TimerButton: View {
    @StateObject var model: Timer.Model
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            Text(String(model.length))
        }
        .buttonStyle(TimerButton.Style(for: model.state))
        .accessibilityIdentifier("\(model.length)s-timer-button")
    }
}

extension TimerButton {
    private struct Style: ButtonStyle {
        let size: Double = 60
        let state: Timer.State

        @ViewBuilder
        var overlayProvider: some View {
            switch state {
            case .inactive:
                EmptyView()
            case .active:
                Circle()
                    .stroke(Color.accent, lineWidth: 4.0)
            }
        }

        init(for state: Timer.State) {
            self.state = state
        }

        func makeBody(configuration: Self.Configuration) -> some View {
            configuration.label
                .frame(width: size, height: size, alignment: .center)
                .background(Color.surface)
                .foregroundColor(Color.onSurface)
                .clipShape(Circle())
                .contentShape(Circle())
                .opacity(configuration.isPressed ? 0.8 : 1.0)
                .overlay(overlayProvider)
        }
    }
}

struct TimerButton_Previews: PreviewProvider {
    static var previews: some View {
        let timerModel = Timer.Model(length: 15, category: .rest, size: .large)
        TimerButton(model: timerModel) {}
            .font(Font.poppins)
    }
}
