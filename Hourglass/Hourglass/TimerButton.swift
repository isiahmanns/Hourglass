import SwiftUI

struct TimerButton: View {
    let value: Int

    var body: some View {
        Button {
            print("tap")
            // TODO: (#3) Publish state change to parent context
        } label: {
            Text(String(value))
        }
        .buttonStyle(TimerButtonStyle())
    }
}

private struct TimerButtonStyle: ButtonStyle {
    let size: Double = 60

    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .frame(width: size, height: size, alignment: .center)
            .background(Color.surface)
            .foregroundColor(Color.onSurface)
            .clipShape(Circle())
            .contentShape(Circle())
            .overlay(
                Circle()
                    //.strokeBorder(Color.accent, lineWidth: 3.0)
                    .stroke(Color.accent, lineWidth: 4.0)
            )
            .opacity(configuration.isPressed ? 0.8 : 1.0)
//            .scaleEffect(configuration.isPressed ? 1.2 : 1)
//            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct TimerButton_Previews: PreviewProvider {
    static var previews: some View {
        TimerButton(value: 15)
            .font(Font.poppins)
    }
}
