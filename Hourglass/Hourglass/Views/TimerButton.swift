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
        .accessibilityIdentifier("\(model.length)m-timer-button")
    }
}

extension TimerButton {
    static let size: Double = 56

    private struct Style: ButtonStyle {
        let state: Timer.State

        init(for state: Timer.State) {
            self.state = state
        }

        func makeBody(configuration: Self.Configuration) -> some View {
            configuration.label
                .frame(width: size, height: size, alignment: .center)
                .background(Color.Hourglass.surface)
                .foregroundColor(Color.Hourglass.onSurface)
                .clipShape(Circle())
                .contentShape(Circle())
                .opacity(opacityProvider(configuration.isPressed))
                .overlay(overlayProvider)
        }

        @ViewBuilder
        private var overlayProvider: some View {
            switch state {
            case .inactive:
                EmptyView()
            case .active:
                Circle()
                    .stroke(Color.Hourglass.accent, lineWidth: 4.0)
            }
        }

        private func opacityProvider(_ isPressed: Bool) -> Double {
            isPressed ? 0.8 : 1.0
        }
    }
}

struct TimerButton_Previews: PreviewProvider {
    static var previews: some View {
        let timerModel = Timer.Model(length: 15)
        TimerButton(model: timerModel) {}
            .font(Font.poppins)
    }
}
