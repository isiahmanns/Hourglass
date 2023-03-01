import SwiftUI

struct ContentView: View {
    let ySpacing = 20.0
    let xSpacing = 26.0

    var body: some View {
        VStack(alignment: .center, spacing: 30.0) {
            Logo()

            HStack(alignment: .center, spacing: xSpacing) {
                VStack(alignment: .center, spacing: ySpacing) {
                    Header(content: "Focus")
                    TimerButton(value: 15)
                    TimerButton(value: 25)
                    TimerButton(value: 35)
                }

                VStack(alignment: .center, spacing: ySpacing) {
                    Header(content: "Break")
                    TimerButton(value: 3)
                    TimerButton(value: 5)
                    TimerButton(value: 10)
                }
            }

            SettingsButton()
        }
        .padding(40)
        .background(Color.background)
        .cornerRadius(50)
    }
}

private struct Logo: View {
    let size: Double = 40

    var body: some View {
        Image("hourglassLogo")
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
    }
}

private struct Header: View {
    let content: String

    var body: some View {
        Text(content)
            .foregroundColor(Color.onBackgroundPrimary)
    }
}

private struct SettingsButton: View {
    var body: some View {
        Image(systemName: "gearshape.fill")
            .imageScale(.large)
            .foregroundColor(Color.onBackgroundSecondary)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .font(Font.poppins)
    }
}
