import SwiftUI

struct AboutView: View {
    let bundle: Bundle
    let iapManager: IAPManager
    @State private var showStoreFlow: Bool = false

    var body: some View {
        HStack(alignment: .center, spacing: 50) {
            // Icon
            Logo(size: 130)

            // Info
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Hourglass")
                        .font(.poppins)

                    if let releaseNo = bundle.releaseVersionNumber,
                       let buildNo = bundle.buildVersionNumber {
                        Text("Version \(releaseNo) (\(buildNo))")
                    }
                }

                VStack(alignment: .leading) {
                    Text("Hourglass lets you decide how you work.")
                    Text("Made with ♥ in Brooklyn.")
                }

                HStack(spacing: 10) {
                    Button {
                        showStoreFlow.toggle()
                    } label: {
                        Text("Support Hourglass")
                    }
                    .buttonStyle(AboutView.PillButtonStyle())

                    Button {
                        openURL("https://www.madebyisiah.com/projects/hourglass")
                    } label: {
                        Text("Website")
                    }
                    .buttonStyle(AboutView.PillButtonStyle())
                }

                Text("Copyright © 2023 Isiah Michael Manns.")
                    .foregroundColor(Color.Hourglass.onBackgroundSecondary)
            }
        }
        .padding([.leading, .trailing], 50)
        .padding([.top, .bottom], 50)
        .background(Color.Hourglass.background)
        .foregroundColor(Color.Hourglass.onBackgroundPrimary)
        .sheet(isPresented: $showStoreFlow) {
            IAPStoreView(iapManager: iapManager,
                         isPresenting: $showStoreFlow)
        }
    }

    private func openURL(_ urlString: String) {
        if let url = URL(string: urlString) {
            NSWorkspace.shared.open(url)
        }
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
                        .stroke(Color.Hourglass.onBackgroundPrimary)
                }
                .foregroundColor(Color.Hourglass.onBackgroundPrimary)
                .opacity(configuration.isPressed ? 0.8 : 1)
        }
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView(bundle: Bundle.main,
                  iapManager: IAPManager.shared)
    }
}
