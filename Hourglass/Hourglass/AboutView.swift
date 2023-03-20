import SwiftUI

struct AboutView: View {
    var body: some View {
        HStack(alignment: .center, spacing: 50) {
            // Icon
            Logo(size: 130)

            // Info
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Hourglass")
                        .font(.poppins) // TODO: - Rename API with sizes
                    Text("Version 1.0")
                }

                VStack(alignment: .leading) {
                    Text("Hourglass lets you decide how you work.")
                    Text("Made with ♥ in Brooklyn.")
                }

                HStack(spacing: 10) {
                    Button {
                        print("tapped BMAC")
                    } label: {
                        Text("Support Hourglass")
                    }
                    .buttonStyle(AboutView.PillButtonStyle())

                    Button {
                        print("tapped website")
                    } label: {
                        Text("Website")
                    }
                    .buttonStyle(AboutView.PillButtonStyle())
                }

                Text("Copyright © 2023 Isiah Michael Manns.")
                    .foregroundColor(Color.onBackgroundSecondary)
            }
        }
        .padding([.leading, .trailing], 50)
        .padding([.top, .bottom], 50)
        .background(Color.background)
        .foregroundColor(Color.onBackgroundPrimary)
    }
}

extension AboutView {
    private struct PillButtonStyle: ButtonStyle {
        let capsule = Capsule(style: .continuous)

        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .padding([.top, .bottom], 5)
                .padding([.leading, .trailing], 10)
                .background(Color.clear)
                .clipShape(capsule)
                .contentShape(capsule)
                .overlay {
                    capsule
                        .stroke(Color.onBackgroundPrimary)
                }
                .foregroundColor(Color.onBackgroundPrimary)
                .opacity(configuration.isPressed ? 0.8 : 1)
        }
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
