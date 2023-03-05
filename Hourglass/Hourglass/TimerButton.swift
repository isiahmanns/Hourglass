import SwiftUI
import Combine

struct TimerButton: View {
    let value: Int
    @State var state: Timer.State
    let publisher: AnyPublisher<Timer.State, Never>
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            Text(String(value))
        }
        .buttonStyle(TimerButton.Style(for: state))
        .onReceive(publisher) { timerState in
            state = timerState
        }
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
        TimerButton(value: 15,
                    state: .active,
                    publisher: Empty<Timer.State, Never>().eraseToAnyPublisher()) {}
            .font(Font.poppins)
    }
}
